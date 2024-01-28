extends Node2D


func display(winner_index:int, winner_color:Color)->void:
	$Label.text = "Player %s is the WINNER!" % (winner_index + 1)
	$Label.label_settings.font_color = winner_color
	$Label2.text = str(winner_index + 1)
	$Label2.label_settings.font_color = winner_color
