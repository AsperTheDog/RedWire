class_name Comparator extends Generator

var substractMode: bool = false
var processing: bool = false
var output: int = 0


func _init(pos: Vector2i, rot: int) -> void:
	self.pos = pos
	self.rot = rot
	self.inputs.append(Connection.new())
	self.inputs.back().powersChanged.connect(onPowerUpdate.bind(0))
	self.inputs.append(Connection.new())
	self.inputs.back().powersChanged.connect(onPowerUpdate.bind(1))
	self.inputs.append(Connection.new())
	self.inputs.back().powersChanged.connect(onPowerUpdate.bind(2))
	requestRegen()


func getConnectionID(dir: int) -> int:
	var side := Side.removeRotation(dir, rot)
	match side:
		Side.DOWN: return 0
		Side.RIGHT: return 1
		Side.LEFT: return 2
	return -1


func isConnectedAt(dir: int) -> bool:
	return true


func getOutputs():
	var neighbors: Array[Component] = [null, null, null, null]
	var side := Side.rotate(Side.UP, rot)
	var currentTile := Game.world.getTileAt(pos + Side.vectors[side])
	var currentSideID := currentTile.getConnectionID(Side.opposite[side]) if currentTile != null else -1
	if currentSideID != -1: neighbors[side] = currentTile
	return neighbors


func getNeighborAt(side: int) -> Component:
	if Side.removeRotation(side, rot) != Side.DOWN and Side.removeRotation(side, rot) != Side.UP: return null
	return Game.world.getTileAt(pos + Side.vectors[side])


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.set_cell(layer, pos, 1, Vector2i(1 if substractMode else 0, 1), rot)
		World.Layer.REDSTONE1:
			Game.world.set_cell(layer, pos, 3, Vector2i(0, 1), rot * 16 + 15 - inputs[0].power)
		World.Layer.REDSTONE2:
			Game.world.set_cell(layer, pos, 3, Vector2i(1, 1), rot * 16 + 15 - output)
		World.Layer.REDSTONE3:
			Game.world.set_cell(layer, pos, 3, Vector2i(2, 1), Side.opposite[rot] * 16 + 15 - inputs[1].power)
		World.Layer.REDSTONE4:
			Game.world.set_cell(layer, pos, 3, Vector2i(2, 1), rot * 16 + 15 - inputs[2].power)


func onPowerUpdate(id :int):
	if processing: return
	var newPow: int = 0
	if substractMode:
		newPow = max(0, inputs[0].power - max(inputs[2].power, inputs[1].power))
	else:
		newPow = inputs[0].power * int(inputs[2].power <= inputs[0].power and inputs[1].power <= inputs[0].power)
	if newPow == output: 
		match id:
			0: Game.world.updateTextures(World.Layer.REDSTONE1, pos)
			1: Game.world.updateTextures(World.Layer.REDSTONE3, pos)
			2: Game.world.updateTextures(World.Layer.REDSTONE4, pos)
		return
	processing = true
	await Game.world.get_tree().physics_frame
	output = newPow
	update.emit(self, output)
	Game.world.updateTextures(World.Layer.ALL, pos)
	processing = false
	onPowerUpdate(0)


func onNeighborChanged(dir: int):
	if Side.removeRotation(dir, rot) == Side.UP:
		requestRegen()


func requestRegen():
	if requested: return
	requested = true
	regenConnections.call_deferred(output)


func getType() -> Type:
	return Type.REPEATER


func isEqual(other: Component):
	return other.getType() == getType() and other.pos == pos and other.rot == rot and other.substractMode == substractMode


func isEqualToNew(type: Type):
	return getType() == type and rot == Game.placingRotation and not substractMode


func propagateRegenRequest():
	for input in inputs:
		for source in input.sources:
			source.requestRegen()


func interact():
	substractMode = not substractMode
	onPowerUpdate(0)
	Game.world.updateTextures(World.Layer.MACHINE, pos)
