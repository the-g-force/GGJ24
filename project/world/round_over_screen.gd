extends PanelContainer


func update_wins(player_wins:Dictionary, player_colors:Dictionary)->void:
	for i in player_wins:
		var player_label : Label = get_node("VBoxContainer/GridContainer/Player%sLabel" % i)
		player_label.text = "Player %s: \n\n" % (i + 1)
		var wins_label : Label = get_node("VBoxContainer/GridContainer/Player%sScore" % i)
		wins_label.text = "%s win%s \n\n" % [player_wins[i], "" if player_wins[i] == 1 else "s"]
		
		player_label.label_settings.font_color = player_colors[i]
		wins_label.label_settings.font_color = player_colors[i]
