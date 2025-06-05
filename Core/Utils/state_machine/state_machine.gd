class_name StateMachine
extends Node

var current_state: State

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func change_state(new_state: State, args: Variant = {}) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.state_machine = self
	current_state.enter(args)


