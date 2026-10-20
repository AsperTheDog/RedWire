class_name Flicker extends Device

var output: bool = false
var lastInput: int = 0
var processing: bool = false


func currentOutput() -> int:
	return 15 if output else 0


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.setCell(layer, pos, 1, Vector2i(0, 5), rot)
		World.Layer.REDSTONE1:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(1, 5), rot, currentOutput())
		World.Layer.REDSTONE2:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(0, 5), rot, lastInput)


func onPowerUpdate(id :int):
	if inputs[0].power == lastInput: return
	if processing: return
	processing = true
	lastInput = inputs[0].power
	Game.world.updateTextures(World.Layer.REDSTONE2, pos)
	await Game.world.get_tree().physics_frame
	output = true
	emitPower(currentOutput())
	Game.world.updateTextures(World.Layer.REDSTONE1, pos)
	await Game.world.get_tree().physics_frame
	output = false
	emitPower(currentOutput())
	Game.world.updateTextures(World.Layer.REDSTONE1, pos)
	processing = false


func getType() -> Type:
	return Type.FLICKER
