extends Node


@onready var gridButtons: Array[TextureButton] = [
	$UILayer/Drawer/margin/scroll/Grid/Wire/TileBG/margin/TileTex,
	$UILayer/Drawer/margin/scroll/Grid/Repeater/TileBG/margin/TileTex,
	$UILayer/Drawer/margin/scroll/Grid/Comparator/TileBG/margin/TileTex,
	$UILayer/Drawer/margin/scroll/Grid/Negator/TileBG/margin/TileTex,
	$UILayer/Drawer/margin/scroll/Grid/Generator/TileBG/margin/TileTex
]


func _ready() -> void:
	Save.wireChanged.connect(onWireColorChange)
	Save.bgChanged.connect(onBGColorChange)
	for butt in gridButtons:
		butt.mouse_entered.connect(func(): butt.get_node("../../hover").show())
		butt.mouse_exited.connect(func(): butt.get_node("../../hover").hide())
		butt.pressed.connect(updatePressedButton.bind(butt))
	$UILayer/Control/MarginContainer/HBoxContainer/BGColor.color_changed.connect(func(color): Save.bgColor = color)
	$UILayer/Control/MarginContainer/HBoxContainer/WireColor.color_changed.connect(func(color): Save.wireColor = color)
	$UILayer/Control/MarginContainer/HBoxContainer/Overwrite.toggled.connect(func(pressed): Save.doOverwrite = pressed)
	$UILayer/Control/MarginContainer/HBoxContainer/BGColor.color = Save.bgColor
	$UILayer/Control/MarginContainer/HBoxContainer/WireColor.color = Save.wireColor
	$UILayer/Control/MarginContainer/HBoxContainer/Overwrite.set_pressed_no_signal(Save.doOverwrite)
	onWireColorChange(Save.wireColor)
	onBGColorChange(Save.bgColor)
	


func _process(delta: float):
	if Input.is_action_just_pressed("drawer"):
		toggleDrawer()
	


func updatePressedButton(pressed: TextureButton):
	for butt in gridButtons:
		butt.get_node("../../press").visible = false
	pressed.get_node("../../press").visible = true


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
		for child in butt.get_node("../").get_children():
			if not child is TextureRect: continue
			child.self_modulate = color


func onBGColorChange(color: Color):
	$BackgroundLayer/ColorRect.color = color