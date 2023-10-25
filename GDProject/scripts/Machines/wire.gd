extends Machine
class_name Wire


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)


func isEqual(other: Machine) -> bool:
	return other.getType() == getType() and other.pos == pos


func update():
	var neighPow := 0
	neighPow = max(neighPow, world.getPowerAt(pos + Vector2i.UP, Dir.DOWN) - 1)
	neighPow = max(neighPow, world.getPowerAt(pos + Vector2i.DOWN, Dir.UP) - 1)
	neighPow = max(neighPow, world.getPowerAt(pos + Vector2i.RIGHT, Dir.LEFT) - 1)
	neighPow = max(neighPow, world.getPowerAt(pos + Vector2i.LEFT, Dir.RIGHT) - 1)
	if power != neighPow:
		world.updateTextures(World.Layer.REDSTONE1, pos)
		world.requestUpdate(0, pos + Vector2i.UP)
		world.requestUpdate(0, pos + Vector2i.DOWN)
		world.requestUpdate(0, pos + Vector2i.LEFT)
		world.requestUpdate(0, pos + Vector2i.RIGHT)
	power = neighPow


func getPower(dir: Dir):
	return power


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.WIRE


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	if layer != World.Layer.REDSTONE1: return null
	var tile: World.TileInfo = World.TileInfo.new()
	tile.atlas = 2
	tile.coords = Vector2i(1, 0)
	tile.altID = 0
	return tile


static func getPhantomTileAtPos(world: World, layer: World.Layer, pos: Vector2i, rot: Dir) -> World.TileInfo:
	return World.TileInfo.new()
