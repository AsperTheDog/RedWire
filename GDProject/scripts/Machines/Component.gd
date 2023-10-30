class_name Component extends Object

enum Type {
	NONE,
	WIRE,
	CROSSING,
	GENERATOR,
	REPEATER,
	NEGATOR,
	COMPARATOR,
	FLICKER,
	SLOGGER
}

signal update(comp: Component, power: int)
signal resetting(comp: Component)
signal deleted


class Connection:
	signal powersChanged

	var power: int = 0
	var sources: Dictionary = {}
	var maxSource: Component = null
	
	func resetSources() -> void:
		for source in sources:
			source.update.disconnect(sourceUpdate)
			source.resetting.disconnect(deleteSource)
		sources.clear()

	func deleteSource(source: Component) -> void:
		if source not in sources: return
		source.update.disconnect(sourceUpdate)
		source.resetting.disconnect(deleteSource)
		sources.erase(source)

	func registerSource(source: Component, distance: int, currentPow: int) -> void:
		if source not in sources:
			source.update.connect(sourceUpdate)
			source.resetting.connect(deleteSource)
		elif sources[source].x <= distance: return
		sources[source] = Vector2i(distance, currentPow)
	
	func sourceUpdate(source: Component, sourcePow: int) -> void:
		sources[source].y = max(0, sourcePow - sources[source].x)
		recalculatePower()
	
	func recalculatePower() -> void:
		power = 0
		for source in sources:
			var data: Vector2i = sources[source]
			if data.y >= power:
				power = data.y
				maxSource = source
		powersChanged.emit()


var inputs: Array[Connection] = []
var pos: Vector2i
var rot: int


func _init(pos: Vector2i, rot: int) -> void:
	self.pos = pos
	self.rot = rot


func die():
	deleted.emit()
	propagateRegenRequest()


func getConnectionID(dir: int) -> int:
	return -1


func isConnectedAt(dir: int) -> bool:
	return false


func getNeighbors() -> Array[Component]:
	return [null, null, null, null]


func registerConnection(source: Component, side: int, distance: int, currentPow: int) -> bool:
	var connID = getConnectionID(side)
	if connID == -1: return false
	inputs[connID].registerSource(source, distance, currentPow)
	return true


func updateTileAtLayer(layer: World.Layer):
	pass


func onNeighborChanged(dir: int):
	pass


func getType() -> Type:
	return Type.NONE


func isEqual(other: Component):
	return other.getType() == getType() and other.pos == pos and other.rot == rot


func isEqualToNew():
	return rot == Game.placingRotation


func propagateRegenRequest():
	var regeneratedSources: Array[Component]
	for input in inputs:
		for source in input.sources:
			if source not in regeneratedSources:
				source.regenConnections()
				regeneratedSources.append(source)


func interact():
	pass
