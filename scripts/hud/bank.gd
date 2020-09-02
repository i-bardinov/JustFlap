extends Control

signal close
signal watch_rewarded_ad
signal coins_updated

export var coins_reward: int = 10

onready var AdMob = get_node("../../AdMob")
onready var ad_button = get_node("CenterContainer/VBoxContainer/BankLine_Ads")
onready var coins_count_label = get_node("CenterContainer/VBoxContainer/BankLine_Ads/Coins/CoinsCount")

var _Utils = preload("res://scripts/core/utils.gd")
var on_close: FuncRef = null

func _ready():
	coins_count_label.text = str(coins_reward)

func _on_Darkening_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal('close')

func _notification(what):
	if visible:
		if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
			emit_signal('close')

func _on_Bank_close():
	hide()
	if on_close:
		on_close.call_func()
		on_close = null

func _on_Menu_not_enough_coins(callback):
	on_close = callback
	show()

func _physics_process(_delta):
	ad_button.visible = AdMob.is_rewarded_ad_loaded()


func _on_BankButton_Ads_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("BankButton_Ads", true, false))
func _on_BankButton_Ads_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("BankButton_Ads", true, false))
func _on_BankButton_1_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("BankButton_1", true, false))
func _on_BankButton_1_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("BankButton_1", true, false))


func _on_BankButton_1_pressed():
	pass

func _on_BankButton_Ads_pressed():
	emit_signal("watch_rewarded_ad")

func _on_AdMob_rewarded_ad_earned_reward(_type, _amount):
	if visible:
		Global.coins += coins_reward
		emit_signal("coins_updated")

func _on_Settings_bank(callback):
	on_close = callback
	show()
