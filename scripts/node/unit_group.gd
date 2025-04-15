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

func _ready() -> void:
	initialize_units()

func on_unit_selected(unit: Unit) -> void:
	selected_unit = unit

func on_unit_unselected(unit: Unit) -> void:
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
			add_unit(spawners[i].spawn_unit())
	else:
		printerr("No unit spawners found in UnitGroup: " + name)

func add_unit(unit: Unit) -> void:
	current_units.push_back(unit)
	unit.selected.connect(on_unit_selected)
	unit.unselected.connect(on_unit_unselected)
	add_child(unit)

func remove_unit(unit: Unit) -> void:
	current_units.erase(unit)
	unit.queue_free()
