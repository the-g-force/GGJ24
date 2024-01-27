extends PanelContainer


func update_wins(player_wins:Dictionary)->void:
	for i in player_wins:
		get_node("GridContainer/Player%sLabel" % i).text = "Chipmunk %s:" % i
		get_node("GridContainer/Player%sScore" % i).text = "%s win%s" % [player_wins[i], "" if player_wins[i] == 1 else "s"]
