extends Node2D
class_name UnitManager

var player_group: UnitGroup
var enemy_group: UnitGroup

func _ready() -> void:
	for child in get_children():
		if child is UnitGroup:
			var unit_group: UnitGroup = child
			if unit_group.unit_type == Constants.UnitType.PLAYER:
				player_group = unit_group
			elif unit_group.unit_type == Constants.UnitType.ENEMY:
				enemy_group = unit_group
			else:
				printerr("UnitManager: Child is not a UnitGroup or has an invalid type: " + child.name)
	print("Player units: ", player_group.current_units)
	print("Enemy units: ", enemy_group.current_units)

func move_player_to_coord(coord: Vector2i) -> void:
	player_group.move_unit_to_coord(coord)

func move_enemy_to_coord(coord: Vector2i) -> void:
	enemy_group.move_unit_to_coord(coord)

func select_unit_at_coord(coord: Vector2i) -> Unit:
	var player = select_player_at_coord(coord)
	var enemy = select_enemy_at_coord(coord)
	if player: return player
	if enemy: return enemy
	return null

func select_player_at_coord(coord: Vector2i) -> Player:
	return player_group.select_unit_at_coord(coord)

func select_enemy_at_coord(coord: Vector2i) -> Enemy:
	return enemy_group.select_unit_at_coord(coord)

func is_player_selected() -> bool:
	return player_group.is_unit_selected()

func is_enemy_selected() -> bool:
	return enemy_group.is_unit_selected()

func unselect_unit_at_coord(coord: Vector2i) -> Unit:
	var player = unselect_player_at_coord(coord)
	var enemy = unselect_enemy_at_coord(coord)
	if player: return player
	if enemy: return enemy
	return null

func unselect_player_at_coord(coord: Vector2i) -> Player:
	return player_group.unselect_unit_at_coord(coord)

func unselect_current_selected_player() -> Player:
	return player_group.unselect_current_selected_unit()

func unselect_enemy_at_coord(coord: Vector2i) -> Enemy:
	return enemy_group.unselect_unit_at_coord(coord)

func unselect_current_selected_enemy() -> Enemy:
	return enemy_group.unselect_current_selected_unit()

func get_unit_at_coord(coord: Vector2i) -> Unit:	
	var player: Player = get_player_at_coord(coord)
	var enemy: Enemy = get_enemy_at_coord(coord)
	if player: return player
	elif enemy: return enemy
	return null

func get_player_at_coord(coord: Vector2i) -> Player:
	if is_player_at_coord(coord):
		return player_group.get_unit_at_coord(coord)
	return null

func get_enemy_at_coord(coord: Vector2i) -> Enemy:
	if is_enemy_at_coord(coord):
		return enemy_group.get_unit_at_coord(coord)
	return null

func is_unit_at_coord(coord: Vector2i) -> bool:
	return is_player_at_coord(coord) or is_enemy_at_coord(coord)

func is_player_at_coord(coord: Vector2i) -> bool:
	return player_group.is_unit_at_coord(coord)

func is_enemy_at_coord(coord: Vector2i) -> bool:
	return enemy_group.is_unit_at_coord(coord)
