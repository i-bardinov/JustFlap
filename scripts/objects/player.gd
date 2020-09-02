extends KinematicBody2D

signal start_flying
signal smash
signal falling

enum State { None, Idle, Flying, Smash, Falling }

export (int) var jump_speed = -410
export (int) var gravity = 1100
export (int) var push = 240
export (int) var start = 240
export (int) var movement_stopping = -250

var velocity = Vector2()
var state = State.None

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if state == State.Idle:
				start_fly()
			if state == State.Flying:
				velocity.y = jump_speed
				$Sounds/Wing.play()

func _process(delta):
	_input_process()
	_movement_process(delta)

func _input_process():
	if state == State.Flying:
		if Input.is_action_just_pressed("game_up"):
			velocity.y = jump_speed
			$Sounds/Wing.play()
	if state == State.Idle:
		if Input.is_action_just_pressed("game_up"):
			start_fly()

func _movement_process(delta):
	if velocity.x > 0:
		velocity.x += movement_stopping * delta
	if velocity.x < 0:
		velocity.x = 0
	if state == State.Idle:
		velocity = move_and_slide(velocity, Vector2(0, -1))
	if state == State.Flying or state == State.Falling:
		velocity.y += gravity * delta
		if state == State.Falling && is_below_screen():
			velocity.y = 0
		velocity = move_and_slide(velocity, Vector2(0, -1))
	if state == State.Flying:
		if position.x > get_viewport_rect().size.x / 3.0:
			velocity.x = 0;
		if is_below_screen():
			bump_into_pipe()

func start_fly():
	emit_signal('start_flying')

func bump_into_pipe():
	emit_signal('smash')

func is_alive() -> bool:
	return state == State.Idle or state == State.Flying

func is_below_screen() -> bool:
	return position.y > get_viewport_rect().size.y + $Sprite.texture.get_size().y

func _on_Player_start_flying():
	state = State.Flying
	velocity.x = push
	velocity.y = jump_speed
	$Sounds/Swoosh.play()

func _on_Player_smash():
	$AnimationPlayer.stop()
	velocity = Vector2(0, 0)
	state = State.Smash
	$FallTimer.one_shot = true
	$FallTimer.start()
	if not is_below_screen():
		$Sounds/Smash.play()

func _on_FallTimer_timeout():
	$FallTimer.stop()
	if state == State.Smash:
		emit_signal("falling")

func _on_Player_falling():
	$AnimationPlayer.stop()
	state = State.Falling
	$FallSoundTimer.start()

func _on_Level_reset():
	state = State.Idle
	position = Vector2(0, get_viewport_rect().size.y / 2.0)
	velocity = Vector2(start, 0)
	$AnimationPlayer.play("fly")

func _on_Level_game_continue():
	_on_Level_reset()

func _on_FallSoundTimer_timeout():
	$FallSoundTimer.stop()
	$Sounds/Falling.play()
