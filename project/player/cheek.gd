@tool
extends Marker2D

@export var radius := 0.0:
	set(value):
		radius = value
		queue_redraw()

@export var stroke_width := 1.0:
	set(value):
		stroke_width = value
		queue_redraw()

func _draw() -> void:
	if radius > 0:
		draw_circle(Vector2.ZERO, radius, Color.BLACK)
		draw_circle(Vector2.ZERO, radius - stroke_width, Color("783f04"))
