extends Machine
class_name Comparator

var substractMode: bool = false


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)
	world.requestUpdate(0, pos + Vector2i.UP, Machine.Dir.DOWN)
	world.requestUpdate(0, pos + Vector2i.RIGHT, Machine.Dir.LEFT)
	world.requestUpdate(0, pos + Vector2i.DOWN, Machine.Dir.UP)
	world.requestUpdate(0, pos + Vector2i.LEFT, Machine.Dir.RIGHT)


func die():
	world.requestUpdate(0, pos + Vector2i.UP, Machine.Dir.DOWN)
	world.requestUpdate(0, pos + Vector2i.RIGHT, Machine.Dir.LEFT)
	world.requestUpdate(0, pos + Vector2i.DOWN, Machine.Dir.UP)
	world.requestUpdate(0, pos + Vector2i.LEFT, Machine.Dir.RIGHT)


func isEqual(other: Machine) -> bool:
	return super.isEqual(other) and other.substractMode == substractMode


func update(fromSelf: bool):
	var right := (rot + 1) % Machine.Dir.ANY
	var powerRight := world.getPowerAt(pos + dirVectors[right], opposeDir[right])
	var left := (rot + 3) % Machine.Dir.ANY
	var powerLeft := world.getPowerAt(pos + dirVectors[left], opposeDir[left])
	var input := world.getPowerAt(pos - dirVectors[rot], rot)
	if substractMode:
		power = max(0, input - max(powerLeft, powerRight))
	else:
		power = input * int(powerLeft <= input and powerRight <= input)
	world.requestUpdate(0, pos + dirVectors[rot], opposeDir[rot])
	world.updateTextures(World.Layer.ALL, pos)


func getPower(dir: Dir):
	if dir != rot: return 0
	return power


func interact():
	substractMode = not substractMode
	world.requestUpdate(0, pos, Machine.Dir.ANY)


func getType() -> World.MachineType:
	return World.MachineType.COMPARATOR


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	match layer:
		World.Layer.MACHINE:
			return World.TileInfo.new(1, Vector2i(1 if substractMode else 0, 1), rot)
		World.Layer.REDSTONE1:
			var input := world.getPowerAt(pos - dirVectors[rot], rot)
			return World.TileInfo.new(3, Vector2i(0, 1), rot * 16 + 15 - input)
		World.Layer.REDSTONE2:
			return World.TileInfo.new(3, Vector2i(1, 1), rot * 16 + 15 - power)
		World.Layer.REDSTONE3:
			var right := (rot + 1) % Machine.Dir.ANY
			var powerRight := world.getPowerAt(pos + dirVectors[right], opposeDir[right])
			return World.TileInfo.new(3, Vector2i(2, 1), opposeDir[rot] * 16 + 15 - powerRight)
		World.Layer.REDSTONE4:
			var left := (rot + 3) % Machine.Dir.ANY
			var powerLeft := world.getPowerAt(pos + dirVectors[left], opposeDir[left])
			return World.TileInfo.new(3, Vector2i(2, 1), rot * 16 + 15 - powerLeft)
	return null


func isConnected(dir: Dir) -> bool:
	return true
