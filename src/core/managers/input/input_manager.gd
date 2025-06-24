class_name InputManager
extends Node2D

@onready var gameSM: GameStateMachine = %GameStateMachine
@onready var camera: Camera = %Camera

# Using process for continuous input
func _process(delta: float) -> void:
	if not gameSM.currently_interactable:
		return
	# CAMERA
	for action in camera.input_actions:
		if Input.is_action_pressed(action):
			camera.handle_input(delta)
			break

# Using unhandled input for discrete inputs
func _unhandled_input(event: InputEvent) -> void:
	# MOUSE
	if event is InputEventMouseButton and (event.pressed):
		gameSM.handle_mouse_button_input(event)
	# KEYS
	elif event is InputEventKey:
		gameSM.handle_key_input(event)
