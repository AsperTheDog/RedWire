class_name Wire extends Component

# key is UP, RIGHT, DOWN, LEFT. Encoded in binary
# value is Coords.x, Coords.y, Rotation. Stored as Vector3i
const WIRE_LAYOUT: Dictionary = {
	0b0000: Vector3i(1, 0, 0),
	0b0001: Vector3i(2, 0, 2),
	0b0010: Vector3i(2, 0, 3),
	0b0011: Vector3i(4, 0, 3),
	0b0100: Vector3i(2, 0, 0),
	0b0101: Vector3i(3, 0, 0),
	0b0110: Vector3i(4, 0, 0),
	0b0111: Vector3i(5, 0, 3),
	0b1000: Vector3i(2, 0, 1),
	0b1001: Vector3i(4, 0, 2),
	0b1010: Vector3i(3, 0, 1),
	0b1011: Vector3i(5, 0, 2),
	0b1100: Vector3i(4, 0, 1),
	0b1101: Vector3i(5, 0, 1),
	0b1110: Vector3i(5, 0, 0),
	0b1111: Vector3i(0, 0, 0)
}


func getConnectionID(dir: int) -> int:
	return 0


func isConnectedAt(dir: int) -> bool:
	return true


func registerConnection(source: Component, side: int, distance: int, currentPow: int) -> bool:
	var gen := source as Generator
	if gen.sourceId == -1: return false
	if not Game.world.powerData.addWireSource(pos, gen.sourceId, distance): return false
	gen.wireReach.append(PowerData.cellIndex(pos))
	return true


func die():
	super.die()
	Game.world.powerData.clearWireCell(pos)


func propagateRegenRequest():
	for id in Game.world.powerData.getWireSourceIds(pos):
		var source = Game.world.powerData.sourceObjects[id]
		if source != null: source.requestRegen()


func getNeighbors(from: int) -> Array[Component]:
	var neighbors: Array[Component] = [null, null, null, null]
	for side in Side.ALL:
		if side == from: continue
		var currentTile := Game.world.getTileAt(pos + Side.vectors[side])
		var currentSideID := currentTile.getConnectionID(Side.opposite[side]) if currentTile != null else -1
		if currentSideID != -1:
			neighbors[side] = currentTile
	return neighbors


func updateTileAtLayer(layer: World.Layer):
	if layer != World.Layer.REDSTONE1: return
	var code := 0
	for side in Side.ALL:
		var conn = Game.world.isTileConnectedAt(pos + Side.vectors[side], Side.opposite[side])
		if conn: code += 1 << side
	var tile: Vector3i = WIRE_LAYOUT[code]
	Game.world.setRedstoneCell(layer, pos, 2, Vector2i(tile.x, tile.y), tile.z, 0)


func onNeighborChanged(side: int):
	propagateRegenRequest()
	Game.world.updateTextures(World.Layer.REDSTONE1, pos)


func getType() -> Type:
	return Type.WIRE


func isEqualToNew(type: Type):
	return getType() == type
