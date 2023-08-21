extends Control

#func _ready():
	#highlight_entry(Color.BLUE_VIOLET)

func setup(rank: int, player: String, score: int, data: String):
	$HBoxContainer/Rank.text = str(rank)
	$HBoxContainer/Player.text = player
	$HBoxContainer/Score.text = str(score)
	$HBoxContainer/Data.text = data


func highlight_entry(color: Color) -> void:
	#change color for all label !!
	#print("color="+str(color))
	$HBoxContainer/Rank.set("theme_override_colors/font_color", color)
		#get_label_settings().font_color = color
	$HBoxContainer/Player.set("theme_override_colors/font_color", color)
	$HBoxContainer/Score.set("theme_override_colors/font_color", color)
