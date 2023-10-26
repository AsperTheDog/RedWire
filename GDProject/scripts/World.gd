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
	VALVE,
	PH_MACHINE,
	PH_REDSTONE1,
	PH_REDSTONE2,
	PH_REDSTONE3,
	PH_VALVE,
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
var pendingActions: Array[UpdateAction] = []

var dragging: bool = false


func _ready():
	Save.wireChanged.connect(updateWireColor)
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
	tick += 1


func updateWireColor(color: Color):
	set_layer_modulate(Layer.REDSTONE1, color)
	set_layer_modulate(Layer.REDSTONE2, color)
	set_layer_modulate(Layer.REDSTONE3, color)


func placeMachine(type: MachineType, pos: Vector2i, rot: Machine.Dir):
	if type == MachineType.NONE or machines[type] == null:
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
		updateTextures(Layer.VALVE, pos)
		return
	if pos not in world:
		erase_cell(layer, pos)
	else:
		var cellData: TileInfo = world[pos].getTileAtLayer(layer)
		if cellData == null: 
			erase_cell(layer, pos)
			return
		set_cell(layer, pos, cellData.atlas, cellData.coords, cellData.altID)


func addPhantomAtPos(pos: Vector2i, type: MachineType, rot: Machine.Dir):
	if type == MachineType.NONE or machines[type] == null: return
	var pMachine: TileInfo = machines[type].getPhantomTileAtPos(self, Layer.MACHINE, pos, rot)
	set_cell(Layer.PH_MACHINE as int, pos, pMachine.atlas, pMachine.coords, pMachine.altID)
	var pRedstone1: TileInfo = machines[type].getPhantomTileAtPos(self, Layer.REDSTONE1, pos, rot)
	set_cell(Layer.PH_REDSTONE1 as int, pos, pRedstone1.atlas, pRedstone1.coords, pRedstone1.altID)
	var pRedstone2: TileInfo = machines[type].getPhantomTileAtPos(self, Layer.REDSTONE2, pos, rot)
	set_cell(Layer.PH_REDSTONE2 as int, pos, pRedstone2.atlas, pRedstone2.coords, pRedstone2.altID)
	var pRedstone3: TileInfo = machines[type].getPhantomTileAtPos(self, Layer.REDSTONE3, pos, rot)
	set_cell(Layer.PH_REDSTONE3 as int, pos, pRedstone3.atlas, pRedstone3.coords, pRedstone3.altID)
	var pValve: TileInfo = machines[type].getPhantomTileAtPos(self, Layer.VALVE, pos, rot)
	set_cell(Layer.PH_VALVE as int, pos, pValve.atlas, pValve.coords, pValve.altID)


func removePhantomAtPos(pos: Vector2i):
	erase_cell(Layer.PH_MACHINE as int, pos)
	erase_cell(Layer.PH_REDSTONE1 as int, pos)
	erase_cell(Layer.PH_REDSTONE2 as int, pos)
	erase_cell(Layer.PH_REDSTONE3 as int, pos)
	erase_cell(Layer.PH_VALVE as int, pos)


func placeOverlay(pos: Vector2i):
	set_cell(Layer.OVERLAY as int, pos, 0, Vector2i.ZERO, 0)


func removeOverlay(pos: Vector2i):
	erase_cell(Layer.OVERLAY as int, pos)


func requestUpdate(delay: int, pos: Vector2i, dir: Machine.Dir):
	if pos not in world or not world[pos].isConnected(dir): return
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
	var tilePos: Vector2i = lastMousePos
	if not isTileEmpty(tilePos) and not Save.doOverwrite:
		return
	placeMachine(Save.selectedMachine, tilePos, Save.placingRotation)


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
