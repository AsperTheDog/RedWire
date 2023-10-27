extends Machine
class_name Repeater

var ticks: int = 1
var processing: bool = false
var bufferPower: int = 0
var tickInit: int = 0


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)
	world.requestUpdate(pos + dirVectors[rot], opposeDir[rot])
	world.requestUpdate(pos - dirVectors[rot], rot)


func die():
	super.die()
	world.requestUpdate(pos + dirVectors[rot], opposeDir[rot])
	world.requestUpdate(pos - dirVectors[rot], rot)


func isEqual(other: Machine) -> bool:
	return super.isEqual(other) and other.ticks == ticks


func update():
	
	if not processing:
		var source = world.getPowerAt(pos - dirVectors[rot], rot)
		if (0 if source == 0 else 15) == bufferPower: 
			world.updateTextures(World.Layer.REDSTONE2, pos)
			return
		processing = true
		bufferPower = 0 if source == 0 else 15
		world.updateTextures(World.Layer.REDSTONE2, pos)
		var count := 0
		while count < ticks:
			await world.get_tree().physics_frame
			count += 1
		processing = false
		power = bufferPower
		world.requestUpdate(pos + dirVectors[rot], opposeDir[rot])
		world.updateTextures(World.Layer.REDSTONE1, pos)
		world.requestUpdate(pos, Machine.Dir.ANY, 1)
#	if not fromSelf and processing and world.tick != tickInit: return
#	if not processing or world.tick == tickInit:
#		var source = world.getPowerAt(pos - dirVectors[rot], rot)
#		if (0 if source == 0 else 15) == bufferPower: 
#			world.updateTextures(World.Layer.REDSTONE2, pos)
#			return
#		bufferPower = 0 if source == 0 else 15
#		if world.tick == tickInit and processing: return
#		world.updateTextures(World.Layer.REDSTONE2, pos)
#		tickInit = world.tick
#		processing = true
#		world.requestUpdate(pos, Machine.Dir.ANY, 1)
#	else:
#		if tickInit + ticks > world.tick: 
#			world.requestUpdate(pos, Machine.Dir.ANY, 1)
#			return
#		power = bufferPower
#		processing = false
#		world.requestUpdate(pos + dirVectors[rot], opposeDir[rot])
#		world.updateTextures(World.Layer.REDSTONE1, pos)
#		world.requestUpdate(pos, Machine.Dir.ANY, 1)


func getPower(dir: Dir):
	return power if dir == rot else 0


func interact():
	ticks += 1
	ticks = max(1, ticks % 5)
	world.updateTextures(World.Layer.ALL, pos)


func getType() -> World.MachineType:
	return World.MachineType.REPEATER


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			world.set_cell(layer, pos, 1, Vector2i(ticks - 1, 0), rot)
		World.Layer.REDSTONE1:
			world.set_cell(layer, pos, 3, Vector2i(0, 0), rot * 16 + 15 - power)
		World.Layer.REDSTONE2:
			world.set_cell(layer, pos, 3, Vector2i(1, 0), rot * 16 + 15 - bufferPower)


func isConnected(dir: Dir) -> bool:
	if dir == Machine.Dir.ANY: return true
	if dir == Machine.Dir.UP or dir == Machine.Dir.DOWN:
		return rot == Machine.Dir.DOWN or rot == Machine.Dir.UP
	if dir == Machine.Dir.RIGHT or dir == Machine.Dir.LEFT:
		return rot == Machine.Dir.LEFT or rot == Machine.Dir.RIGHT
	return false
