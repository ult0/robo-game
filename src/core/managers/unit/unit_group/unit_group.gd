extends Node2D
class_name UnitGroup

var force_show_attack_range: bool = false
@export var unit_type: Constants.UnitType = Constants.UnitType.PLAYER
var spawners: Array[Spawner] = []
var current_units: Array[Unit] = []
var dead_units: Array[Unit] = []
var selected_unit: Unit

func _ready() -> void:
	initialize_units()

func on_unit_selected(unit: Unit) -> void:
	if selected_unit:
		if selected_unit.is_moving:
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
	for child in get_children():
		if child is Spawner:
			spawners.push_back(child)
	if spawners.size():
		for i in range(spawners.size()):
			print("Spawning unit: ", spawners[i].unit_resource.name)
			add_unit(spawners[i].spawn_unit(unit_type))
	else:
		printerr("No unit spawners found in UnitGroup: " + name)

func add_unit(unit: Unit) -> void:
	current_units.push_back(unit)
	add_child(unit)
	unit.died.connect(remove_unit)
	EventBus.unit_spawned_emit(unit)

func remove_unit(unit: Unit) -> void:
	current_units.erase(unit)
	dead_units.append(unit)

func move_unit_to_coord(coord: Vector2i) -> void:
	if selected_unit and !selected_unit.is_moving:
		await selected_unit.move_to(coord)

func select_unit_at_coord(coord: Vector2i) -> Unit:
	var unit = get_unit_at_coord(coord)
	return select_unit(unit)

func select_unit(unit: Unit) -> Unit:
	if unit and unit != selected_unit and !unit.is_moving:
		if selected_unit:
			selected_unit.unselect()
		unit.select()
		selected_unit = unit
	return unit 

func unselect_unit_at_coord(coord: Vector2i) -> Unit:
	var unit = get_unit_at_coord(coord)
	if unit and unit == selected_unit:
		unit.unselect()
		selected_unit = null
	return unit

func unselect_current_selected_unit() -> Unit:
	return unselect_unit(selected_unit)

func unselect_unit(unit: Unit) -> Unit:
	if unit and unit == selected_unit:
		unit.unselect()
		selected_unit = null
	return unit

func show_all_units_attack_range():
	for unit in current_units:
		unit.preview_layer.clear()

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

func set_force_show_attack_range(value: bool) -> void:
	force_show_attack_range = value
	for unit in current_units:
		if "force_show_attack_range" in unit:
			unit.force_show_attack_range = value
