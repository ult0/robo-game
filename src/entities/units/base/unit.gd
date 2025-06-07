class_name Unit
extends Node2D

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@export var unit_resource: UnitResource

var tile_coord: Vector2i:
	get:
		return TileMapUtils.get_tile_coord(global_position)

var unit_components: Dictionary[String, UnitComponent] = {}

var tween: Tween
var aStar: AStar

var walkable_tiles: Array[Vector2i] = []
var attackable_tiles: Array[Vector2i] = []
var friendly_tiles: Array[Vector2i] = []

func _ready() -> void:
	aStar = AStar.create(is_walkable)
	setup_animation()

	for child in get_children():
		if child is UnitComponent:
			child.setup(self)
			unit_components[child.name] = child

func setup_animation() -> void:
	animatedSprite.sprite_frames = unit_resource.animation_resource
	animatedSprite.play("idle")

func tile_contains_opposing_unit(_coord: Vector2i) -> bool:
	printerr("tile_contains_opposing_unit not implemented in Unit base class")
	return false

func tile_contains_friendly_unit(_coord: Vector2i) -> bool:
	printerr("tile_contains_friendly_unit not implemented in Unit base class")
	return false

func update_action_tiles() -> void:
	walkable_tiles.clear()
	attackable_tiles.clear()
	friendly_tiles.clear()

	for tile in get_walkable_tiles(tile_coord):
		if tile_contains_friendly_unit(tile) and tile != tile_coord:
			friendly_tiles.append(tile)
		else:
			walkable_tiles.append(tile)
	attackable_tiles = get_attackable_tiles(walkable_tiles)

# SELECT
signal selected(selected: bool)
var is_selected: bool = false:
	set(value):
		is_selected = value
		update_action_tiles()
		selected.emit(is_selected)
func select() -> void:
	is_selected = true
func unselect() -> void:
	is_selected = false

# MOVE
@export var moves_per_second: float = 5.0

signal moving(moving: bool)
var is_moving: bool = false:
	set(value):
		is_moving = value
		if is_moving:
			animatedSprite.play("walk")
		else:
			update_action_tiles()
			animatedSprite.play("idle")
		moving.emit(is_moving)

func move(coords) -> void:
	if coords.size() == 0:
		is_moving = false
		return
	var coord = coords.pop_back()

	if tween:
		tween.kill()
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "global_position", TileMapUtils.get_tile_center_position_from_coord(coord), 1.0 / moves_per_second).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(move.bind(coords))

func move_to(coord: Vector2i) -> void:
	var path := aStar.find_path(tile_coord, coord)
	if path.size() <= unit_resource.move_speed:
		is_moving = true
		move(path)

func is_walkable(coord: Vector2i) -> bool:
	var containsObstacle := Level.instance.tile_contains_obstacle(coord)
	var exists := Level.instance.tile_contains_navtile(coord)
	return exists and !containsObstacle and !tile_contains_opposing_unit(coord)

func get_walkable_tiles(coord: Vector2i) -> Array[Vector2i]:
	return TileMapUtils.get_tiles_in_range(
		[coord],
		unit_resource.move_speed,
		is_walkable
	)

# ATTACK
signal attacking(moving: bool)
var is_attacking: bool = false:
	set(value):
		is_attacking = value
		if is_attacking:
			animatedSprite.play("attack")
		else:
			animatedSprite.play("idle")
		attacking.emit(is_attacking)

func get_attackable_tiles(starting_tiles: Array[Vector2i]) -> Array[Vector2i]:
	return TileMapUtils.get_tiles_in_range(
		starting_tiles,
		unit_resource.attack_range,
		Level.instance.tile_contains_navtile,
		tile_contains_friendly_unit
	)

# DAMAGE
signal damaged(amount: int)
var is_damaged: bool = false:
	get:
		return unit_resource.health < unit_resource.max_health
	set(value):
		is_damaged = true
		animatedSprite.play("take_damage")
func damage(attempted_amount: int) -> void:
	var amount: int = attempted_amount
	if unit_resource.health - attempted_amount < 0:
		amount = unit_resource.health

	unit_resource.health -= amount

	if unit_resource.health > 0:
		is_damaged = true
		damaged.emit(amount)
	else:
		unit_resource.health = 0
		die()

# HEAL
signal healed(amount: int)
func heal(attempted_amount: int) -> void:
	var amount: int = attempted_amount
	if unit_resource.max_health > unit_resource.health + attempted_amount:
		amount = unit_resource.max_health - unit_resource.health
	unit_resource.health += amount
	healed.emit(amount)

# DEATH
signal died(unit: Unit)
var dead: bool = false:
	get:
		return unit_resource.health <= 0
	set(value):
		dead = value
		if dead:
			died.emit(self)
			animatedSprite.play("die")
func die() -> void:
	dead = true
