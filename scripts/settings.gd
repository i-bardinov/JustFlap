extends Control

signal sound
signal score

var _Utils = preload("res://scripts/utils.gd")
onready var AdMob = get_node("../../AdMob")

func _on_SoundButton_pressed():
	emit_signal('sound')

func _on_ScoreButton_pressed():
	emit_signal("score")

func _on_ScoreButton_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("ScoreButton", true, false))
func _on_ScoreButton_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("ScoreButton", true, false))
func _on_SoundButton_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("SoundButton", true, false))
func _on_SoundButton_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("SoundButton", true, false))

func _on_Player_start_flying():
	hide()

func _on_Level_reset():
	show()

func _on_Level_game_over():
	show()

func _on_AdMob_banner_ad_loaded():
	var scale: float = float(ProjectSettings.get_setting("display/window/size/height")) / float(OS.get_screen_size().y)
	var dimension: Vector2 = AdMob.get_banner_dimension()
	$MarginContainer.rect_position.y = -dimension.y * scale
