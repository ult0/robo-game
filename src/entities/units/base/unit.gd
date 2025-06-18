class_name Unit
extends Node2D

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@export var unit_resource: UnitResource

var tile_coord: Vector2i:
	get:
		return TileMapUtils.get_tile_coord(global_position)

var unit_components: Dictionary[String, UnitComponent] = {}

var aStar: AStar

var walkable_tile_dict: Dictionary[Vector2i, int] = {}
var walkable_tiles: Array[Vector2i]: 
	get: return walkable_tile_dict.keys()
var attackable_tile_dict: Dictionary[Vector2i, int] = {}
var attackable_tiles: Array[Vector2i]:
	get: return attackable_tile_dict.keys()
var friendly_tile_dict: Dictionary[Vector2i, int] = {}
var friendly_tiles: Array[Vector2i]:
	get: return friendly_tile_dict.keys()

func _ready() -> void:
	# TODO: Change AStar to take in additional arguments for walkable overrides
	# Potentially will make more sense after introducing unit state machine
	aStar = AStar.create()
	EventBus.unit_action_completed_connect(update)
	setup_animation()

	for child in get_children():
		if child is UnitComponent:
			child.setup(self)
			unit_components[child.name] = child

func setup_animation() -> void:
	animatedSprite.sprite_frames = unit_resource.animation_resource
	animatedSprite.play("idle")

func update() -> void:
	update_action_tiles()

#region NAVIGATION

func get_walkable_path(coord: Vector2i) -> Array[Vector2i]:
	return aStar.find_path(tile_coord, coord, is_walkable)

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

	var walkable_and_friendly_tile_dict = get_walkable_and_friendly_tiles(tile_coord)
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

func get_walkable_and_friendly_tiles(coord: Vector2i) -> Dictionary[Vector2i, int]:
	return TileMapUtils.get_tiles_in_range_with_distances(
		[coord],
		unit_resource.movement,
		is_walkable
	)

func get_walkable_tiles(coord: Vector2i) -> Dictionary[Vector2i, int]:
	return TileMapUtils.get_tiles_in_range_with_distances(
		[coord],
		unit_resource.movement,
		is_walkable,
		tile_contains_friendly_unit
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
		selected.emit(is_selected)
func select() -> void:
	z_index += 1
	is_selected = true
func unselect() -> void:
	z_index -= 1
	is_selected = false
#endregion

#region MOVE
signal moving(moving: bool)
var is_moving: bool = false:
	set(value):
		is_moving = value
		if is_moving:
			animatedSprite.play("walk")
		else:
			animatedSprite.play("idle")
		moving.emit(is_moving)

var move_tween: Tween
func move_through(path: Array[Vector2i]) -> bool:
	if path.size() == 0 or path.size() > unit_resource.movement:
		return false
	if move_tween:
		move_tween.kill()
	move_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	is_moving = true
	# Visually move the sprite but instantly move the unit to avoid two units going to same tile
	var temp = global_position
	global_position = TileMapUtils.get_tile_center_position_from_coord(path[0])
	animatedSprite.global_position = temp

	for i in range(path.size() -1, -1, -1):
		move_tween.tween_property(
			animatedSprite, 
			"global_position",
			TileMapUtils.get_tile_center_position_from_coord(path[i]), 
			1.0 / Constants.MOVES_PER_SECOND).set_trans(Tween.TRANS_SINE)
	await move_tween.finished
	unit_resource.movement -= path.size()
	is_moving = false
	if tile_coord == path[0]:
		return true
	else:
		printerr(self.name, " failed to move_through to ", path[0])
		return false

func move_to(coord: Vector2i) -> bool:
	if is_moving or coord == null or not can_move_to(coord):
		return false
	var path: Array[Vector2i] = get_walkable_path(coord)
	await move_through(path)
	print("Finished moving to: ", coord)
	return true

func move_towards(coord: Vector2i) -> bool:
	var path: Array[Vector2i] = get_tile_path(coord)
	if path.size() > 0:
		while not can_move_to(path[0]):
			if path.size() > 0:
				path.pop_front()
			else:
				break

			if path.is_empty():
				break
	
	if path.size() > 0:
		await move_through(path)
		return true
	else:
		print(self.name, " unable to move towards ", coord)
		return false

func can_move_to(coord: Vector2i):
	return walkable_tiles.has(coord)
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
	var max_attack_range_coord: Vector2i = Vector2i.MAX
	var distance: int = max_attack_range_coord.x
	for coord in walkable_tiles:
		if can_attack_from(target, coord) and walkable_tile_dict[coord] < distance:
			distance = walkable_tile_dict[coord]
			max_attack_range_coord = coord
	return max_attack_range_coord

func can_attack_from(target: Vector2i, starting_tile: Vector2i = tile_coord) -> bool:
	var attack_range: Dictionary[Vector2i, int] = get_attackable_tiles([starting_tile])
	return attack_range.has(target)

func can_attack_after_moving(target: Vector2i) -> bool:
	return attackable_tiles.has(target)
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
