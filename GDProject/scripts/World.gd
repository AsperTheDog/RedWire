extends TileMap
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

var world: Dictionary = {}

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


func updateWireColor(color: Color):
	set_layer_modulate(Layer.REDSTONE1, color)
	set_layer_modulate(Layer.REDSTONE2, color)
	set_layer_modulate(Layer.REDSTONE3, color)
	set_layer_modulate(Layer.REDSTONE4, color)


func onEraserToggle(active: bool):
	set_layer_modulate(Layer.OVERLAY, Color(1.0, 0.5, 0.5, 0.35) if active else Color(1.0, 1.0, 1.0, 0.35))


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
		erase_cell(layer, pos)
	else:
		world[pos].updateTileAtLayer(layer)


func cleanAllLayersAt(pos: Vector2i):
	erase_cell(Layer.MACHINE, pos)
	erase_cell(Layer.REDSTONE1, pos)
	erase_cell(Layer.REDSTONE2, pos)
	erase_cell(Layer.REDSTONE3, pos)
	erase_cell(Layer.REDSTONE4, pos)


func isTileEmpty(pos: Vector2i):
	return not pos in world


# --- NAVIGATION ---


var lastMousePos: Vector2i = Vector2i.ZERO
var dragging: bool = false


func _process(delta: float) -> void:
	if dragging:
		updateDragging()
	if Input.is_action_just_pressed("interact"):
		if not isTileEmpty(lastMousePos):
			world[lastMousePos].interact()
	if Input.is_action_just_pressed("rotate"):
		Game.placingRotation = (Game.placingRotation + 1) % Side.ALL


func updateDragging():
	if Game.eraserActive:
		placeComponent(Component.Type.NONE, lastMousePos, Side.ALL)
		return
	if not isTileEmpty(lastMousePos) and not Game.doOverwrite:
		return
	placeComponent(Game.selectedComponent, lastMousePos, Game.placingRotation)


func placeComponent(type: Component.Type, pos: Vector2i, rot: int):
	if pos in world and world[pos].isEqualToNew(type): return
	if type == Component.Type.NONE:
		if pos not in world:
			return
		var elem = world[pos]
		world.erase(pos)
		elem.die()
		notifyNeighbors(pos)
		cleanAllLayersAt(pos)
		return
	if pos in world:
		world[pos].die()
	world[pos] = componentClasses[type].new(pos, rot)
	cleanAllLayersAt(pos)
	updateTextures(Layer.ALL, pos)
	notifyNeighbors(pos)


func notifyNeighbors(pos: Vector2i):
	for side in Side.ALL:
		var neighPos = pos + Side.vectors[side]
		if neighPos in world: world[neighPos].onNeighborChanged(Side.opposite[side])


func placeOverlay(pos: Vector2i):
	set_cell(Layer.OVERLAY as int, pos, 0, Vector2i.ZERO, 0)


func removeOverlay(pos: Vector2i):
	erase_cell(Layer.OVERLAY as int, pos)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var halfSize := get_viewport_rect().size / 2
		removeOverlay(lastMousePos)
		lastMousePos = local_to_map(to_local((event.position - halfSize) / owner.getCurrentZoom()))
		placeOverlay(lastMousePos)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("drag"): dragging = true
	elif event.is_action_released("drag"): dragging = false
