extends TileMap
class_name World

enum MachineType {
	WIRE,
	REPEATER,
	COMPARATOR,
	NEGATOR,
	GENERATOR,
	CROSSING,
	FLICKER,
	SLOGGER,
	NONE
}

enum Layer {
	MACHINE,
	REDSTONE1,
	REDSTONE2,
	REDSTONE3,
	REDSTONE4,
	OVERLAY,
	ALL
}


class UpdateAction:
	var tick: int
	var pos: Vector2i
	var objectType: MachineType
	var fromSelf: bool
	
	func _init(tick: int, pos: Vector2i, type: MachineType, fromSelf: bool):
		self.tick = tick
		self.pos = pos
		objectType = type
		self.fromSelf = fromSelf


class TileInfo:
	var atlas: int = -1
	var coords: Vector2i = Vector2i.ZERO
	var altID: int = -1
	
	func _init(atlas: int = -1, coords: Vector2i = Vector2i.ZERO, altID: int = -1):
		self.atlas = atlas
		self.coords = coords
		self.altID = altID


@onready var world: Dictionary
var tick: int = 0

var machines: Dictionary = {
	MachineType.WIRE: Wire,
	MachineType.REPEATER: Repeater,
	MachineType.COMPARATOR: Comparator,
	MachineType.NEGATOR: Negator,
	MachineType.GENERATOR: Generator,
	MachineType.CROSSING: null,
	MachineType.FLICKER: null,
	MachineType.SLOGGER: null
}
var forcedDelays: Dictionary = {
	MachineType.WIRE: 0,
	MachineType.REPEATER: 0,
	MachineType.COMPARATOR: 1,
	MachineType.NEGATOR: 1,
	MachineType.GENERATOR: 0,
	MachineType.CROSSING: 0,
	MachineType.FLICKER: 0,
	MachineType.SLOGGER: 0
}
var pendingActions: Array[UpdateAction] = []

var dragging: bool = false


func _ready():
	Save.wireChanged.connect(updateWireColor)
	Save.eraserToggled.connect(onEraserToggle)
	updateWireColor(Save.wireColor)


func _process(delta: float) -> void:
	if dragging:
		updateDragging()
	if Input.is_action_just_pressed("interact"):
		if not isTileEmpty(lastMousePos):
			world[lastMousePos].interact()
	if Input.is_action_just_pressed("rotate"):
		Save.placingRotation = (Save.placingRotation + 1) % Machine.Dir.ANY


func _physics_process(delta: float) -> void:
	var count = 0
	while count < pendingActions.size():
		var action: UpdateAction = pendingActions[count]
		if action.tick == tick:
			if action.pos in world and world[action.pos].getType() == action.objectType:
				world[action.pos].update(action.fromSelf)
			pendingActions.remove_at(count)
			count -= 1
		count += 1
	if pendingActions.size() > 0:
		tick += 1
	else:
		tick = 0


func updateWireColor(color: Color):
	set_layer_modulate(Layer.REDSTONE1, color)
	set_layer_modulate(Layer.REDSTONE2, color)
	set_layer_modulate(Layer.REDSTONE3, color)
	set_layer_modulate(Layer.REDSTONE4, color)


func onEraserToggle(active: bool):
	set_layer_modulate(Layer.OVERLAY, Color(1.0, 0.5, 0.5, 0.35) if active else Color(1.0, 1.0, 1.0, 0.35))


func placeMachine(type: MachineType, pos: Vector2i, rot: Machine.Dir):
	if type == MachineType.NONE or machines[type] == null:
		if pos in world:
			world[pos].die()
		world.erase(pos)
		updateTextures(Layer.ALL, pos)
		return
	world[pos] = machines[type].new(self, pos, rot)
	world[pos].update(true)
	updateTextures(Layer.ALL, pos)


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
		var cellData: TileInfo = world[pos].getTileAtLayer(layer)
		if cellData == null: 
			erase_cell(layer, pos)
			return
		set_cell(layer, pos, cellData.atlas, cellData.coords, cellData.altID)


func placeOverlay(pos: Vector2i):
	set_cell(Layer.OVERLAY as int, pos, 0, Vector2i.ZERO, 0)


func removeOverlay(pos: Vector2i):
	erase_cell(Layer.OVERLAY as int, pos)


func requestUpdate(delay: int, pos: Vector2i, dir: Machine.Dir):
	if pos not in world or not world[pos].isConnected(dir): return
	delay = max(delay, forcedDelays[world[pos].getType()])
	var update := UpdateAction.new(tick + delay, pos, world[pos].getType(), dir == Machine.Dir.ANY)
	pendingActions.append(update)


func getTileAt(pos: Vector2i):
	if isTileEmpty(pos): return null
	return world[pos]


func isTileEmpty(pos: Vector2i):
	return not pos in world


func getPowerAt(pos: Vector2i, from: Machine.Dir) -> int:
	if isTileEmpty(pos): return 0
	return world[pos].getPower(from)


func isConnectedAt(pos: Vector2i, dir: Machine.Dir) -> bool:
	if isTileEmpty(pos): return false
	return world[pos].isConnected(dir)


func updateDragging():
	if Save.eraserActive:
		placeMachine(MachineType.NONE, lastMousePos, Machine.Dir.ANY)
		return
	if not isTileEmpty(lastMousePos) and not Save.doOverwrite:
		return
	placeMachine(Save.selectedMachine, lastMousePos, Save.placingRotation)


var lastMousePos: Vector2i = Vector2i.ZERO
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var halfSize := get_viewport_rect().size / 2
		removeOverlay(lastMousePos)
		lastMousePos = local_to_map(to_local((event.position - halfSize) / owner.getCurrentZoom()))
		placeOverlay(lastMousePos)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("drag"): dragging = true
	elif event.is_action_released("drag"): dragging = false
