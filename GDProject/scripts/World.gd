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
	ALL
}

class UpdateAction:
	var tick: int
	var pos: Vector2i
	var objectType: MachineType
	
	func _init(tick: int, pos: Vector2i, type: MachineType):
		self.tick = tick
		self.pos = pos
		objectType = type

class TileInfo:
	var atlas: int = -1
	var coords: Vector2i = Vector2i.ZERO
	var altID: int = -1

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


func _physics_process(delta: float) -> void:
	tick += 1
	var count = 0
	while count < pendingActions.size():
		var action: UpdateAction = pendingActions[count]
		if action.tick == tick:
			if action.pos in world and world[action.pos].getType() == action.objectType:
				world[action.pos].update()
			pendingActions.remove_at(count)
			count -= 1
		count += 1


func addObject(type: MachineType, pos: Vector2i, rot: Machine.Dir):
	if type == MachineType.NONE or machines[type] == null:
		world.erase(pos)
		updateTextures(Layer.ALL, pos)
		return
	var newObj: Machine = machines[type].new(self, pos, rot)
	world[pos] = newObj
	requestUpdate(0, pos)
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


func requestUpdate(delay: int, pos: Vector2i):
	if pos not in world: return
	var update := UpdateAction.new(tick + delay, pos, world[pos].getType())
	pendingActions.append(update)


func getTileAt(pos: Vector2i):
	if pos not in world: return null
	return world[pos]
