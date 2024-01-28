@tool
extends VBoxContainer

@export var player_index := 0 :
	set(value):
		player_index = value
		$PanelContainer/Label.text = "Player %s" % player_index

var color : Color :
	set(value):
		color = value
		var stylebox := StyleBoxFlat.new()
		stylebox.bg_color = color
		stylebox.border_color = color
		stylebox.set_corner_radius_all(5)
		stylebox.set_border_width_all(4)
		$PanelContainer.add_theme_stylebox_override("panel", stylebox)
