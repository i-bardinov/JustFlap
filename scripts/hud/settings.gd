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
	var scale: float = float(get_viewport().get_visible_rect().size.x) / float(OS.get_window_size().x)
	var dimension: Vector2 = AdMob.get_banner_dimension()
	if dimension.y <= 1:
		$BannerSizeUpdate.start()
	$MarginContainer.rect_position.y = -dimension.y * scale - 10

func _on_return_from_bank() -> void:
	emit_signal("bank_closed")

func _on_BannerSizeUpdate_timeout():
	_on_AdMob_banner_ad_loaded()

