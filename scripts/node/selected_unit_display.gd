extends Control

@onready var selectedPlayerIcon: TextureRect = %SelectedPlayerIcon
@onready var healthLabel: Label = %HealthLabel
@onready var maxHealthLabel: Label = %MaxHealthLabel
@onready var attackLabel: Label = %AttackLabel

var selected_unit: Unit = null
var show_unit: bool = false:
	set(show):
		show_unit = show
		visible = show_unit


func on_unit_selected(unit: Unit) -> void:
	if unit == null:
		show_unit = false
		return
	else:
		selected_unit = unit
		show_unit = true
		print("Showing Unit: ", unit.unit_resource.name)
		selectedPlayerIcon.texture = unit.animatedSprite.sprite_frames.get_frame_texture("idle", 0)
		healthLabel.text = str(unit.unit_resource.health)
		maxHealthLabel.text = str(unit.unit_resource.max_health)
		attackLabel.text = str(unit.unit_resource.attack)


func _ready() -> void:
	EventBus.unit_selected.connect(func (unit) -> void: on_unit_selected(unit))
	show_unit = false



