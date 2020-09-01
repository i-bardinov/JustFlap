extends Node2D

enum State { Stop, Move }

signal coin_taken

var state = State.Stop
var speed: float = 0.0
var taken: bool = false

func _on_Coin_body_entered(_body):
	if not taken:
		$Taken.play()
		visible = false
		taken = true
		emit_signal("coin_taken")

func _ready():
	state = State.Move

func _physics_process(delta):
	if state == State.Move:
		position.x -= speed * delta

func set_speed(eff_speed: float):
	speed = eff_speed

func stop():
	state = State.Stop
