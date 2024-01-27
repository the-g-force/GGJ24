extends Node2D

@export var players := 4

var _players_joined : Array[int] = []

@onready var _spawn_point_parent := $SpawnPoints

func _ready():
	for i in players:
		_add_player(i)


func _add_player(id:int)->void:
	_players_joined.append(id)
	
	var player := preload("res://player/player.tscn").instantiate()
	add_child(player)
	var spawn_point := _spawn_point_parent.get_children()[id]
	player.global_position = spawn_point.global_position
	player.id = id
