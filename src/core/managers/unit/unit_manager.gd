extends Node2D
class_name UnitManager

var player_group: UnitGroup
var selected_player: Player:
	get: return player_group.selected_unit

var enemy_group: UnitGroup
var selected_enemy: Enemy:
	get:
		return enemy_group.selected_unit

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

func resolve_combat(attacker: Unit, target: Unit) -> void:
	if not attacker.can_attack_from(target.tile_coord):
		await attacker.move_to(attacker.get_max_attack_range_coord(target.tile_coord))

	var damage = calculate_damage(attacker, target)

	print("Attacker: ", attacker.name, " attacks Target: ", target.name, " and deals ", damage, " damage")

	await attacker.attack()

	await target.damage(damage)

	if target.dead:
		print(target.name, " died!")

func handle_enemy_turn(enemy: Enemy) -> void:
	# Find nearest player
	print(enemy, " looking for nearest player...")
	var target: Unit = enemy.choose_target(player_group.current_units)
	if not target:
		print("No target found!")
		return

	# If possible, attack nearest player
	if enemy.can_attack_after_moving(target.tile_coord):
		print(enemy, " attacking nearest player...")
		await resolve_combat(enemy, target)
	# Otherwise, move towards nearest player
	else:
		print(enemy, " moving towards nearest player...")
		await enemy.move_towards(target.tile_coord)

func calculate_damage(attacker: Unit, target: Unit) -> int:
	return maxi(0, attacker.unit_resource.attack - target.unit_resource.defense)

func are_all_enemies_dead() -> bool:
	return enemy_group.current_units.is_empty() and enemy_group.spawners.size() == enemy_group.dead_units.size()

func are_all_players_dead() -> bool:
	return player_group.current_units.is_empty() and player_group.spawners.size() == player_group.dead_units.size()

func move_player_to_coord(coord: Vector2i) -> void:
	await player_group.move_unit_to_coord(coord)

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
