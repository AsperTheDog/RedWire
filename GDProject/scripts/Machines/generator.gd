extends Machine
class_name Generator

var activated: bool = false


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)


func die():
	world.requestUpdate(pos + Vector2i.UP, Machine.Dir.DOWN)
	world.requestUpdate(pos + Vector2i.RIGHT, Machine.Dir.LEFT)
	world.requestUpdate(pos + Vector2i.DOWN, Machine.Dir.UP)
	world.requestUpdate(pos + Vector2i.LEFT, Machine.Dir.RIGHT)


func isEqual(other: Machine) -> bool:
	return super.isEqual(other) and other.activated == activated


func update():
	var newPow = 15 if activated else 0
	if newPow == power: return
	power = newPow
	world.requestUpdate(pos + Vector2i.UP, Machine.Dir.DOWN)
	world.requestUpdate(pos + Vector2i.RIGHT, Machine.Dir.LEFT)
	world.requestUpdate(pos + Vector2i.DOWN, Machine.Dir.UP)
	world.requestUpdate(pos + Vector2i.LEFT, Machine.Dir.RIGHT)
	world.updateTextures(World.Layer.ALL, pos)


func getPower(dir: Dir):
	return 15 if activated else 0


func interact():
	activated = not activated
	update()


func getType() -> World.MachineType:
	return World.MachineType.GENERATOR


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			world.set_cell(layer, pos, 1, Vector2i(1 if activated else 0, 3), 0)
		World.Layer.REDSTONE1:
			world.set_cell(layer, pos, 3, Vector2i(0, 3), 0 + 15 - power)


func isConnected(dir: Dir) -> bool:
	return true
