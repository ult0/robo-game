extends Control

@export var containerTexture: Texture2D
@export var unit_type: Constants.UnitType = Constants.UnitType.PLAYER

@onready var selectedPlayerIcon: TextureRect = %SelectedPlayerIcon
@onready var uiContainer: NinePatchRect = %UIContainer
@onready var healthLabel: Label = %HealthLabel
@onready var maxHealthLabel: Label = %MaxHealthLabel
@onready var attackLabel: Label = %AttackLabel

var selected_player: Player = null
var selected_enemy: Enemy = null
var show_unit: bool = false:
	set(show):
		show_unit = show
		visible = show_unit

func _ready() -> void:
	uiContainer.texture = containerTexture
	if unit_type == Constants.UnitType.PLAYER:	
		EventBus.player_selected_connect(on_player_selected)
	elif unit_type == Constants.UnitType.ENEMY:
		EventBus.enemy_selected_connect(on_enemy_selected)
	else:
		print("Unknown type: ", unit_type)
	show_unit = false

func on_player_selected(player: Player) -> void:
	if player == null:
		show_unit = false
		return
	else:
		selected_player = player
		show_unit = true
		selectedPlayerIcon.texture = player.animatedSprite.sprite_frames.get_frame_texture("idle", 0)
		healthLabel.text = str(player.unit_resource.health)
		maxHealthLabel.text = str(player.unit_resource.max_health)
		attackLabel.text = str(player.unit_resource.attack)

func on_enemy_selected(enemy: Enemy) -> void:
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
