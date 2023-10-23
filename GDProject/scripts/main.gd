extends Node2D

var moving: bool = false:
	set(value):
		if moving == value: return
		moving = value
		if moving:
			origWorld = $Camera2D.position

var origMouse: Vector2 = Vector2.ZERO
var origWorld: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("zoom_up"):
		$Camera2D.zoom *= 0.9
	elif Input.is_action_just_pressed("zoom_down"):
		$Camera2D.zoom *= 1.1
	moving = Input.is_action_pressed("move")


func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_action("move"):
		if event.is_pressed():
			moving = true
			origMouse = event.position
		elif event.is_released():
			moving = false
	elif moving and event is InputEventMouseMotion:
		$Camera2D.position = ((origMouse - event.position) / $Camera2D.zoom + origWorld)
