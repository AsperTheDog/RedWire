extends Machine
class_name Wire

# key is UP, RIGHT, DOWN, LEFT. Encoded in binary
# value is Coords.x, Coords.y, AltID. Stored as Vector3i
# gradient is (AltID + 15) - power
var wireLayout: Dictionary = {
	0b0000: Vector3i(1, 0, 0),
	0b0001: Vector3i(2, 0, 16),
	0b0010: Vector3i(2, 0, 0),
	0b0011: Vector3i(4, 0, 16),
	0b0100: Vector3i(2, 0, 48),
	0b0101: Vector3i(3, 0, 16),
	0b0110: Vector3i(4, 0, 0),
	0b0111: Vector3i(5, 0, 0),
	0b1000: Vector3i(2, 0, 32),
	0b1001: Vector3i(4, 0, 32),
	0b1010: Vector3i(3, 0, 0),
	0b1011: Vector3i(5, 0, 16),
	0b1100: Vector3i(4, 0, 48),
	0b1101: Vector3i(5, 0, 32),
	0b1110: Vector3i(5, 0, 48),
	0b1111: Vector3i(0, 0, 0),
}


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)


func isEqual(other: Machine) -> bool:
	return other.getType() == getType() and other.pos == pos


func update(fromSelf: bool):
	var neighPow := 0
	neighPow = max(neighPow, world.getPowerAt(pos + Vector2i.UP, Dir.DOWN) - 1)
	neighPow = max(neighPow, world.getPowerAt(pos + Vector2i.DOWN, Dir.UP) - 1)
	neighPow = max(neighPow, world.getPowerAt(pos + Vector2i.RIGHT, Dir.LEFT) - 1)
	neighPow = max(neighPow, world.getPowerAt(pos + Vector2i.LEFT, Dir.RIGHT) - 1)
	if power != neighPow:
		world.requestUpdate(0, pos + Vector2i.UP, Dir.DOWN)
		world.requestUpdate(0, pos + Vector2i.DOWN, Dir.UP)
		world.requestUpdate(0, pos + Vector2i.LEFT, Dir.RIGHT)
		world.requestUpdate(0, pos + Vector2i.RIGHT, Dir.LEFT)
	power = neighPow
	world.updateTextures(World.Layer.REDSTONE1, pos)


func getPower(dir: Dir):
	return power


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.WIRE


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	if layer != World.Layer.REDSTONE1: return null
	var tile: World.TileInfo = World.TileInfo.new()
	var connUp = world.isConnectedAt(pos + Vector2i.UP, Machine.Dir.DOWN)
	var connRight = world.isConnectedAt(pos + Vector2i.RIGHT, Machine.Dir.LEFT)
	var connDown = world.isConnectedAt(pos + Vector2i.DOWN, Machine.Dir.UP)
	var connLeft = world.isConnectedAt(pos + Vector2i.LEFT, Machine.Dir.RIGHT)
	var code := (int(connLeft) + (int(connDown) << 1) + (int(connRight) << 2) + (int(connUp) << 3))
	var tilePos = wireLayout[code]
	tile.atlas = 2
	tile.coords = Vector2i(tilePos.x, tilePos.y)
	tile.altID = tilePos.z + 15 - power
	return tile


func isConnected(dir: Dir) -> bool:
	return true
