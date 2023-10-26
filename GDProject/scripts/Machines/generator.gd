extends Machine
class_name Generator

var activated: bool = false


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)


func isEqual(other: Machine) -> bool:
	return super.isEqual(other) and other.activated == activated


func update(fromSelf: bool):
	if not fromSelf: return
	power = 15 if activated else 0
	world.requestUpdate(0, pos + Vector2i.UP, Machine.Dir.DOWN)
	world.requestUpdate(0, pos + Vector2i.RIGHT, Machine.Dir.LEFT)
	world.requestUpdate(0, pos + Vector2i.DOWN, Machine.Dir.UP)
	world.requestUpdate(0, pos + Vector2i.LEFT, Machine.Dir.RIGHT)
	world.updateTextures(World.Layer.ALL, pos)


func getPower(dir: Dir):
	return 15 if activated else 0


func interact():
	activated = not activated
	update(true)


func getType() -> World.MachineType:
	return World.MachineType.GENERATOR


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	match layer:
		World.Layer.MACHINE:
			return World.TileInfo.new(1, Vector2i(1 if activated else 0, 3), 0)
		World.Layer.REDSTONE1:
			return World.TileInfo.new(3, Vector2i(0, 3), 0 + 15 - power)
	return null


func isConnected(dir: Dir) -> bool:
	return true
