extends Machine
class_name Repeater

var ticks: int = 1


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)


func isEqual(other: Machine) -> bool:
	return super.isEqual(other) and other.ticks == ticks


func update():
	pass


func getPower(dir: Dir):
	pass


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.REPEATER


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	return World.TileInfo.new()


static func getPhantomTileAtPos(world: World, layer: World.Layer, pos: Vector2i, rot: Dir) -> World.TileInfo:
	return World.TileInfo.new()
