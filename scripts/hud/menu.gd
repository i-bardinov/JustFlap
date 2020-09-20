extends Control

signal replay
signal continue_button
signal watch_rewarded_ad
signal continue_game
signal not_enough_coins(callback)

signal mute(is_muted)
signal coins_updated(coins)

export var price_multiplier: int = 10
export var color_available: Color = Color8(0, 167, 72, 255)
export var color_unavailable: Color = Color.firebrick

var _Utils = preload("res://scripts/core/utils.gd")

var texture_sound_on = preload("res://assets/images/icons/sound_on_icon.png")
var texture_sound_off = preload("res://assets/images/icons/sound_off_icon.png")

onready var price_text: Label = get_node("CenterContainer/VBoxContainer/Center/VBoxContainer/ContinueButton/CenterContainer/HBoxContainer/Price")
onready var continue_button: TextureButton = get_node("CenterContainer/VBoxContainer/Center/VBoxContainer/ContinueButton")
onready var ad_button: TextureButton = get_node("CenterContainer/VBoxContainer/Center/VBoxContainer/AdButton")
onready var AdMob = get_node("../../AdMob")

const SAVE_GAME_PATH = "user://savedata.bin"

var high_score: int = 0
var is_muted: bool = false
var is_score_showed: bool = false
var current_price: int = 0

func _ready():
	load_game()
	continue_button.visible = false
	ad_button.visible = false

func show():
	.show()
	set_text(tr("CONTINUE"))
	continue_button.visible = true
	ad_button.visible = Global.death_count == 1 and AdMob.is_rewarded_ad_loaded()
	is_score_showed = false
	current_price = price_multiplier * int(pow(2, (Global.death_count - 1)))
	if current_price > 9999:
		return
	price_text.text = str(current_price)
	if current_price <= Global.coins:
		price_text.add_color_override("font_color", color_available)
	else:
		price_text.add_color_override("font_color", color_unavailable)

func _physics_process(_delta):
	ad_button.visible = Global.death_count == 1 and AdMob.is_rewarded_ad_loaded()

func set_text(text: String):
	$CenterContainer/VBoxContainer/Text.text = text

func sound_change():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_muted)
	emit_signal("mute", is_muted)
	if is_muted:
		get_tree().get_root().find_node("SoundTexture", true, false).texture = texture_sound_off
	else:
		get_tree().get_root().find_node("SoundTexture", true, false).texture = texture_sound_on

func _on_ReplayButton_pressed():
	emit_signal('replay')

func _on_ContinueButton_pressed():
	emit_signal("continue_button")

func _on_AdButton_pressed():
	emit_signal("watch_rewarded_ad")

func load_game():
	var saved_game = File.new()
	if saved_game.file_exists(SAVE_GAME_PATH):
		var err = saved_game.open_encrypted_with_pass(SAVE_GAME_PATH, File.READ, "create2random6passWord8235Nq")
		if err == OK:
			high_score = saved_game.get_var()
			is_muted = saved_game.get_var()
			Global.coins = saved_game.get_var()
			var start_count = saved_game.get_var()
			if start_count:
				Global.start_count += start_count
			var premium = saved_game.get_var()
			if premium != null:
				Global.premium = premium
			saved_game.close()
	sound_change()
	emit_signal("coins_updated", Global.coins)
	$GPGS.sign_in(true)

func save_game():
	var saved_game = File.new()
	var err = saved_game.open_encrypted_with_pass(SAVE_GAME_PATH, File.WRITE, "create2random6passWord8235Nq")
	if err == OK:
		saved_game.store_var(high_score)
		saved_game.store_var(is_muted)
		saved_game.store_var(Global.coins)
		saved_game.store_var(Global.start_count)
		saved_game.store_var(Global.premium)
		saved_game.close()
	$GPGS.submit_leaderboard_score(high_score)

func _on_Level_game_over():
	high_score = int(max(Global.score, high_score))
	save_game()
	show()

func _on_coin_taken():
	Global.coins += 1
	emit_signal("coins_updated", Global.coins)

func _on_ContinueMenu_return_to_menu():
	show()

func _on_Level_reset():
	hide()

func _on_Level_game_continue():
	hide()

func _on_ReplayButton_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("ReplayButton", true, false))
func _on_ReplayButton_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("ReplayButton", true, false))
func _on_ContinueButton_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("ContinueButton", true, false))
func _on_ContinueButton_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("ContinueButton", true, false))
func _on_AdButton_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("AdButton", true, false))
func _on_AdButton_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("AdButton", true, false))

func _on_ScoreTimer_timeout():
	if is_score_showed:
		set_text(tr("CONTINUE"))
		is_score_showed = false
	else:
		set_text(tr("BEST_SCORE") + str(high_score))
		is_score_showed = true

func _on_Settings_sound():
	is_muted = !is_muted
	sound_change()
	save_game()

func _on_Settings_score():
	if $GPGS.is_inited():
		if $GPGS.is_signed_in():
			$GPGS.show_leaderboard()
		else:
			if not $GPGS.play_games_services.is_connected("_on_sign_in_success", self, "_on_sign_in_success"):
				$GPGS.play_games_services.connect("_on_sign_in_success", self, "_on_sign_in_success")
			$GPGS.sign_in(false)

func _on_sign_in_success(_account_id: String) -> void:
	$GPGS.show_leaderboard()

func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal('replay')

func _notification(what):
	if visible:
		if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
			emit_signal('replay')

func _on_Menu_continue_button():
	if Global.coins >= current_price:
		Global.coins -= current_price
		save_game()
		emit_signal("coins_updated", Global.coins)
		emit_signal("continue_game")
	else:
		hide()
		emit_signal("not_enough_coins", funcref(self, "_on_return_from_bank"))

func _on_return_from_bank():
	if Global.coins >= current_price:
		Global.coins -= current_price
		save_game()
		emit_signal("coins_updated", Global.coins)
		emit_signal("continue_game")
	else:
		show()

func _on_AdMob_rewarded_ad_earned_reward(_type, _amount):
	if visible:
		emit_signal("continue_game")

func _on_Bank_coins_updated():
	save_game()
	emit_signal("coins_updated", Global.coins)
