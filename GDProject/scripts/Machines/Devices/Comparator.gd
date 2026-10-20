class_name Comparator extends Device

var substractMode: bool = false
var processing: bool = false
var output: int = 0


func inputCount() -> int:
	return 3


func currentOutput() -> int:
	return output


# Input 0 is the one behind the comparator, 1 and 2 are the sides
func getConnectionID(dir: int) -> int:
	var side := Side.removeRotation(dir, rot)
	match side:
		Side.DOWN: return 0
		Side.RIGHT: return 1
		Side.LEFT: return 2
	return -1


func isConnectedAt(dir: int) -> bool:
	return true


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.setCell(layer, pos, 1, Vector2i(1 if substractMode else 0, 1), rot)
		World.Layer.REDSTONE1:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(0, 1), rot, inputs[0].power)
		World.Layer.REDSTONE2:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(1, 1), rot, output)
		World.Layer.REDSTONE3:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(2, 1), Side.opposite[rot], inputs[1].power)
		World.Layer.REDSTONE4:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(2, 1), rot, inputs[2].power)


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
	emitPower(output)
	Game.world.updateTextures(World.Layer.ALL, pos)
	processing = false
	onPowerUpdate(0)


func getType() -> Type:
	return Type.COMPARATOR


func isEqualToNew(type: Type):
	return getType() == type and rot == Game.placingRotation and not substractMode


func interact():
	substractMode = not substractMode
	onPowerUpdate(0)
	Game.world.updateTextures(World.Layer.MACHINE, pos)


func getMeta():
	return [substractMode]


func applyMeta(meta: Array):
	substractMode = meta[0]
