class_name Device extends Generator


func _init(pos: Vector2i, rot: int) -> void:
	super(pos, rot)
	for i in inputCount():
		addInput()


func inputCount() -> int:
	return 1


func getConnectionID(dir: int) -> int:
	return 0 if Side.removeRotation(dir, rot) == Side.DOWN else -1


func isConnectedAt(dir: int) -> bool:
	return Side.removeRotation(dir, rot) == Side.DOWN or Side.removeRotation(dir, rot) == Side.UP


func getOutputs() -> Array[Component]:
	var neighbors: Array[Component] = [null, null, null, null]
	var side := Side.rotate(Side.UP, rot)
	var currentTile := Game.world.getTileAt(pos + Side.vectors[side])
	var currentSideID := currentTile.getConnectionID(Side.opposite[side]) if currentTile != null else -1
	if currentSideID != -1: neighbors[side] = currentTile
	return neighbors


func onNeighborChanged(dir: int):
	if Side.removeRotation(dir, rot) == Side.UP:
		requestRegen()


func isEqualToNew(type: Type):
	return getType() == type and rot == Game.placingRotation


func interact():
	pass


func getMeta():
	return []


func applyMeta(meta: Array):
	pass
