class_name Lamp extends Component



func _init(pos: Vector2i, rot: int) -> void:
	self.pos = pos
	self.rot = rot
	self.inputs.append(Connection.new())
	self.inputs.back().powersChanged.connect(onPowerUpdate.bind(0))


func getConnectionID(dir: int) -> int:
	return 0


func isConnectedAt(dir: int) -> bool:
	return true


func updateTileAtLayer(layer: World.Layer):
	if layer != World.Layer.MACHINE: return
	Game.world.set_cell(layer, pos, 1, Vector2i(int(inputs[0].power > 0), 7), 0)


func onPowerUpdate(id :int):
	Game.world.updateTextures(World.Layer.MACHINE, self.pos)


func getType() -> Type:
	return Type.LAMP


func isEqual(other: Component):
	return other.getType() == getType() and other.pos == pos


func isEqualToNew(type: Type):
	return getType() == type
