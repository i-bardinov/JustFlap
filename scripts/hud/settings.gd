extends Control

signal sound
signal score
signal bank(callback)

signal bank_closed

var _Utils = preload("res://scripts/core/utils.gd")
onready var AdMob = get_node("../../AdMob")

func _on_BankButton_pressed():
	emit_signal("bank", funcref(self, "_on_return_from_bank"))

func _on_SoundButton_pressed():
	emit_signal('sound')

func _on_ScoreButton_pressed():
	emit_signal("score")

func _on_BankButton_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("BankButton", true, false))
func _on_BankButton_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("BankButton", true, false))
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
	hide()

func _on_Level_game_continue():
	hide()

func _on_AdMob_banner_ad_loaded():
	var scale: float = float(ProjectSettings.get_setting("display/window/size/height")) / float(OS.get_screen_size().y)
	var dimension: Vector2 = AdMob.get_banner_dimension()
	$MarginContainer.rect_position.y = -dimension.y * scale

func _on_return_from_bank() -> void:
	emit_signal("bank_closed")
