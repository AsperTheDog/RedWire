extends Node

signal projectPathChanged(path: String)
signal bgChanged(color: Color)
signal wireChanged(color: Color)
signal overwriteChanged(overwrite: bool)
signal rotationChanged(rotation: int)
signal eraserToggled(active: bool)
signal wireDisplayUpdated(doUpdate: bool)

var world: World = null

var savePath: String = ""

var bgColor: Color = Color.DARK_BLUE:
	set(value):
		bgColor = value
		bgChanged.emit(value)

var wireColor: Color = Color.RED:
	set(value):
		wireColor = value
		wireChanged.emit(value)

var doOverwrite: bool = true:
	set(value):
		doOverwrite = value
		overwriteChanged.emit(value)

var selectedComponent: Component.Type = Component.Type.WIRE
var placingRotation: int = Side.UP:
	set(value):
		placingRotation = value
		rotationChanged.emit(value)

var tps: int = 10:
	set(value):
		tps = value
		Engine.physics_ticks_per_second = tps

var eraserActive: bool:
	set(value):
		eraserActive = value
		eraserToggled.emit(value)

var updateWires: bool = true:
	set(value):
		if updateWires == value: return
		updateWires = value
		wireDisplayUpdated.emit(value)


func saveProject() -> bool:
	var data: Dictionary
	var file := FileAccess.open(savePath, FileAccess.WRITE)
	if file == null:
		return false
	for elem in world.world:
		data[elem] = {
			"type": world.world[elem].getType(),
			"rot": world.world[elem].rot,
			"meta": world.world[elem].getMeta()
		}
	file.store_var(data)
	return true


func loadProject(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	savePath = path
	var data = file.get_var()
	if not data is Dictionary:
		return false
	world.empty()
	for pos in data:
		world.placeComponent(data[pos]["type"], pos, data[pos]["rot"])
		world.world[pos].applyMeta(data[pos]["meta"])
	return true
