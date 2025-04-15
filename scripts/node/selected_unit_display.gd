extends Control

@export var containerTexture: Texture2D
enum Type {
	Unit,
	Enemy
}
@export var type: Type = Type.Unit

@onready var selectedPlayerIcon: TextureRect = %SelectedPlayerIcon
@onready var uiContainer: NinePatchRect = %UIContainer
@onready var healthLabel: Label = %HealthLabel
@onready var maxHealthLabel: Label = %MaxHealthLabel
@onready var attackLabel: Label = %AttackLabel

var selected_unit: Unit = null
var selected_enemy: Unit = null
var show_unit: bool = false:
	set(show):
		show_unit = show
		visible = show_unit

func _ready() -> void:
	uiContainer.texture = containerTexture
	if type == Type.Unit:	
		EventBus.player_selected.connect(func (unit: Unit) -> void: on_unit_selected(unit))
	elif type == Type.Enemy:
		EventBus.enemy_selected.connect(func (enemy) -> void: on_enemy_hover(enemy))
	else:
		print("Unknown type: ", type)
	show_unit = false

func on_unit_selected(unit: Unit) -> void:
	if unit == null:
		show_unit = false
		return
	else:
		selected_unit = unit
		show_unit = true
		selectedPlayerIcon.texture = unit.animatedSprite.sprite_frames.get_frame_texture("idle", 0)
		healthLabel.text = str(unit.unit_resource.health)
		maxHealthLabel.text = str(unit.unit_resource.max_health)
		attackLabel.text = str(unit.unit_resource.attack)

func on_enemy_hover(enemy) -> void:
	if enemy == null:
		show_unit = false
		return
	else:
		selected_enemy = enemy
		show_unit = true
		print("Showing Unit: ", enemy.unit_resource.name)
		selectedPlayerIcon.texture = enemy.animatedSprite.sprite_frames.get_frame_texture("idle", 0)
		healthLabel.text = str(enemy.unit_resource.health)
		maxHealthLabel.text = str(enemy.unit_resource.max_health)
		attackLabel.text = str(enemy.unit_resource.attack)
