class_name Negator extends Device

var processing: bool = false
var isPowered: bool = false


func currentOutput() -> int:
	return 0 if isPowered else 15


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.setCell(layer, pos, 1, Vector2i(0, 2), rot)
		World.Layer.REDSTONE1:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(1, 2), rot, 15 if isPowered else 0)
		World.Layer.REDSTONE2:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(0, 2), rot, currentOutput())


func onPowerUpdate(id :int):
	if inputs[0].power > 0 == isPowered: return
	if processing: return
	processing = true
	isPowered = inputs[0].power > 0
	Game.world.updateTextures(World.Layer.REDSTONE1, pos)
	await Game.world.get_tree().physics_frame
	Game.world.updateTextures(World.Layer.REDSTONE2, pos)
	emitPower(currentOutput())
	processing = false
	onPowerUpdate(0)


func getType() -> Type:
	return Type.NEGATOR
