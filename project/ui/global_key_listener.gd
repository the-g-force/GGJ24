extends Node

func _process(_delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN\
			if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN\
			else DisplayServer.WINDOW_MODE_WINDOWED
		)
