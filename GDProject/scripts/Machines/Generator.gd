class_name Generator extends Component


class CircuitNode:
	var elem: Component
	var side: int
	var distance: int

	func _init(comp: Component, side: int, distance: int):
		self.elem = comp
		self.side = side
		self.distance = distance


var sourceId: int = -1
var wireReach: PackedInt32Array = PackedInt32Array()
var requested: bool = false
var dead: bool = false
var savedActive: bool = false

var activated: bool = false:
	set(value):
		if activated == value: return
		activated = value
		emitPower(currentOutput())
		Game.world.updateTextures(World.Layer.MACHINE, pos)
		Game.world.updateTextures(World.Layer.REDSTONE1, pos)


func _init(pos: Vector2i, rot: int):
	super(pos, rot)
	requestRegen()


func die():
	dead = true
	deleted.emit(self)
	clearWireEntries()
	if sourceId != -1:
		Game.world.powerData.freeSource(sourceId)
		sourceId = -1


func currentOutput() -> int:
	return 15 if activated else 0


func emitPower(power: int) -> void:
	if dead: return
	if sourceId != -1:
		Game.world.powerData.setSourcePower(sourceId, power)
	update.emit(self, power)


func clearWireEntries() -> void:
	for cell in wireReach:
		Game.world.powerData.removeWireSource(cell, sourceId)
	wireReach.clear()


func getType() -> Type:
	return Type.GENERATOR


func isEqualToNew(type: Type):
	return getType() == type and not activated


func isConnectedAt(dir: int) -> bool:
	return true


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.setCell(layer, pos, 1, Vector2i(1 if activated else 0, 3), 0)
		World.Layer.REDSTONE1:
			Game.world.setRedstoneCell(layer, pos, 3, Vector2i(0, 3), 0, currentOutput())


func interact():
	activated = not activated


func onNeighborChanged(dir: int):
	requestRegen()


func requestRegen():
	if requested: return
	requested = true
	regenConnections.call_deferred(currentOutput())


func regenConnections(currentPower: int):
	if dead:
		requested = false
		return
	deleted.emit(self)
	clearWireEntries()
	if sourceId == -1:
		sourceId = Game.world.powerData.allocSource(self)
	if sourceId != -1:
		Game.world.powerData.setSourcePower(sourceId, currentPower)
	var nodesToExplore: Array[CircuitNode] = []
	var neighbors := getOutputs()
	for side in neighbors.size():
		if neighbors[side] != null:
			nodesToExplore.append(CircuitNode.new(neighbors[side], Side.opposite[side], 1))
	while not nodesToExplore.is_empty():
		var nextNode: CircuitNode = nodesToExplore.pop_front()
		if not nextNode.elem.registerConnection(self, nextNode.side, nextNode.distance, currentPower):
			continue
		if nextNode.distance == 14: continue
		neighbors = nextNode.elem.getNeighbors(nextNode.side)
		for side in neighbors.size():
			if neighbors[side] != null:
				nodesToExplore.append(CircuitNode.new(neighbors[side], Side.opposite[side], nextNode.distance + 1))
	requested = false


func getOutputs() -> Array[Component]:
	var neighbors: Array[Component] = [null, null, null, null]
	for side in Side.ALL:
		var currentTile := Game.world.getTileAt(pos + Side.vectors[side])
		var currentSideID := currentTile.getConnectionID(Side.opposite[side]) if currentTile != null else -1
		if currentSideID != -1:
			neighbors[side] = currentTile
	return neighbors


func getMeta():
	return [activated]


func applyMeta(meta: Array):
	savedActive = meta[0]


func start():
	activated = savedActive


func discard():
	dead = true
	sourceId = -1
	wireReach.clear()
