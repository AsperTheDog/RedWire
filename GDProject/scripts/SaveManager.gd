extends Node

signal bgChanged(color: Color)
signal wireChanged(color: Color)
signal overwriteChanged(overwrite: bool)
signal rotationChanged(rotation: Machine.Dir)
signal eraserToggled(active: bool)

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

var selectedMachine: World.MachineType = World.MachineType.WIRE
var placingRotation: Machine.Dir = Machine.Dir.UP:
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
