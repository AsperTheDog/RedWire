extends Machine
class_name Comparator


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)


func update():
	pass


func getLayout():
	pass


func getPower(dir: Dir):
	pass


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.COMPARATOR


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	return World.TileInfo.new()