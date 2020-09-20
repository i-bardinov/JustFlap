extends Node2D

signal score_point

enum State { Stop, Move }

var state = State.Stop
var scored: bool = false
var speed: float = 0.0
var move_direction: int = -1
var pipe_border_up: float = 0.0
var pipe_border_down: float = 0.0
var is_moving_up_down: bool = false setget set_moving_up_down

func _ready():
	state = State.Move

func _process(delta):
	if state == State.Move:
		position.x -= speed * delta
		if is_moving_up_down:
			position.y += move_direction * speed / 2.0 * delta
			if position.y < pipe_border_up:
				move_direction = 1
			if position.y > pipe_border_down:
				move_direction = -1

func set_speed(eff_speed: float):
	speed = eff_speed

func set_moving_up_down(moving: bool):
	is_moving_up_down = moving
	pipe_border_up = $PipeUp/Pipe1.position.y + position.y
	pipe_border_down = $PipeDown/Pipe1.position.y + position.y

func stop():
	state = State.Stop

func _on_PipeUp_body_entered(body):
	_on_entered(body)

func _on_PipeDown_body_entered(body):
	_on_entered(body)

func _on_entered(body):
	if state == State.Move:
		body.bump_into_pipe()
		#eff_speed = speed

func _on_ScoreArea_body_exited(body):
	if not scored and body.is_alive():
		emit_signal('score_point')
		scored = true
		$Score.play()
