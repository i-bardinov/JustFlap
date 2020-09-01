extends Control

export(int) var speed: int = 1000

var is_moving: bool = false

func _process(delta):
	if is_moving:
		$Back.scroll_offset.x -= speed * delta
		$Up.scroll_offset.x -= speed * delta
		$Down.scroll_offset.x -= speed * delta

func _on_Player_smash():
	is_moving = false

func _on_Player_start_flying():
	is_moving = true
