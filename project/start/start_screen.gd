extends Control

@export var player_colors : Array[Color] = [
	Color.RED, Color.GREEN,
	Color.BLUE, Color.GOLD,
]

var _joined_player_ids : Array[int] = []
var _joined_player_colors := {}

@onready var _music_bus_index := AudioServer.get_bus_index("Music")
@onready var _sfx_bus_index := AudioServer.get_bus_index("SFX")


func _ready()->void:
	$MenuButtons/MuteMusicButton.button_pressed = AudioServer.is_bus_mute(_music_bus_index)
	$MenuButtons/MuteSFXButton.button_pressed = AudioServer.is_bus_mute(_sfx_bus_index)


func _input(event:InputEvent)->void:
	if event is InputEventJoypadButton and event.is_pressed():
		if not _joined_player_ids.has(event.device) and event.button_index == JOY_BUTTON_A:
			_join_player(event.device)
		elif event.button_index == JOY_BUTTON_START and _joined_player_ids.size() > 1:
			_start_game()


func _join_player(id:int)->void:
	_joined_player_ids.append(id)
	_joined_player_colors[id] = _get_unused_color(1)
	var player_banner := get_node("HBoxContainer/PlayerBanner" + str(id))
	player_banner.modulate = Color.WHITE
	player_banner.color = _joined_player_colors[id]


func _start_game()->void:
	var game := preload("res://world/world.tscn").instantiate()
	game.joined_player_ids = _joined_player_ids
	game.joined_player_colors = _joined_player_colors
	add_sibling(game)
	queue_free()


func _get_unused_color(search_direction:int)->Color:
	var used_colors := _joined_player_colors.values()
	var color_index := 0
	while used_colors.has(player_colors[color_index]):
		color_index += search_direction
		color_index %= player_colors.size()
	return player_colors[color_index]


func _on_quit_button_pressed()->void:
	get_tree().quit()


func _on_mute_music_button_toggled(toggled_on:bool)->void:
	AudioServer.set_bus_mute(_music_bus_index, toggled_on)


func _on_mute_sfx_button_toggled(toggled_on:bool)->void:
	AudioServer.set_bus_mute(_sfx_bus_index, toggled_on)
