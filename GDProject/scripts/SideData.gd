extends Node


const UP := 0
const RIGHT := 1
const DOWN := 2
const LEFT := 3
const ALL := 4

var opposite : Dictionary = {
	UP: DOWN, 
	RIGHT: LEFT, 
	DOWN: UP, 
	LEFT: RIGHT
}

var vectors: Dictionary = {
	UP: Vector2i.UP, 
	RIGHT: Vector2i.RIGHT, 
	DOWN: Vector2i.DOWN, 
	LEFT: Vector2i.LEFT
}


func removeRotation(side: int, offset: int) -> int:
	return ((side - offset) + Side.ALL) % Side.ALL


func rotate(side: int, rot: int) -> int:
	return (side + rot) % Side.ALL
