extends Node2D

const MAX_PLAYER_INDEX := 3

var _players_joined : Array[int] = []

@onready var _spawn_point_parent := $SpawnPoints

func _input(event:InputEvent)->void:
	if event is InputEventKey\
		and event.is_pressed()\
		and event.keycode == KEY_SPACE\
		and not _players_joined.has(0):
		_add_player(0)
	
	if event is InputEventJoypadButton and event.is_pressed():
		var player_index := event.device
		if player_index <= MAX_PLAYER_INDEX \
			and not _players_joined.has(player_index):
			_add_player(player_index)


func _add_player(id:int)->void:
	_players_joined.append(id)
	
	var player := preload("res://player/player.tscn").instantiate()
	add_child(player)
	var spawn_point := _spawn_point_parent.get_children()[id]
	player.global_position = spawn_point.global_position
	player.id = id
