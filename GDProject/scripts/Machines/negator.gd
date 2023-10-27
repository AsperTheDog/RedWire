extends Machine
class_name Negator


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)
	world.requestUpdate(pos + dirVectors[rot], opposeDir[rot])
	world.requestUpdate(pos - dirVectors[rot], rot)


func die():
	super.die()


func update():
	await world.get_tree().physics_frame
	var input := world.getPowerAt(pos - dirVectors[rot], rot)
	var newPow = 0 if input > 0 else 15
	if newPow != power:
		power = newPow
		world.requestUpdate(pos + dirVectors[rot], opposeDir[rot])
		world.updateTextures(World.Layer.REDSTONE1, pos)
		world.updateTextures(World.Layer.REDSTONE2, pos)


func getPower(dir: Dir):
	if dir != rot: return 0
	return power


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.NEGATOR


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			world.set_cell(layer, pos, 1, Vector2i(0, 2), rot)
		World.Layer.REDSTONE1:
			world.set_cell(layer, pos, 3, Vector2i(0, 2), rot * 16 + 15 - power)
		World.Layer.REDSTONE2:
			world.set_cell(layer, pos, 3, Vector2i(1, 2), rot * 16 + 15 - (0 if power > 0 else 15))


func isConnected(dir: Dir) -> bool:
	if dir == Machine.Dir.ANY: return true
	if dir == Machine.Dir.UP or dir == Machine.Dir.DOWN:
		return rot == Machine.Dir.DOWN or rot == Machine.Dir.UP
	if dir == Machine.Dir.RIGHT or dir == Machine.Dir.LEFT:
		return rot == Machine.Dir.LEFT or rot == Machine.Dir.RIGHT
	return false
