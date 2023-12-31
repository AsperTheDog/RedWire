class_name Repeater extends Generator

var ticks: int = 1
var processing: bool = false
var isPowered: bool = false
var output: bool = false


func _init(pos: Vector2i, rot: int) -> void:
	self.pos = pos
	self.rot = rot
	self.inputs.append(Connection.new())
	self.inputs.back().powersChanged.connect(onPowerUpdate.bind(0))
	requestRegen()


func getConnectionID(dir: int) -> int:
	return 0 if Side.removeRotation(dir, rot) == Side.DOWN else -1


func isConnectedAt(dir: int) -> bool:
	return Side.removeRotation(dir, rot) == Side.DOWN or Side.removeRotation(dir, rot) == Side.UP


func getOutputs():
	var neighbors: Array[Component] = [null, null, null, null]
	var side := Side.rotate(Side.UP, rot)
	var currentTile := Game.world.getTileAt(pos + Side.vectors[side])
	var currentSideID := currentTile.getConnectionID(Side.opposite[side]) if currentTile != null else -1
	if currentSideID != -1: neighbors[side] = currentTile
	return neighbors


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.set_cell(layer, pos, 1, Vector2i(ticks - 1, 0), rot)
		World.Layer.REDSTONE1:
			Game.world.set_cell(layer, pos, 3, Vector2i(0, 0), rot * 16 + 15 - (15 if output else 0))
		World.Layer.REDSTONE2:
			Game.world.set_cell(layer, pos, 3, Vector2i(1, 0), rot * 16 + 15 - (15 if isPowered else 0))


func onPowerUpdate(id :int):
	if inputs[0].power > 0 == isPowered: return
	if processing: return
	processing = true
	isPowered = inputs[0].power > 0
	Game.world.updateTextures(World.Layer.REDSTONE2, pos)
	var count = 0
	while count < ticks:
		await Game.world.get_tree().physics_frame
		count += 1
	output = 15 if isPowered else 0
	Game.world.updateTextures(World.Layer.REDSTONE1, pos)
	update.emit(self, 15 if output else 0)
	processing = false
	onPowerUpdate(0)


func onNeighborChanged(dir: int):
	if Side.removeRotation(dir, rot) == Side.UP:
		requestRegen()


func requestRegen():
	if requested: return
	requested = true
	regenConnections.call_deferred(15 if output else 0)


func getType() -> Type:
	return Type.REPEATER


func isEqual(other: Component):
	return other.getType() == getType() and other.pos == pos and other.rot == rot and other.ticks == ticks


func isEqualToNew(type: Type):
	return getType() == type and rot == Game.placingRotation and ticks == 1


func propagateRegenRequest():
	for input in inputs:
		for source in input.sources:
			source.requestRegen()


func interact():
	ticks += 1
	ticks = max(1, ticks % 5)
	Game.world.updateTextures(World.Layer.MACHINE, pos)


func getMeta():
	return [ticks]


func applyMeta(meta: Array):
	ticks = meta[0]
