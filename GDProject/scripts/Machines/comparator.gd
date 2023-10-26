extends Machine
class_name Comparator

var substractMode: bool = false


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)


func isEqual(other: Machine) -> bool:
	return super.isEqual(other) and other.substractMode == substractMode


func update(fromSelf: bool):
	pass


func getPower(dir: Dir):
	pass


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.COMPARATOR


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	return World.TileInfo.new()


func isConnected(dir: Dir) -> bool:
	return true
