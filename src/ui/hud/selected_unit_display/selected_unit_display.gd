extends Control

@export var containerTexture: Texture2D
@export var unit_type: Constants.UnitType = Constants.UnitType.PLAYER

@onready var selectedPlayerIcon: TextureRect = %SelectedPlayerIcon
@onready var uiContainer: NinePatchRect = %UIContainer
@onready var healthLabel: Label = %HealthLabel
@onready var maxHealthLabel: Label = %MaxHealthLabel
@onready var attackLabel: Label = %AttackLabel

var selected_unit: Unit

func _ready() -> void:
	uiContainer.texture = containerTexture
	if unit_type == Constants.UnitType.PLAYER:	
		EventBus.player_selected_connect(on_unit_selected)
	elif unit_type == Constants.UnitType.ENEMY:
		EventBus.enemy_selected_connect(on_unit_selected)
	else:
		print("Unknown type: ", unit_type)
	visible = false

func update() -> void:
	selectedPlayerIcon.texture = selected_unit.animatedSprite.sprite_frames.get_frame_texture("idle", 0)
	healthLabel.text = str(selected_unit.unit_resource.health)
	maxHealthLabel.text = str(selected_unit.unit_resource.max_health)
	attackLabel.text = str(selected_unit.unit_resource.attack)

func connect_signals() -> void:
	for signal_method: Signal in [selected_unit.damaged, selected_unit.healed]:
		signal_method.connect(on_unit_info_changed)

func disconnect_signals() -> void:
	for signal_method: Signal in [selected_unit.damaged, selected_unit.healed]:
		signal_method.disconnect(on_unit_info_changed)

func on_unit_info_changed(_arg1 = null, _arg2 = null) -> void:
	update()

func on_unit_selected(unit: Unit) -> void:
	if unit:
		selected_unit = unit
		connect_signals()
		update()
		visible = true
	elif selected_unit:
		disconnect_signals()
		selected_unit = null
		visible = false
		
