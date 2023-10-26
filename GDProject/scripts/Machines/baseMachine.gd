extends Node
class_name Machine

enum Dir {
	UP,
	RIGHT,
	DOWN,
	LEFT,
	ANY
}


var opposeDir := {
	Dir.UP: Dir.DOWN,
	Dir.RIGHT: Dir.LEFT,
	Dir.DOWN: Dir.UP,
	Dir.LEFT: Dir.RIGHT,
	Dir.ANY: Dir.ANY
}
var dirVectors := {
	Dir.UP: Vector2i.UP,
	Dir.RIGHT: Vector2i.RIGHT,
	Dir.DOWN: Vector2i.DOWN,
	Dir.LEFT: Vector2i.LEFT,
	Dir.ANY: Vector2i.ZERO
}

var pos: Vector2i
var world: World
var rot: Dir
var power: int = -1


func _init(world: World, pos: Vector2i, rot: Dir):
	self.world = world
	self.pos = pos
	self.rot = rot


func isEqual(other: Machine) -> bool:
	return other.getType() == getType() and other.pos == pos and other.rot == rot


func update(fromSelf: bool):
	pass


func getPower(dir: Dir):
	pass


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.NONE


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	return World.TileInfo.new()


func isConnected(dir: Dir) -> bool:
	return false
