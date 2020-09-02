extends Control

func _ready():
	$MarginContainer2/HBoxContainer/Coins.text = str(Global.coins)
	set_visible_coins(true)

func set_visible_score(visibility: bool):
	$MarginContainer.visible = visibility
	if visibility:
		$MarginContainer/VBoxContainer/Score.text = str(Global.score)
	
func set_visible_coins(visibility: bool):
	$MarginContainer2.visible = visibility
	if visibility:
		$MarginContainer2/HBoxContainer/Coins.text = str(Global.coins)

func _on_Level_game_over():
	set_visible_coins(true)

func _on_Level_reset():
	set_visible_score(false)
	_on_Level_score_updated(0)

func _on_Level_game_continue():
	set_visible_coins(true)

func _on_Level_score_updated(score):
	$MarginContainer/VBoxContainer/Score.text = str(score)

func _on_Player_start_flying():
	set_visible_score(true)

func _on_Menu_coins_updated(_coins):
	$MarginContainer2/HBoxContainer/Coins.text = str(Global.coins)
