extends Node

var currentDragComponent: Component.Type:
	set(value):
		currentDragComponent = value
		updatePressedButton(value)
		Game.selectedComponent = currentDragComponent


@onready var gridButtons: Dictionary = {
	Component.Type.WIRE: $UILayer/Drawer/margin/scroll/Grid/Wire/TileBG/margin/TileTex,
	Component.Type.REPEATER: $UILayer/Drawer/margin/scroll/Grid/Repeater/TileBG/margin/TileTex,
	Component.Type.COMPARATOR: $UILayer/Drawer/margin/scroll/Grid/Comparator/TileBG/margin/TileTex,
	Component.Type.NEGATOR: $UILayer/Drawer/margin/scroll/Grid/Negator/TileBG/margin/TileTex,
	Component.Type.GENERATOR: $UILayer/Drawer/margin/scroll/Grid/Generator/TileBG/margin/TileTex,
	Component.Type.CROSSING: $UILayer/Drawer/margin/scroll/Grid/Crossroad/TileBG/margin/TileTex,
	Component.Type.FLICKER: $UILayer/Drawer/margin/scroll/Grid/Flicker/TileBG/margin/TileTex,
	Component.Type.SLOGGER: $UILayer/Drawer/margin/scroll/Grid/Slogger/TileBG/margin/TileTex
}


func _ready() -> void:
	Game.wireChanged.connect(onWireColorChange)
	Game.bgChanged.connect(onBGColorChange)
	Game.rotationChanged.connect(onRotationChange)
	for buttKey in gridButtons:
		var butt = gridButtons[buttKey]
		butt.mouse_entered.connect(func(): butt.get_node("../../hover").show())
		butt.mouse_exited.connect(func(): butt.get_node("../../hover").hide())
		butt.pressed.connect(func(): currentDragComponent = buttKey)
	$UILayer/Control/MarginContainer/HBoxContainer/BGColor.color_changed.connect(func(color): Game.bgColor = color)
	$UILayer/Control/MarginContainer/HBoxContainer/WireColor.color_changed.connect(func(color): Game.wireColor = color)
	$UILayer/Control/MarginContainer/HBoxContainer/Overwrite.toggled.connect(func(pressed): Game.doOverwrite = pressed)
	$UILayer/Control/MarginContainer/HBoxContainer/BGColor.color = Game.bgColor
	$UILayer/Control/MarginContainer/HBoxContainer/WireColor.color = Game.wireColor
	$UILayer/Control/MarginContainer/HBoxContainer/Overwrite.set_pressed_no_signal(Game.doOverwrite)
	onWireColorChange(Game.wireColor)
	onBGColorChange(Game.bgColor)
	currentDragComponent = Component.Type.WIRE


func _process(delta: float):
	if Input.is_action_just_pressed("drawer"):
		toggleDrawer()
	if Input.is_action_just_pressed("erase"):
		var butt: TextureButton = $UILayer/Control/MarginContainer/HBoxContainer/TextureRect/eraser
		butt.button_pressed = not butt.button_pressed


func updatePressedButton(pressed: Component.Type):
	for butt in gridButtons:
		gridButtons[butt].get_node("../../press").visible = false
	gridButtons[pressed].get_node("../../press").visible = true


var isDrawerOpen: bool = true
var drawerTween: Tween = null
func toggleDrawer() -> void:
	var screenEdge: float = $UILayer/Drawer.get_viewport_rect().size.x
	var targetNode: Control = $UILayer/Drawer/ClosedPoint if isDrawerOpen else $UILayer/Drawer/OpenedPoint
	var distToMove := screenEdge - targetNode.global_position.x
	if drawerTween != null:
		drawerTween.kill()
	drawerTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	drawerTween.tween_property($UILayer/Drawer, "position:x", $UILayer/Drawer.position.x + distToMove, 0.5)
	isDrawerOpen = not isDrawerOpen


func onWireColorChange(color: Color):
	for butt in gridButtons:
		for child in gridButtons[butt].get_node("../").get_children():
			if not child is TextureRect: continue
			child.self_modulate = color


func onBGColorChange(color: Color):
	$BackgroundLayer/ColorRect.color = color


func onRotationChange(rot: int):
	for butt in gridButtons:
		for child in gridButtons[butt].get_node("../").get_children():
			child.pivot_offset = child.size / 2
			child.rotation = deg_to_rad(90 * rot)


func TPSChanged(newTPS: String):
	if not newTPS.is_valid_int(): return
	var tps: int = newTPS.to_int()
	if tps <= 0: return
	Game.tps = tps


func eraserToggled(active: bool) -> void:
	Game.eraserActive = active
