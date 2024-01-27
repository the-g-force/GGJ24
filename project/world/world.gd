extends Node2D

## The number of players that start in this round of the game
@export var joined_player_ids : Array[int] = [0, 1, 2, 3]
@export var seconds_between_rounds := 3.0

@onready var _spawn_point_parent := $SpawnPoints

var _players : Array[Player]

func _ready():
	for i in joined_player_ids:
		_add_player(i)


func _add_player(id:int)->void:
	var player := preload("res://player/player.tscn").instantiate()
	player.id = id
	add_child(player)
	var spawn_point := _spawn_point_parent.get_children()[id]
	player.global_position = spawn_point.global_position
	_players.append(player)
	player.died.connect(_on_player_died.bind(player))


func _on_player_died(player:Player) -> void:
	_players.erase(player)
	if _players.size() == 1:
		$GameOverLabel.visible = true
		await get_tree().create_timer(seconds_between_rounds).timeout
		var new_scene = load("res://world/world.tscn").instantiate()
		new_scene.joined_player_ids = joined_player_ids
		add_sibling(new_scene)
		queue_free()
