extends Node2D
class_name World


enum Layer {
	MACHINE,
	REDSTONE1,
	REDSTONE2,
	REDSTONE3,
	REDSTONE4,
	OVERLAY,
	ALL
}

const GRID_SIZE: int = 1024
const GRID_HALF: int = GRID_SIZE / 2
const POWER_SHADER: Shader = preload("res://tiles/power.gdshader")

var world: Dictionary = {}

var powerData: PackedByteArray = PackedByteArray()
var powerImage: Image
var powerTexture: ImageTexture
var powerDirty: bool = false

var gridBackground: ColorRect

@onready var layers: Array[TileMapLayer] = [
	$Machines,
	$Redstone1,
	$Redstone2,
	$Redstone3,
	$Redstone4,
	$Overlay
]

static var componentClasses: Dictionary = {
	Component.Type.WIRE: Wire,
	Component.Type.REPEATER: Repeater,
	Component.Type.COMPARATOR: Comparator,
	Component.Type.NEGATOR: Negator,
	Component.Type.GENERATOR: Generator,
	Component.Type.CROSSING: Crossing,
	Component.Type.FLICKER: Flicker,
	Component.Type.SLOGGER: Slogger,
	Component.Type.LAMP: Lamp
}


func _ready():
	Game.world = self
	Game.wireChanged.connect(updateWireColor)
	Game.eraserToggled.connect(onEraserToggle)
	updateWireColor(Game.wireColor)
	setupPowerTexture()
	setupGridBackground()
	set_notify_transform(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED and powerTexture != null:
		updateShaderOrigin()


func setupPowerTexture():
	powerData.resize(GRID_SIZE * GRID_SIZE * 4)
	powerData.fill(0)
	powerImage = Image.create_empty(GRID_SIZE, GRID_SIZE, false, Image.FORMAT_RGBA8)
	powerTexture = ImageTexture.create_from_image(powerImage)
	var tileSize := Vector2(layers[Layer.MACHINE].tile_set.tile_size)
	for layer in range(Layer.REDSTONE1, Layer.REDSTONE4 + 1):
		var mat := ShaderMaterial.new()
		mat.shader = POWER_SHADER
		mat.set_shader_parameter("powerTex", powerTexture)
		mat.set_shader_parameter("channel", layer - Layer.REDSTONE1)
		mat.set_shader_parameter("tileSize", tileSize)
		mat.set_shader_parameter("gridSize", float(GRID_SIZE))
		layers[layer].use_parent_material = false
		layers[layer].material = mat
	updateShaderOrigin()


func updateShaderOrigin():
	for layer in range(Layer.REDSTONE1, Layer.REDSTONE4 + 1):
		(layers[layer].material as ShaderMaterial).set_shader_parameter("origin", global_position)


func setupGridBackground():
	var tileSize := Vector2(layers[Layer.MACHINE].tile_set.tile_size)
	gridBackground = ColorRect.new()
	gridBackground.position = -tileSize * GRID_HALF
	gridBackground.size = tileSize * GRID_SIZE
	gridBackground.z_index = -1
	gridBackground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gridBackground.color = Game.bgColor
	add_child(gridBackground)
	Game.bgChanged.connect(func(color: Color): gridBackground.color = color)


func isInBounds(pos: Vector2i) -> bool:
	return pos.x >= -GRID_HALF and pos.x < GRID_HALF and pos.y >= -GRID_HALF and pos.y < GRID_HALF


func setPower(layer: Layer, pos: Vector2i, power: int):
	if not isInBounds(pos): return
	var idx := ((pos.y + GRID_HALF) * GRID_SIZE + pos.x + GRID_HALF) * 4 + layer - Layer.REDSTONE1
	var value := power * 17
	if powerData[idx] == value: return
	powerData[idx] = value
	powerDirty = true


func flushPower():
	if not powerDirty: return
	powerDirty = false
	powerImage.set_data(GRID_SIZE, GRID_SIZE, false, Image.FORMAT_RGBA8, powerData)
	powerTexture.update(powerImage)


func updateWireColor(color: Color):
	layers[Layer.REDSTONE1].modulate = color
	layers[Layer.REDSTONE2].modulate = color
	layers[Layer.REDSTONE3].modulate = color
	layers[Layer.REDSTONE4].modulate = color


func onEraserToggle(active: bool):
	layers[Layer.OVERLAY].modulate = Color(1.0, 0.5, 0.5, 0.35) if active else Color(1.0, 1.0, 1.0, 0.35)


func isRedstoneLayer(layer: Layer) -> bool:
	return layer >= Layer.REDSTONE1 and layer <= Layer.REDSTONE4


func setCell(layer: Layer, pos: Vector2i, source: int, atlasCoords: Vector2i, alternative: int):
	if isRedstoneLayer(layer):
		setPower(layer, pos, 15 - (alternative & 15))
		alternative &= ~15
	layers[layer].set_cell(pos, source, atlasCoords, alternative)


func eraseCell(layer: Layer, pos: Vector2i):
	if isRedstoneLayer(layer):
		setPower(layer, pos, 0)
	layers[layer].erase_cell(pos)


func getTileAt(pos: Vector2i) -> Component:
	if pos not in world: return null
	return world[pos]


func getTileConnectionIDAt(pos: Vector2i, dir: int) -> int:
	if pos not in world: return -1
	return world[pos].getConnectionID(dir)


func isTileConnectedAt(pos: Vector2i, dir: int) -> bool:
	if pos not in world: return false
	return world[pos].isConnectedAt(dir)


func updateTextures(layer: Layer, pos: Vector2i):
	if layer == Layer.ALL:
		updateTextures(Layer.MACHINE, pos)
		updateTextures(Layer.REDSTONE1, pos)
		updateTextures(Layer.REDSTONE2, pos)
		updateTextures(Layer.REDSTONE3, pos)
		updateTextures(Layer.REDSTONE4, pos)
		return
	if pos not in world:
		eraseCell(layer, pos)
	else:
		world[pos].updateTileAtLayer(layer)


func cleanAllLayersAt(pos: Vector2i):
	eraseCell(Layer.MACHINE, pos)
	eraseCell(Layer.REDSTONE1, pos)
	eraseCell(Layer.REDSTONE2, pos)
	eraseCell(Layer.REDSTONE3, pos)
	eraseCell(Layer.REDSTONE4, pos)


func isTileEmpty(pos: Vector2i):
	return not pos in world


func empty():
	for pos in world:
		cleanAllLayersAt(pos)
	world.clear()
	


# --- NAVIGATION ---


var origMouse: Vector2 = Vector2.ZERO
var lastMousePos: Vector2i = Vector2i.ZERO
var dragging: bool = false
var horiz: bool = false
var vert: bool = false


func _process(delta: float) -> void:
	flushPower()
	if dragging:
		updateDragging()
	if Input.is_action_just_pressed("interact"):
		if not isTileEmpty(lastMousePos):
			world[lastMousePos].interact()
		Game.isEditDirty = true
	if Input.is_action_just_pressed("rotate"):
		Game.placingRotation = (Game.placingRotation + 1) % Side.ALL
	if Input.is_action_just_pressed("snap_horiz"):
		origMouse = get_viewport().get_mouse_position()
		horiz = true
	elif Input.is_action_just_released("snap_horiz"):
		horiz = false
	if Input.is_action_just_pressed("snap_vert"):
		origMouse = get_viewport().get_mouse_position()
		vert = true
	elif Input.is_action_just_released("snap_vert"):
		vert = false


func updateDragging():
	if Game.eraserActive:
		placeComponent(Component.Type.NONE, lastMousePos, Side.ALL)
		return
	if not isTileEmpty(lastMousePos) and not Game.doOverwrite:
		return
	placeComponent(Game.selectedComponent, lastMousePos, Game.placingRotation)


func placeComponent(type: Component.Type, pos: Vector2i, rot: int):
	if not isInBounds(pos): return
	if pos in world and world[pos].isEqualToNew(type): return
	if type == Component.Type.NONE:
		if pos not in world:
			return
		var elem = world[pos]
		world.erase(pos)
		elem.die()
		notifyNeighbors(pos)
		cleanAllLayersAt(pos)
		Game.isEditDirty = true
		return
	if pos in world:
		world[pos].die()
	world[pos] = componentClasses[type].new(pos, rot)
	cleanAllLayersAt(pos)
	updateTextures(Layer.ALL, pos)
	notifyNeighbors(pos)
	Game.isEditDirty = true


func notifyNeighbors(pos: Vector2i):
	for side in Side.ALL:
		var neighPos = pos + Side.vectors[side]
		if neighPos in world: world[neighPos].onNeighborChanged(Side.opposite[side])


func placeOverlay(pos: Vector2i):
	setCell(Layer.OVERLAY, pos, 0, Vector2i.ZERO, 0)


func removeOverlay(pos: Vector2i):
	eraseCell(Layer.OVERLAY, pos)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var halfSize := get_viewport_rect().size / 2
		removeOverlay(lastMousePos)
		var pos = event.position
		if horiz:
			pos.x = origMouse.x
		if vert:
			pos.y = origMouse.y
		lastMousePos = layers[Layer.OVERLAY].local_to_map(to_local((pos - halfSize) / owner.getCurrentZoom()))
			
		placeOverlay(lastMousePos)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("drag"): dragging = true
	elif event.is_action_released("drag"): dragging = false
