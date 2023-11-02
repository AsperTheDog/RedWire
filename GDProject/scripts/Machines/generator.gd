class_name Generator extends Component


class CircuitNode:
	var elem: Component
	var side: int
	var distance: int
	
	func _init(comp: Component, side: int, distance: int):
		self.elem = comp
		self.side = side
		self.distance = distance


var activated: bool = false:
	set(value):
		if activated == value: return
		activated = value
		update.emit(self, 15 if activated else 0)
		Game.world.updateTextures(World.Layer.MACHINE, pos)
		Game.world.updateTextures(World.Layer.REDSTONE1, pos)


func _init(pos: Vector2i, rot: int):
	self.pos = pos
	self.rot = rot
	requestRegen()


func die():
	deleted.emit(self)


func getType() -> Type:
	return Type.GENERATOR


func isEqual(other: Component):
	return other.getType() == getType() and other.pos == pos and other.activated == activated


func isEqualToNew(type: Type):
	return getType() == type and not activated


func isConnectedAt(dir: int) -> bool:
	return true


func updateTileAtLayer(layer: World.Layer):
	match layer:
		World.Layer.MACHINE:
			Game.world.set_cell(layer, pos, 1, Vector2i(1 if activated else 0, 3), 0)
		World.Layer.REDSTONE1:
			Game.world.set_cell(layer, pos, 3, Vector2i(0, 3), 0 + 15 - (15 if activated else 0))


func interact():
	activated = not activated


func onNeighborChanged(dir: int):
	requestRegen()


var requested: bool = false
func requestRegen():
	if requested: return
	requested = true
	regenConnections.call_deferred(15 if activated else 0)


func regenConnections(currentPower: int):
	deleted.emit(self)
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
	activated = meta[0]
