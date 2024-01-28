extends Node2D

const THEME_SONGS := [
	"res://world/game_theme.ogg",
	"res://world/game_theme_2.ogg",
	"res://world/game_theme_3.ogg",
	"res://world/game_theme_4.ogg",
]

## The number of players that start in this round of the game
@export var joined_player_ids : Array[int] = [0, 1, 2, 3]
@export var seconds_between_rounds := 3.0

@onready var _spawn_point_parent := $SpawnPoints

var _players : Array[Player]
var player_wins := {}
var joined_player_colors := {
	0:Color.WHITE,
	1:Color.WHITE,
	2:Color.WHITE,
	3:Color.WHITE,
}
var _pending_game_over := false

func _ready():
	for i in joined_player_ids:
		_add_player(i)
	if player_wins.size() < joined_player_ids.size():
		for id in joined_player_ids:
			if not player_wins.has(id):
				player_wins[id] = 0
	
	$Music.stream = load(THEME_SONGS.pick_random())
	$Music.play()


func _add_player(id:int)->void:
	var player := preload("res://player/player.tscn").instantiate()
	player.id = id
	player.color = joined_player_colors[id]
	add_child(player)
	var spawn_point := _spawn_point_parent.get_children()[id]
	player.global_position = spawn_point.global_position
	_players.append(player)
	player.died.connect(_on_player_died.bind(player))


func _on_player_died(player:Player) -> void:
	if _pending_game_over:
		return
	
	_players.erase(player)
	if _players.size() == 1:
		_pending_game_over = true
		var winner_id := _players[0].id
		player_wins[winner_id] += 1
		if player_wins[winner_id] == 3:
			_end_game(winner_id)
		else:
			_end_round()


func _end_round()->void:
	$RoundOverScreen.show()
	$RoundOverScreen.update_wins(player_wins, joined_player_colors)
	await get_tree().create_timer(seconds_between_rounds).timeout
	_load_new_round()


func _load_new_round()->void:
	var new_scene = load("res://world/world.tscn").instantiate()
	new_scene.joined_player_ids = joined_player_ids
	new_scene.joined_player_colors = joined_player_colors
	new_scene.player_wins = player_wins
	add_sibling(new_scene)
	queue_free()


func _end_game(winner_id:int)->void:
	$GameOverPopup.visible = true
	$GameOverPopup.display(winner_id, joined_player_colors[winner_id], joined_player_ids.size())
	await get_tree().create_timer(seconds_between_rounds).timeout
	add_sibling(load("res://start/start_screen.tscn").instantiate())
	queue_free()
