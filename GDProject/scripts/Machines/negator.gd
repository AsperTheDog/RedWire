extends Machine
class_name Negator


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)


func update(fromSelf: bool):
	pass


func getPower(dir: Dir):
	pass


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.NEGATOR


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	return World.TileInfo.new()


func isConnected(dir: Dir) -> bool:
	if dir == Machine.Dir.ANY: return true
	if dir == Machine.Dir.UP or dir == Machine.Dir.DOWN:
		return rot == Machine.Dir.DOWN or rot == Machine.Dir.UP
	if dir == Machine.Dir.RIGHT or dir == Machine.Dir.LEFT:
		return rot == Machine.Dir.LEFT or rot == Machine.Dir.RIGHT
	return false
