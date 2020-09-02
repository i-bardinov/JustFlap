extends Node2D

signal reset
signal tutorial_start
signal score_updated(score)
signal game_over
signal game_continue

onready var pipe_scene = load("res://scenes/objects/pipes.tscn")
onready var coin_scene = load("res://scenes/objects/coin.tscn")
onready var Player = get_node("Player/Player")

export (float) var base_pipe_timer = 3
export (float) var delta_pipe_timer = 0.03
export (float) var min_pipe_timer = 1.5
export (float) var pipe_screen_gap = 3.0
export (float) var coin_screen_gap = 2.0
export (float) var speed = 170.0
export (float) var speed_increasing = 0.02
export (int) var coin_min_pipe = 1
export (int) var coin_max_pipe = 3
export (int) var banner_starts_required = 2

var decreased_timer: float = 0
var eff_speed = speed
var pipes_for_coin: int = 0
var pipes_generated: int = 0
var was_revived: bool = false

func _ready():
	randomize()
	emit_signal("score_updated", Global.score)
	_on_Menu_replay()

func _physics_process(_delta):
	if Player.state == Player.State.Flying:
		eff_speed += speed_increasing

func _on_PipeGeneratorTimer_timeout():
	decreased_timer -= delta_pipe_timer
	decreased_timer = max(decreased_timer, min_pipe_timer)
	$Timers/PipeGeneratorTimer.start(decreased_timer)
	generate_new_pipe(false)
	remove_old_objects()

func _on_Player_start_flying():
	if not was_revived:
		eff_speed = speed
	was_revived = false
	pipes_for_coin = int(round(randi() % coin_max_pipe + coin_min_pipe))
	$Timers/FirstPipeGeneratorTimer.start()
	$Timers/TutorialTimer.stop()
	if not $AdMob.is_rewarded_ad_loaded():
		$AdMob.load_rewarded_ad()
	if not $AdMob.is_banner_loaded() and Global.start_count >= banner_starts_required:
		$AdMob.load_banner()

func generate_new_pipe(in_center: bool):
	var pipe = pipe_scene.instance() as Node2D
	pipe.scale = Vector2(2, 2)
	pipe.set_speed(eff_speed)
	var pipe_gap = int(round(get_viewport_rect().size.y / pipe_screen_gap))
	pipe.position.x = get_viewport_rect().size.x * 1.5
	pipe.position.y = get_viewport_rect().size.y / 2.0
	if not in_center:
		 pipe.position.y += randi() % pipe_gap - round(pipe_gap / 2.0)
	pipe.connect("score_point", self, "_on_score_point")
	if not in_center and randi() % int(max(50 - Global.score, 2)) == 0:
		pipe.set_moving_up_down(true)
	$Objects/GeneratedObjects.add_child(pipe)
	pipes_generated += 1
	if not in_center:
		if pipes_generated >= pipes_for_coin and $Timers/CoinTimer.is_stopped():
			var coin_time = decreased_timer / 2.0 + (randf() - 0.5) * 0.5
			$Timers/CoinTimer.start(coin_time)

func generate_new_coin():
	pipes_generated = 0
	pipes_for_coin = int(round(randi() % coin_max_pipe + coin_min_pipe))
	var coin = coin_scene.instance()
	coin.scale = Vector2(3, 3)
	coin.set_speed(eff_speed)
	coin.connect("coin_taken", $HUD/Menu, "_on_coin_taken")
	var coin_gap = int(round(get_viewport_rect().size.y / coin_screen_gap))
	coin.position.x = get_viewport_rect().size.x * 1.5
	coin.position.y = get_viewport_rect().size.y / 2.0 + randi() % coin_gap - round(coin_gap / 2.0)
	$Objects/GeneratedObjects.add_child(coin)

func remove_old_objects():
	for child in $Objects/GeneratedObjects.get_children():
		if child.position.x <= -get_viewport_rect().size.x:
			child.queue_free()

func remove_objects():
	for child in $Objects/GeneratedObjects.get_children():
		child.queue_free()

func _on_Player_smash():
	Global.death_count += 1
	$Timers/PipeGeneratorTimer.stop()
	$Timers/CoinTimer.stop()
	$Timers/MenuTimer.start()
	for child in $Objects/GeneratedObjects.get_children():
		child.stop()

func _on_score_point():
	Global.score += 1
	emit_signal("score_updated", Global.score)

func _on_Menu_replay():
	emit_signal("reset")

func _on_MenuTimer_timeout():
	emit_signal("game_over")

func _on_FirstPipeGeneratorTimer_timeout():
	generate_new_pipe(true)
	decreased_timer = base_pipe_timer
	$Timers/PipeGeneratorTimer.start(decreased_timer)

func _on_TutorialTimer_timeout():
	emit_signal("tutorial_start")

func _on_CoinTimer_timeout():
	generate_new_coin()

func _on_Level_reset():
	Global.matches_count += 1
	Global.score = 0
	Global.death_count = 0
	pipes_generated = 0
	eff_speed = speed
	remove_objects()
	$Timers/TutorialTimer.start()

func _on_Level_game_continue():
	remove_objects()
	was_revived = true
	$ContinueSound.play()

func _on_Menu_watch_rewarded_ad():
	$AdMob.show_rewarded_ad()

func _on_AdMob_initialization_complete():
	if Global.start_count >= banner_starts_required:
		$AdMob.load_banner()
	$AdMob.load_rewarded_ad()

func _on_AdMob_banner_ad_failed_to_load(error_code):
	print("Error in AdMob: " + error_code)

func _on_AdMob_rewarded_ad_closed():
	$AdMob.load_rewarded_ad()

func _on_Menu_continue_game():
	emit_signal("game_continue")

func _on_Bank_watch_rewarded_ad():
	$AdMob.show_rewarded_ad()

func _on_Settings_bank_closed():
	emit_signal("reset")

func _on_Settings_bank(callback):
	$Timers/TutorialTimer.stop()
