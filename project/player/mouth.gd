@tool
extends Sprite2D

var percent_length := 0.0 :
	set(value):
		percent_length = value
		scale = Vector2(percent_length, 1.0)


func _ready()->void:
	percent_length = 0.0
