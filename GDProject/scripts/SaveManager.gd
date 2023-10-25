extends Node

signal bgChanged(color: Color)
signal wireChanged(color: Color)
signal overwriteChanged(overwrite: bool)

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
