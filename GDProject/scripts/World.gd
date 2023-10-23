extends TileMap
class_name World

enum GenType {
	WIRE,
	REPEATER,
	COMPARATOR,
	NEGATOR,
	GENERATOR,
	NONE
}

class UpdateAction:
	var tick: int
	var pos: Vector2
	var objectType: GenType
	
	func _init(tick: int, pos: Vector2, type: GenType):
		self.tick = tick
		self.pos = pos
		objectType = type


var layers: Dictionary = {
	"Machines": 0,
	"Redstone1": 1,
	"Redstone2": 2,
	"Redstone3": 3,
	"Valve": 4
}

var phantomLayers: Dictionary = {
	"Machines": 5,
	"Redstone1": 6,
	"Redstone2": 7,
	"Redstone3": 8,
	"Valve": 9
}

@onready var world: Dictionary
var tick: int = 0

var pendingActions: Array[UpdateAction] = []


func _ready() -> void:
	pass


func requestUpdate(delay: int, pos: Vector2):
	if pos not in world: return
	var update := UpdateAction.new(tick + delay, pos, world[pos].getType())
	pendingActions.append(update)


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
