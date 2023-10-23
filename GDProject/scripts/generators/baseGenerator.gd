extends Node
class_name Generator

enum Dir {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

var pos: Vector2
var world: World
var rot: Dir


func _init(world: World, pos: Vector2, rot: Dir):
	self.world = world
	self.pos = pos
	self.rot = rot


func update():
	pass


func getLayout():
	pass


func getPower(dir: Dir):
	pass


func interact():
	pass


func getType() -> World.GenType:
	return World.GenType.NONE
