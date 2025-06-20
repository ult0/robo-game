extends CenterContainer

@export var text_label: Label

func _ready() -> void:
	visible = false
	EventBus.level_completed_connect(func () -> void: show_text("Level Completed"))
	EventBus.game_over_connect(func () -> void: show_text("Game Over"))

func show_text(text: String) -> void:
	text_label.text = text
	visible = true


