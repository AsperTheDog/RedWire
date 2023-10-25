extends Machine
class_name Generator

var activated: bool = false


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)


func isEqual(other: Machine) -> bool:
	return super.isEqual(other) and other.activated == activated


func update():
	pass


func getPower(dir: Dir):
	return 15 if activated else 0


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.GENERATOR


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	return World.TileInfo.new()


static func getPhantomTileAtPos(world: World, layer: World.Layer, pos: Vector2i, rot: Dir) -> World.TileInfo:
	return World.TileInfo.new()
