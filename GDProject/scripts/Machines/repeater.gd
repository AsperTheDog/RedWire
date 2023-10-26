extends Machine
class_name Repeater

var ticks: int = 1
var processing: bool = false
var bufferPower: int = 0
var tickInit: int = 0


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)
	power = 0


func isEqual(other: Machine) -> bool:
	return super.isEqual(other) and other.ticks == ticks


func update(fromSelf: bool):
	if not fromSelf and processing: return
	if not processing:
		var source = world.getPowerAt(pos - dirVectors[rot], rot)
		if source == bufferPower: return
		bufferPower = 0 if source == 0 else 15
		world.requestUpdate(1, pos, Machine.Dir.ANY)
		world.updateTextures(World.Layer.REDSTONE2, pos)
		tickInit = world.tick
		processing = true
	else:
		if tickInit + ticks > world.tick: 
			world.requestUpdate(1, pos, Machine.Dir.ANY)
			return
		power = bufferPower
		processing = false
		world.requestUpdate(0, pos + dirVectors[rot], opposeDir[rot])
		world.updateTextures(World.Layer.REDSTONE1, pos)


func getPower(dir: Dir):
	return power if dir == rot else 0


func interact():
	ticks += 1
	ticks = max(1, ticks % 5)
	world.updateTextures(World.Layer.ALL, pos)


func getType() -> World.MachineType:
	return World.MachineType.REPEATER


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	match layer:
		World.Layer.MACHINE:
			return World.TileInfo.new(1, Vector2i(ticks - 1, 0), rot)
		World.Layer.REDSTONE1:
			return World.TileInfo.new(3, Vector2i(0, 0), rot * 16 + 15 - power)
		World.Layer.REDSTONE2:
			return World.TileInfo.new(3, Vector2i(1, 0), rot * 16 + 15 - bufferPower)
	return null


func isConnected(dir: Dir) -> bool:
	if dir == Machine.Dir.ANY: return true
	if dir == Machine.Dir.UP or dir == Machine.Dir.DOWN:
		return rot == Machine.Dir.DOWN or rot == Machine.Dir.UP
	if dir == Machine.Dir.RIGHT or dir == Machine.Dir.LEFT:
		return rot == Machine.Dir.LEFT or rot == Machine.Dir.RIGHT
	return false
