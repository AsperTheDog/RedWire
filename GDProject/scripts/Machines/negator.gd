extends Machine
class_name Negator


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)
	power = 0
	world.requestUpdate(0, pos + dirVectors[rot], opposeDir[rot])
	world.requestUpdate(0, pos - dirVectors[rot], rot)


func die():
	pass


func update(fromSelf: bool):
	var input := world.getPowerAt(pos - dirVectors[rot], rot)
	var newPow = 0 if input > 0 else 15
	if newPow != power:
		power = newPow
		world.requestUpdate(0, pos + dirVectors[rot], opposeDir[rot])
		world.updateTextures(World.Layer.REDSTONE1, pos)
		world.updateTextures(World.Layer.REDSTONE2, pos)


func getPower(dir: Dir):
	if dir != rot: return 0
	return power


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.NEGATOR


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	match layer:
		World.Layer.MACHINE:
			return World.TileInfo.new(1, Vector2i(0, 2), rot)
		World.Layer.REDSTONE1:
			return World.TileInfo.new(3, Vector2i(0, 2), rot * 16 + 15 - power)
		World.Layer.REDSTONE2:
			return World.TileInfo.new(3, Vector2i(1, 2), rot * 16 + 15 - (0 if power > 0 else 15))
	return null


func isConnected(dir: Dir) -> bool:
	if dir == Machine.Dir.ANY: return true
	if dir == Machine.Dir.UP or dir == Machine.Dir.DOWN:
		return rot == Machine.Dir.DOWN or rot == Machine.Dir.UP
	if dir == Machine.Dir.RIGHT or dir == Machine.Dir.LEFT:
		return rot == Machine.Dir.LEFT or rot == Machine.Dir.RIGHT
	return false
