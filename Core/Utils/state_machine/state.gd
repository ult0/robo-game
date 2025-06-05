class_name State
extends RefCounted

var state_machine: StateMachine

@warning_ignore_start("unused_parameter")
func update(delta: float) -> void: pass
func enter(args: Variant = {}) -> void: pass
func exit() -> void: pass
func handle_input(event: InputEvent) -> void: pass


