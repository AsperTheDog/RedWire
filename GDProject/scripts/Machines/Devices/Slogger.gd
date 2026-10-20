class_name Slogger extends Device

var output: bool = false
var lastInput: bool = false
var processing: bool = false


func currentOutput() -> int:
	return 15 if output else 0


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.setCell(layer, pos, 1, Vector2i(0, 6), rot)
		World.Layer.REDSTONE1:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(1, 6), rot, currentOutput())
		World.Layer.REDSTONE2:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(0, 6), rot, inputs[0].power)


func onPowerUpdate(id :int):
	if inputs[0].power > 0 == lastInput: return
	if processing: return
	processing = true
	if not (inputs[0].power > 0 and not lastInput):
		lastInput = inputs[0].power > 0
		Game.world.updateTextures(World.Layer.REDSTONE2, pos)
		processing = false
		return
	lastInput = inputs[0].power > 0
	Game.world.updateTextures(World.Layer.REDSTONE2, pos)
	await Game.world.get_tree().physics_frame
	output = not output
	emitPower(currentOutput())
	Game.world.updateTextures(World.Layer.REDSTONE1, pos)
	processing = false


func getType() -> Type:
	return Type.SLOGGER
