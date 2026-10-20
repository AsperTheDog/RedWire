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
	SLOGGER,
	LAMP
}

signal update(comp: Component, power: int)
signal deleted(comp: Component)


class Connection:
	signal powersChanged

	var power: int = 0
	# source -> Vector2i(distance, power the source gives)
	var sources: Dictionary = {}

	func deleteSource(source: Component) -> void:
		if source not in sources: return
		source.update.disconnect(sourceUpdate)
		source.deleted.disconnect(deleteSource)
		sources.erase(source)
		recalculatePower()

	func registerSource(source: Component, distance: int, currentPow: int) -> bool:
		if source in sources: return false
		source.update.connect(sourceUpdate)
		source.deleted.connect(deleteSource)
		sources[source] = Vector2i(distance, max(0, currentPow - distance))
		recalculatePower()
		return true

	func sourceUpdate(source: Component, sourcePow: int) -> void:
		sources[source].y = max(0, sourcePow - sources[source].x)
		recalculatePower()

	func recalculatePower() -> void:
		var newPower = 0
		for source in sources:
			newPower = max(newPower, sources[source].y)
		if power != newPower:
			power = newPower
			powersChanged.emit()


var inputs: Array[Connection] = []
var pos: Vector2i
var rot: int


func _init(pos: Vector2i, rot: int) -> void:
	self.pos = pos
	self.rot = rot


func die():
	deleted.emit(self)
	propagateRegenRequest()


func addInput() -> void:
	var id := inputs.size()
	inputs.append(Connection.new())
	inputs[id].powersChanged.connect(onPowerUpdate.bind(id))


func onPowerUpdate(id: int):
	pass


func getConnectionID(dir: int) -> int:
	return -1


func isConnectedAt(dir: int) -> bool:
	return false


func getNeighbors(from: int) -> Array[Component]:
	return [null, null, null, null]


func registerConnection(source: Component, side: int, distance: int, currentPow: int) -> bool:
	var connID = getConnectionID(side)
	if connID == -1: return false
	return inputs[connID].registerSource(source, distance, currentPow)


func updateTileAtLayer(layer: World.Layer):
	pass


func onNeighborChanged(dir: int):
	pass


func getType() -> Type:
	return Type.NONE


func isEqualToNew(type: Type):
	return type == getType() and rot == Game.placingRotation


func propagateRegenRequest():
	for input in inputs:
		for source in input.sources:
			source.requestRegen()


func interact():
	pass


func getMeta():
	return []


func applyMeta(meta: Array):
	pass


func start():
	pass


func discard():
	pass
