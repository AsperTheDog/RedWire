extends Node

signal bgChanged(color: Color)
signal wireChanged(color: Color)
signal overwriteChanged(overwrite: bool)
signal rotationChanged(rotation: int)
signal eraserToggled(active: bool)
signal wireDisplayUpdated(doUpdate: bool)

var world: World = null

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
