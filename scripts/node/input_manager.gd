class_name InputManager
extends Node2D

@onready var gameSM: GameStateMachine = %GameStateMachine

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		gameSM.handle_mouse_button_input(event)
	elif event is InputEventKey:
		gameSM.handle_key_input(event)
