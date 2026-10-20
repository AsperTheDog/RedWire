class_name Lamp extends Component


func _init(pos: Vector2i, rot: int) -> void:
	super(pos, rot)
	addInput()


func getConnectionID(dir: int) -> int:
	return 0


func isConnectedAt(dir: int) -> bool:
	return true


func updateTileAtLayer(layer: World.Layer):
	if layer != World.Layer.MACHINE: return
	Game.world.setCell(layer, pos, 1, Vector2i(int(inputs[0].power > 0), 7), 0)


func onPowerUpdate(id :int):
	Game.world.updateTextures(World.Layer.MACHINE, pos)


func getType() -> Type:
	return Type.LAMP


func isEqualToNew(type: Type):
	return getType() == type
