extends Node2D

var _players_joined : Array[int] = []


func _input(event:InputEvent)->void:
	if event is InputEventJoypadButton and event.is_pressed():
		if not _players_joined.has(event.device):
			_add_player(event.device)


func _add_player(id:int)->void:
	_players_joined.append(id)
	
	var player := preload("res://player/player.tscn").instantiate()
	add_child(player)
	player.id = id
	
	print("player ", id, " added")
