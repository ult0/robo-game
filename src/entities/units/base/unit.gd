class_name Unit
extends Node2D

@onready var preview_component: PreviewComponent = $PreviewComponent
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var clickBox: Area2D = $ClickBox
@export var unit_resource: UnitResource

var tile_coord: Vector2i:
	get:
		return TileMapUtils.get_tile_coord(global_position)

@warning_ignore_start("unused_signal")
signal selected(unit: Unit)
signal unselected(unit: Unit)
var is_selected: bool = false
var force_show_attack_range: bool = false
func select() -> void:
	is_selected = true
func unselect() -> void:
	is_selected = false

signal entered_hover(unit: Unit)
signal exited_hover(unit: Unit)

var tween: Tween
var aStar: AStar

func is_walkable(_coord: Vector2i) -> bool:
	return true

@export var moves_per_second: float = 5.0
var moving: bool = false:
	set(value):
		moving = value
		if moving: animatedSprite.play("walk")
		else: animatedSprite.play("idle")

func _ready() -> void:
	setup_animation()
	setup_preview_layer()

func setup_animation() -> void:
	animatedSprite.sprite_frames = unit_resource.animation_resource
	animatedSprite.play("idle")

func setup_preview_layer() -> void:
	preview_component.unit = self

func update_preview_layer() -> void:
	set_preview_tiles()
	preview_component.update()

func set_preview_tiles() -> void: pass

func is_preview_layer_showing() -> bool:
	return preview_component.preview_layer.enabled

func move(coords) -> void:
	if coords.size() == 0:
		moving = false
		update_preview_layer()
		return
	moving = true
	var coord = coords.pop_back()

	if tween:
		tween.kill()
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "global_position", TileMapUtils.get_tile_center_position_from_coord(coord), 1.0 / moves_per_second).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(move.bind(coords))

func move_to(_coord: Vector2i) -> void:
	pass

func enter_hover() -> void:
	entered_hover.emit(self)

func exit_hover() -> void:
	exited_hover.emit(self)

func take_damage(amount: int) -> void:
	unit_resource.health -= amount
	animatedSprite.play("take_damage")
	if unit_resource.health <= 0:
		unit_resource.health = 0
		animatedSprite.play("die")

func heal(amount: int) -> void:
	unit_resource.health += amount
	if unit_resource.health > unit_resource.max_health:
		unit_resource.health = unit_resource.max_health

func die() -> void:
	animatedSprite.play("die")

func is_alive() -> bool:
	return unit_resource.health > 0

func is_dead() -> bool:
	return unit_resource.health <= 0

func is_moving() -> bool:
	return moving

func is_attacking() -> bool:
	return false
