extends Control

signal close
signal watch_rewarded_ad
signal coins_updated

export var coins_ad_reward: int = 10
export var coins_1_reward: int = 300
export var coins_2_reward: int = 1500
export var coins_3_reward: int = 3000
export var coins_4_reward: int = 9000

onready var AdMob = get_node("../../AdMob")
onready var ad_button = get_node("CenterContainer/VBoxContainer/BankLine_Ads")
onready var coins_count_label = get_node("CenterContainer/VBoxContainer/BankLine_Ads/Coins/CoinsCount")

var _Utils = preload("res://scripts/core/utils.gd")
var on_close: FuncRef = null

var tokens: Dictionary = {}
var payment

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		# These are all signals supported by the API
		# You can drop some of these based on your needs
		payment.connect("connected", self, "_on_connected") # No params
		payment.connect("disconnected", self, "_on_disconnected") # No params
		payment.connect("connect_error", self, "_on_connect_error") # Response ID (int), Debug message (string)
		payment.connect("purchases_updated", self, "_on_purchases_updated") # Purchases (Dictionary[])
		#payment.connect("purchase_error", self, "_on_purchase_error") # Response ID (int), Debug message (string)
		payment.connect("sku_details_query_completed", self, "_on_sku_details_query_completed") # SKUs (Dictionary[])
		payment.connect("sku_details_query_error", self, "_on_sku_details_query_error") # Response ID (int), Debug message (string), Queried SKUs (string[])
		#payment.connect("purchase_acknowledged", self, "_on_purchase_acknowledged") # Purchase token (string)
		#payment.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error") # Response ID (int), Debug message (string), Purchase token (string)
		payment.connect("purchase_consumed", self, "_on_purchase_consumed") # Purchase token (string)
		#payment.connect("purchase_consumption_error", self, "_on_purchase_consumption_error") # Response ID (int), Debug message (string), Purchase token (string)

		payment.startConnection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and the GodotGooglePlayBilling plugin in your Android export settings! IAP will not work.")
	coins_count_label.text = str(coins_ad_reward)
	$CenterContainer/VBoxContainer/BankLine_1/Button/BankButton_1/CenterContainer/Price.text = ""
	$CenterContainer/VBoxContainer/BankLine_2/Button/BankButton_2/CenterContainer/Price.text = ""
	$CenterContainer/VBoxContainer/BankLine_3/Button/BankButton_3/CenterContainer/Price.text = ""
	$CenterContainer/VBoxContainer/BankLine_4/Button/BankButton_4/CenterContainer/Price.text = ""
	$CenterContainer/VBoxContainer/BankLine_1/Coins/CoinsCount.text = str(coins_1_reward)
	$CenterContainer/VBoxContainer/BankLine_2/Coins/CoinsCount.text = str(coins_2_reward)
	$CenterContainer/VBoxContainer/BankLine_3/Coins/CoinsCount.text = str(coins_3_reward)
	$CenterContainer/VBoxContainer/BankLine_4/Coins/CoinsCount.text = str(coins_4_reward)

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
func _on_BankButton_2_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("BankButton_2", true, false))
func _on_BankButton_2_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("BankButton_2", true, false))
func _on_BankButton_3_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("BankButton_3", true, false))
func _on_BankButton_3_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("BankButton_3", true, false))
func _on_BankButton_4_button_down():
	_Utils.on_button_down(get_tree().get_root().find_node("BankButton_4", true, false))
func _on_BankButton_4_button_up():
	_Utils.on_button_up(get_tree().get_root().find_node("BankButton_4", true, false))

func _on_BankButton_1_pressed():
	if payment:
		payment.purchase("coin_1")
func _on_BankButton_2_pressed():
	if payment:
		payment.purchase("coin_2")
func _on_BankButton_3_pressed():
	if payment:
		payment.purchase("coin_3")
func _on_BankButton_4_pressed():
	if payment:
		payment.purchase("coin_4")

func _on_BankButton_Ads_pressed():
	emit_signal("watch_rewarded_ad")

func _on_AdMob_rewarded_ad_earned_reward(_type, _amount):
	if visible:
		Global.coins += coins_ad_reward
		emit_signal("coins_updated")

func _on_Settings_bank(callback):
	on_close = callback
	show()

func _on_connected():
	var query = payment.queryPurchases("inapp") # Use "subs" for subscriptions.
	if query.status == OK:
		for purchase in query.purchases:
			if !purchase.is_acknowledged:
				tokens[purchase.purchase_token] = purchase.sku
				payment.consumePurchase(purchase.purchase_token)
	payment.querySkuDetails(["coin_1", "coin_2", "coin_3", "coin_4"], "inapp")

func _on_disconnected():
	$PurchasesRefreshTimer.start()

func _on_connect_error(_response, _error):
	$PurchasesRefreshTimer.start()

func _on_sku_details_query_completed(sku_details):
	for available_sku in sku_details:
		if available_sku.sku == "coin_1":
			$CenterContainer/VBoxContainer/BankLine_1/Button/BankButton_1.visible = true
			$CenterContainer/VBoxContainer/BankLine_1/Button/BankButton_1/CenterContainer/Price.text = String(available_sku.price_amount_micros / 1000000.0)
		if available_sku.sku == "coin_2":
			$CenterContainer/VBoxContainer/BankLine_2/Button/BankButton_2.visible = true
			$CenterContainer/VBoxContainer/BankLine_2/Button/BankButton_2/CenterContainer/Price.text = String(available_sku.price_amount_micros / 1000000.0)
		if available_sku.sku == "coin_3":
			$CenterContainer/VBoxContainer/BankLine_3/Button/BankButton_3.visible = true
			$CenterContainer/VBoxContainer/BankLine_3/Button/BankButton_3/CenterContainer/Price.text = String(available_sku.price_amount_micros / 1000000.0)
		if available_sku.sku == "coin_4":
			$CenterContainer/VBoxContainer/BankLine_4/Button/BankButton_4.visible = true
			$CenterContainer/VBoxContainer/BankLine_4/Button/BankButton_4/CenterContainer/Price.text = String(available_sku.price_amount_micros / 1000000.0)

func _on_sku_details_query_error(_response, _error, _sku_details):
	_on_connected()

func _on_purchases_updated(purchases):
	for purchase in purchases:
		if !purchase.is_acknowledged:
			tokens[purchase.purchase_token] = purchase.sku
			payment.consumePurchase(purchase.purchase_token)

func _on_purchase_consumed(purchase):
	if tokens[purchase] == "coin_1":
		Global.coins += coins_1_reward
	if tokens[purchase] == "coin_2":
		Global.coins += coins_2_reward
	if tokens[purchase] == "coin_3":
		Global.coins += coins_3_reward
	if tokens[purchase] == "coin_4":
		Global.coins += coins_4_reward
	Global.premium = 1
	AdMob.hide_banner()
	emit_signal("coins_updated")

func _on_PurchasesRefreshTimer_timeout():
	_on_connected()
