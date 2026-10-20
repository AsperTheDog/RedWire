class_name Repeater extends Device

var ticks: int = 1
var processing: bool = false
var isPowered: bool = false
var output: bool = false


func currentOutput() -> int:
	return 15 if output else 0


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.setCell(layer, pos, 1, Vector2i(ticks - 1, 0), rot)
		World.Layer.REDSTONE1:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(0, 0), rot, currentOutput())
		World.Layer.REDSTONE2:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(1, 0), rot, 15 if isPowered else 0)


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
	output = isPowered
	Game.world.updateTextures(World.Layer.REDSTONE1, pos)
	emitPower(currentOutput())
	processing = false
	onPowerUpdate(0)


func getType() -> Type:
	return Type.REPEATER


func isEqualToNew(type: Type):
	return getType() == type and rot == Game.placingRotation and ticks == 1


func interact():
	ticks += 1
	ticks = max(1, ticks % 5)
	Game.world.updateTextures(World.Layer.MACHINE, pos)


func getMeta():
	return [ticks]


func applyMeta(meta: Array):
	ticks = meta[0]
