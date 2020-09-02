extends Control

func _on_Level_tutorial_start():
	show()

func _on_Player_start_flying():
	hide()

func _on_Settings_bank(_callback):
	hide()
