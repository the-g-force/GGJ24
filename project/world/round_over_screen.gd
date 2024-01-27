extends PanelContainer


func update_wins(player_wins:Dictionary)->void:
	for i in player_wins:
		get_node("VBoxContainer/Player%sLabel" % i).text = "Chipmunk %s: %s win%s" % \
		[i, player_wins[i], "" if player_wins[i] == 1 else "s"] 
