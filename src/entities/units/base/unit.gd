class_name Unit
extends Node2D

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@export var unit_resource: UnitResource

var tile_coord: Vector2i:
	get:
		return TileMapUtils.get_tile_coord(global_position)

var unit_components: Dictionary[String, UnitComponent] = {}

var aStar: AStar

var walkable_tiles: Array[Vector2i]: 
	get: return walkable_tile_dict.keys()
var attackable_tiles: Array[Vector2i]:
	get: return attackable_tile_dict.keys()
var friendly_tiles: Array[Vector2i] = []:
	get: return friendly_tile_dict.keys()

var walkable_tile_dict: Dictionary[Vector2i, int] = {}
var attackable_tile_dict: Dictionary[Vector2i, int] = {}
var friendly_tile_dict: Dictionary[Vector2i, int] = {}

func _ready() -> void:
	# TODO: Change AStar to take in additional arguments for walkable overrides
	# Potentially will make more sense after introducing unit state machine
	aStar = AStar.create()
	setup_animation()

	for child in get_children():
		if child is UnitComponent:
			child.setup(self)
			unit_components[child.name] = child

func setup_animation() -> void:
	animatedSprite.sprite_frames = unit_resource.animation_resource
	animatedSprite.play("idle")

#region NAVIGATION
var selector_path: Array[Vector2i] = []:
	set(value):
		selector_path = value
		EventBus.selected_player_selector_path_emit(selector_path)
var selector_coord: Vector2i

func on_selector_coord_changed(coord: Vector2i) -> void:
	if is_selected:
		selector_coord = coord
		selector_path = get_tile_path(selector_coord)
		EventBus.selected_player_selector_path_emit(selector_path)

func get_tile_path(coord: Vector2i) -> Array[Vector2i]:
	return aStar.find_path(tile_coord, coord)

func tile_contains_opposing_unit(_coord: Vector2i) -> bool:
	printerr("tile_contains_opposing_unit not implemented in Unit base class")
	return false

func tile_contains_friendly_unit(_coord: Vector2i) -> bool:
	printerr("tile_contains_friendly_unit not implemented in Unit base class")
	return false

func update_action_tiles() -> void:
	walkable_tile_dict.clear()
	attackable_tile_dict.clear()
	friendly_tile_dict.clear()

	var walkable_and_friendly_tile_dict = get_walkable_tiles(tile_coord)
	for tile in walkable_and_friendly_tile_dict:
		if tile_contains_friendly_unit(tile) and tile != tile_coord:
			friendly_tile_dict.set(tile, walkable_and_friendly_tile_dict[tile])
		else:
			walkable_tile_dict.set(tile, walkable_and_friendly_tile_dict[tile])
	attackable_tile_dict = get_attackable_tiles(walkable_tiles)

func is_walkable(coord: Vector2i) -> bool:
	var containsObstacle := Level.instance.tile_contains_obstacle(coord)
	var exists := Level.instance.tile_contains_navtile(coord)
	return exists and !containsObstacle and !tile_contains_opposing_unit(coord)

func get_walkable_tiles(coord: Vector2i) -> Dictionary[Vector2i, int]:
	return TileMapUtils.get_tiles_in_range_with_distances(
		[coord],
		unit_resource.move_speed,
		is_walkable
	)

func get_attackable_tiles(starting_tiles: Array[Vector2i]) -> Dictionary[Vector2i, int]:
	return TileMapUtils.get_tiles_in_range_with_distances(
		starting_tiles,
		unit_resource.attack_range,
		Level.instance.tile_contains_navtile,
		tile_contains_friendly_unit
	)
#endregion

#region SELECT
signal selected(selected: bool)
var is_selected: bool = false:
	set(value):
		is_selected = value
		update_action_tiles()
		if is_selected:
			EventBus.selector_coord_changed_connect(on_selector_coord_changed)
		else:
			EventBus._selector_coord_changed.disconnect(on_selector_coord_changed)
		selected.emit(is_selected)
func select() -> void:
	z_index += 1
	is_selected = true
func unselect() -> void:
	z_index -= 1
	is_selected = false
#endregion

#region MOVE
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

var move_tween: Tween
func move(coords) -> void:
	if move_tween:
		move_tween.kill()
	move_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	for i in range(coords.size() -1, -1, -1):
		move_tween.tween_property(
			animatedSprite, 
			"global_position", 
			TileMapUtils.get_tile_center_position_from_coord(coords[i]), 
			1.0 / moves_per_second).set_trans(Tween.TRANS_SINE)

func move_to(coord: Vector2i) -> void:
	if is_moving or not coord:
		return

	var path: Array[Vector2i] = aStar.find_path(tile_coord, coord)
	
	if path.size() > 0 and path.size() <= unit_resource.move_speed and walkable_tiles.has(coord):
		is_moving = true
		# Visually move the sprite but instantly move the unit to avoid two units going to same tile
		var temp = global_position
		global_position = TileMapUtils.get_tile_center_position_from_coord(coord)
		animatedSprite.global_position = temp

		move(path)
		await move_tween.finished
		print("Finished moving to: ", coord)
		is_moving = false
#endregion

#region ATTACK
signal attacking(attacking: bool)
var is_attacking: bool = false:
	get:
		return animatedSprite.animation == 'attack'

func attack() -> void:
	animatedSprite.play("attack")
	attacking.emit(true)
	await animatedSprite.animation_finished
	animatedSprite.play("idle")
	attacking.emit(false)

func get_max_attack_range_coord(target: Vector2i):
	var walkable_tiles_with_move_cost: Dictionary[Vector2i, int] = TileMapUtils.get_tiles_in_range_with_distances(
		[tile_coord],
		unit_resource.move_speed,
		is_walkable,
		Level.instance.tile_contains_player
	)
	var max_attack_range_coord: Vector2i = Vector2i.MAX
	var distance: int = max_attack_range_coord.x
	for coord in walkable_tiles_with_move_cost:
		if can_attack(target, coord) and walkable_tiles_with_move_cost[coord] < distance:
			distance = walkable_tiles_with_move_cost[coord]
			max_attack_range_coord = coord
	return max_attack_range_coord

func can_attack(target: Vector2i, from: Vector2i = tile_coord) -> bool:
	var attack_range: Dictionary[Vector2i, int] = get_attackable_tiles([from])
	return attack_range.has(target)

func is_attackable(coord: Vector2i) -> bool:
	return attackable_tiles.has(coord)
#endregion

#region DAMAGE
signal damaged(amount: int)
var is_damaged: bool = false:
	get:
		return unit_resource.health < unit_resource.max_health

func damage(attempted_amount: int) -> void:
	var amount: int = attempted_amount
	if unit_resource.health - attempted_amount < 0:
		amount = unit_resource.health

	unit_resource.health -= amount
	animatedSprite.play("damage")
	damaged.emit(amount)
	await animatedSprite.animation_finished

	if unit_resource.health > 0:
		animatedSprite.play("idle")
	else:
		await die()
#endregion

#region HEAL
signal healed(amount: int)
func heal(attempted_amount: int) -> void:
	var amount: int = attempted_amount
	if unit_resource.max_health > unit_resource.health + attempted_amount:
		amount = unit_resource.max_health - unit_resource.health
	unit_resource.health += amount
	healed.emit(amount)
#endregion

#region DEATH
var death_tween: Tween
signal died(unit: Unit)
var dead: bool = false:
	get:
		return unit_resource.health <= 0
	set(value):
		dead = value
		if dead:
			unselect()
			died.emit(self)
func die() -> void:
	animatedSprite.play("die")
	await animatedSprite.animation_finished
	death_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	death_tween.tween_property(animatedSprite, "modulate", Color(1, 1, 1, 0), 0.5)
	await death_tween.finished
	dead = true
#endregion
