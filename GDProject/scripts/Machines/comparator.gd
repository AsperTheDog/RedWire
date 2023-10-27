extends Machine
class_name Comparator

var substractMode: bool = false


func _init(world: World, pos: Vector2i, rot: Dir):
	super._init(world, pos, rot)
	world.requestUpdate(pos + Vector2i.UP, Machine.Dir.DOWN)
	world.requestUpdate(pos + Vector2i.RIGHT, Machine.Dir.LEFT)
	world.requestUpdate(pos + Vector2i.DOWN, Machine.Dir.UP)
	world.requestUpdate(pos + Vector2i.LEFT, Machine.Dir.RIGHT)


func die():
	world.requestUpdate(pos + Vector2i.UP, Machine.Dir.DOWN)
	world.requestUpdate(pos + Vector2i.RIGHT, Machine.Dir.LEFT)
	world.requestUpdate(pos + Vector2i.DOWN, Machine.Dir.UP)
	world.requestUpdate(pos + Vector2i.LEFT, Machine.Dir.RIGHT)


func isEqual(other: Machine) -> bool:
	return super.isEqual(other) and other.substractMode == substractMode


var awaiting: bool = false
func update():
	if awaiting: return
	awaiting = true
	await world.get_tree().physics_frame
	awaiting = false
	var right := (rot + 1) % Machine.Dir.ANY
	var powerRight := world.getPowerAt(pos + dirVectors[right], opposeDir[right])
	var left := (rot + 3) % Machine.Dir.ANY
	var powerLeft := world.getPowerAt(pos + dirVectors[left], opposeDir[left])
	var input := world.getPowerAt(pos - dirVectors[rot], rot)
	if substractMode:
		power = max(0, input - max(powerLeft, powerRight))
	else:
		power = input * int(powerLeft <= input and powerRight <= input)
	world.requestUpdate(pos + dirVectors[rot], opposeDir[rot])
	world.updateTextures(World.Layer.ALL, pos)


func getPower(dir: Dir):
	if dir != rot: return 0
	return power


func interact():
	substractMode = not substractMode
	world.requestUpdate(pos, Machine.Dir.ANY)


func getType() -> World.MachineType:
	return World.MachineType.COMPARATOR


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			world.set_cell(layer, pos, 1, Vector2i(1 if substractMode else 0, 1), rot)
		World.Layer.REDSTONE1:
			var input := world.getPowerAt(pos - dirVectors[rot], rot)
			world.set_cell(layer, pos, 3, Vector2i(0, 1), rot * 16 + 15 - input)
		World.Layer.REDSTONE2:
			world.set_cell(layer, pos, 3, Vector2i(1, 1), rot * 16 + 15 - power)
		World.Layer.REDSTONE3:
			var right := (rot + 1) % Machine.Dir.ANY
			var powerRight := world.getPowerAt(pos + dirVectors[right], opposeDir[right])
			world.set_cell(layer, pos, 3, Vector2i(2, 1), opposeDir[rot] * 16 + 15 - powerRight)
		World.Layer.REDSTONE4:
			var left := (rot + 3) % Machine.Dir.ANY
			var powerLeft := world.getPowerAt(pos + dirVectors[left], opposeDir[left])
			world.set_cell(layer, pos, 3, Vector2i(2, 1), rot * 16 + 15 - powerLeft)


func isConnected(dir: Dir) -> bool:
	return true
