extends Node2D
class_name UnitGroup

enum UnitType {
	Player,
	Enemy
}
@export var type: UnitType = UnitType.Player
var current_units: Array[Unit] = []
var selected_unit: Unit = null
var player_script: Script = preload("res://scripts/node/player.gd")
var enemy_script: Script = preload("res://scripts/node/enemy.gd")

func _ready() -> void:
	initialize_units()

func on_unit_selected(unit: Unit) -> void:
	if selected_unit:
		if selected_unit.moving:
			return
		elif selected_unit:
			selected_unit.unselect()
	unit.set_tile_options()
	selected_unit = unit

func on_unit_unselected(unit: Unit) -> void:
	unit.clear_tile_options()
	if selected_unit == unit:
		selected_unit = null

func initialize_units() -> void:
	var spawners: Array[Spawner] = []
	for child in get_children():
		if child is Spawner:
			spawners.push_back(child)
	if spawners.size():
		for i in range(spawners.size()):
			print("Spawning unit: ", spawners[i].unit_resource.name)
			add_unit(spawners[i].spawn_unit(get_unit_script()))
	else:
		printerr("No unit spawners found in UnitGroup: " + name)

func get_unit_script() -> Script:
	if type == UnitType.Player:
		return player_script
	elif type == UnitType.Enemy:
		return enemy_script
	else:
		printerr("Invalid unit type: " + str(type))
		return null

func add_unit(unit: Unit) -> void:
	current_units.push_back(unit)
	add_child(unit)

func remove_unit(unit: Unit) -> void:
	current_units.erase(unit)
	unit.queue_free()

func move_unit_to_coord(coord: Vector2i) -> void:
	if selected_unit and !selected_unit.moving:
		selected_unit.move_to(coord)

func select_unit_at_coord(coord: Vector2i) -> Unit:
	var unit = get_unit_at_coord(coord)
	if unit and unit != selected_unit and !unit.moving:
		unit.select()
		if selected_unit:
			selected_unit.unselect()
		selected_unit = unit
	return unit

func unselect_unit_at_coord(coord: Vector2i) -> Unit:
	var unit = get_unit_at_coord(coord)
	if unit and unit == selected_unit:
		unit.unselect()
		selected_unit = null
	return unit

func is_unit_selected() -> bool:
	return !!selected_unit

func get_unit_at_coord(coord: Vector2i) -> Unit:
	var unit_index = find_unit_index(coord)
	if unit_index != -1:
		return current_units[unit_index]
	else:
		return null

func is_unit_at_coord(coord: Vector2i) -> bool:
	return find_unit_index(coord) != -1

func find_unit_index(coord: Vector2i) -> int:
	return current_units.find_custom(func (unit: Unit) -> bool: return unit.tile_coord == coord)
