extends Control

signal close

var _Utils = preload("res://scripts/core/utils.gd")

func _on_Darkening_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal('close')

