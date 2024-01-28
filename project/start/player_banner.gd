@tool
extends VBoxContainer

@export var player_index := 0 :
	set(value):
		player_index = value
		$Label.text = "Player %s" % player_index
