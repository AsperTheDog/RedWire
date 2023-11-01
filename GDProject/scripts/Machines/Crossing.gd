class_name Crossing extends Component


func _init(pos: Vector2i, rot: int) -> void:
	self.pos = pos
	self.rot = rot
	self.inputs.append(Connection.new())
	self.inputs.back().powersChanged.connect(onPowerUpdate.bind(0))
	self.inputs.append(Connection.new())
	self.inputs.back().powersChanged.connect(onPowerUpdate.bind(1))


func getConnectionID(dir: int) -> int:
	var trueRot := Side.removeRotation(dir, rot)
	return 0 if trueRot == Side.UP or trueRot == Side.DOWN else 1


func isConnectedAt(dir: int) -> bool:
	return true


func getNeighbors(from: int) -> Array[Component]:
	var neighbors: Array[Component] = [null, null, null, null]
	var dir: int = Side.opposite[Side.removeRotation(from, rot)]
	var currentTile := Game.world.getTileAt(pos + Side.vectors[dir])
	var currentSideID := currentTile.getConnectionID(Side.opposite[dir]) if currentTile != null else -1
	if currentSideID != -1:
		neighbors[dir] = currentTile
	return neighbors


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.set_cell(layer, pos, 1, Vector2i(0, 4), rot)
		World.Layer.REDSTONE1:
			Game.world.set_cell(layer, pos, 3, Vector2i(0, 4), rot * 16 + 15 - inputs[1].power)
		World.Layer.REDSTONE2:
			Game.world.set_cell(layer, pos, 3, Vector2i(1, 4), rot * 16 + 15 - inputs[0].power)


func onPowerUpdate(id :int):
	match id:
		0: Game.world.updateTextures(World.Layer.REDSTONE2, self.pos)
		1: Game.world.updateTextures(World.Layer.REDSTONE1, self.pos)


func onNeighborChanged(dir: int):
	var trueDir := Side.removeRotation(dir, rot)
	if trueDir == Side.UP or trueDir == Side.DOWN:
		Game.world.updateTextures(World.Layer.REDSTONE2, self.pos)
		for source in inputs[0].sources:
			source.requestRegen()
	else:
		Game.world.updateTextures(World.Layer.REDSTONE1, self.pos)
		for source in inputs[1].sources:
			source.requestRegen()


func getType() -> Type:
	return Type.CROSSING
