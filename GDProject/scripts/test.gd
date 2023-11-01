extends Node2D

var amount: int = 500
var times: Array[float] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.world.placeComponent(Component.Type.GENERATOR, Vector2i(0, 0), Side.UP)
	for x in 33:
		var trueX = x - 16
		for y in 33:
			var trueY = y - 16
			if trueY == 0 and trueX == 0: continue
			Game.world.placeComponent(Component.Type.WIRE, Vector2i(trueX, trueY), Side.UP)



func _on_button_pressed() -> void:
	times.clear()
	for i in amount:
		var tile: Generator = Game.world.getTileAt(Vector2i(0, 0))
		var time = Time.get_ticks_msec()
		tile.regenConnections(15 if tile.activated else 0)
		times.append(Time.get_ticks_msec() - time)
	var avg: float = 0
	for time in times:
		avg += time
	avg /= times.size()
	$CanvasLayer/Control/Label.text = "Amount: " + str(amount) + "\nTime: " + str(avg) + "ms"


func getCurrentZoom():
	return $Camera2D.zoom
