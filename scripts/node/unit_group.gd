extends Node2D
class_name UnitGroup

enum UnitType {
	Player,
	Enemy
}
@export var type: UnitType = UnitType.Player
var current_units: Array[Unit] = []
var selected_unit: Unit = null:
	set(unit):
		unit_selected.emit(unit)
		selected_unit = unit
signal unit_selected(unit: Unit)
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
	unit.selected.connect(on_unit_selected)
	unit.unselected.connect(on_unit_unselected)
	add_child(unit)

func remove_unit(unit: Unit) -> void:
	current_units.erase(unit)
	unit.queue_free()
