extends Machine
class_name Crossroad

var vertPower: int = 0

func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)
	world.requestUpdate(pos + Vector2i.UP, Dir.DOWN)
	world.requestUpdate(pos + Vector2i.DOWN, Dir.UP)
	world.requestUpdate(pos + Vector2i.LEFT, Dir.RIGHT)
	world.requestUpdate(pos + Vector2i.RIGHT, Dir.LEFT)


func die():
	super.die()
	world.requestUpdate(pos + Vector2i.UP, Dir.DOWN)
	world.requestUpdate(pos + Vector2i.DOWN, Dir.UP)
	world.requestUpdate(pos + Vector2i.LEFT, Dir.RIGHT)
	world.requestUpdate(pos + Vector2i.RIGHT, Dir.LEFT)


func isEqual(other: Machine) -> bool:
	return super.isEqual(other)


func update():
	var horizPow := world.getPowerAt(pos + dirVectors[rot + Dir.UP], opposeDir[rot + Dir.UP]) - 1
	horizPow = max(horizPow, world.getPowerAt(pos + dirVectors[rot + Dir.DOWN], opposeDir[rot + Dir.DOWN]) - 1)
	var vertPow := world.getPowerAt(pos + dirVectors[rot + Dir.RIGHT], opposeDir[rot + Dir.LEFT]) - 1
	vertPow = max(vertPow, world.getPowerAt(pos + dirVectors[rot + Dir.LEFT], opposeDir[rot + Dir.RIGHT]) - 1)
	if vertPower != vertPow:
		vertPower = vertPow
		world.requestUpdate(pos + dirVectors[rot + Dir.UP], opposeDir[rot + Dir.UP])
		world.requestUpdate(pos + dirVectors[rot + Dir.DOWN], opposeDir[rot + Dir.DOWN])
	if power != horizPow:
		power = horizPow
		world.requestUpdate(pos + dirVectors[rot + Dir.RIGHT], opposeDir[rot + Dir.RIGHT])
		world.requestUpdate(pos + dirVectors[rot + Dir.LEFT], opposeDir[rot + Dir.LEFT])
	world.updateTextures(World.Layer.MACHINE, pos)
	world.updateTextures(World.Layer.REDSTONE1, pos)
	world.updateTextures(World.Layer.REDSTONE2, pos)


func getPower(dir: Dir):
	if dir == rot + Dir.DOWN or dir == rot + Dir.UP: return vertPower
	if dir == rot + Dir.LEFT or dir == rot + Dir.RIGHT: return power


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.NONE


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			world.set_cell(layer, pos, 1, Vector2i(0, 4), rot)
		World.Layer.REDSTONE1:
			world.set_cell(layer, pos, 3, Vector2i(0, 4), rot * 16 + 15 - power)
		World.Layer.REDSTONE2:
			world.set_cell(layer, pos, 3, Vector2i(1, 4), rot * 16 + 15 - vertPower)


func isConnected(dir: Dir) -> bool:
	return false
