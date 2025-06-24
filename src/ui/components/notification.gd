@tool
extends Panel

@onready var label: Label = %Label

func _ready() -> void:
	visible = false

var show_tween: Tween
func show_notification(text: String) -> void:
	label.text = text
	visible = true

	if show_tween:
		show_tween.kill()
		visible = false

	var viewport_transform = get_viewport_transform()
	print(viewport_transform)

	show_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	# show_tween.tween_property(self, "global_position")
	



