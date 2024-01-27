extends Control

var _joined_player_ids : Array[int] = []


func _input(event:InputEvent)->void:
	if event is InputEventJoypadButton and event.is_pressed():
		if not _joined_player_ids.has(event.device) and event.button_index == JOY_BUTTON_A:
			_join_player(event.device)
		elif event.button_index == JOY_BUTTON_START:
			_start_game()


func _join_player(id:int)->void:
	_joined_player_ids.append(id)
	get_node("HBoxContainer/PlayerBanner" + str(id + 1)).texture = load("res://player/chipmunk.png")


func _start_game()->void:
	var game := preload("res://world/world.tscn").instantiate()
	game.joined_player_ids = _joined_player_ids
	add_sibling(game)
	queue_free()
