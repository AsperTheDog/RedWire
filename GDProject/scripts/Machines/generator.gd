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
	deleted.emit()


func getType() -> Type:
	return Type.NONE


func isEqual(other: Component):
	return other.getType() == getType() and other.pos == pos and other.activated == activated


func isEqualToNew():
	return not activated


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
	regenConnections()


var requested: bool = false
func requestRegen():
	if requested: return
	requested = true
	regenConnections.call_deferred()


func regenConnections():
	requested = false
	resetting.emit(self)
	var exploredNodes: Array[Vector2i] = []
	var nodesToExplore: Array[CircuitNode] = []
	var neighbors := getNeighbors()
	for side in neighbors.size():
		if neighbors[side] != null: 
			nodesToExplore.append(CircuitNode.new(neighbors[side], side, 1))
			exploredNodes.append(neighbors[side].pos)
	while not nodesToExplore.is_empty():
		var nextNode: CircuitNode = nodesToExplore.pop_front()
		nextNode.elem.registerConnection(self, nextNode.side, nextNode.distance, 15 if activated else 0)
		if nextNode.distance == 15: continue
		neighbors = nextNode.elem.getNeighbors()
		for side in neighbors.size():
			if neighbors[side] != null and not neighbors[side].pos in exploredNodes:
				nodesToExplore.append(CircuitNode.new(neighbors[side], side, nextNode.distance + 1))
				exploredNodes.append(neighbors[side].pos)


func getNeighbors() -> Array[Component]:
	var neighbors: Array[Component] = [null, null, null, null]
	for side in Side.ALL:
		var currentTile = Game.world.getTileAt(pos + Side.vectors[side])
		var currentSideID = currentTile.getConnectionID(Side.opposite[side]) if currentTile != null else -1
		if currentSideID != -1: 
			neighbors[side] = currentTile
	return neighbors


