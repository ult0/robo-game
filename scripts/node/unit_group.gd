extends Node2D
class_name UnitGroup

enum Type {
	Unit,
	Enemy
}
@export var type: Type = Type.Unit
@export var unit_spawners: Array[Spawner] = []

var current_units: Array[Unit] = []
var selected_unit: Unit = null
var unit_scene: PackedScene = preload("res://scenes/unit.tscn")
var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")

func _ready() -> void:
	var scene: PackedScene
	if type == Type.Unit:
		scene = unit_scene
		EventBus.unit_selected.connect(func (unit: Unit) -> void: selected_unit = unit)
	elif type == Type.Enemy:
		scene = enemy_scene
		EventBus.enemy_selected.connect(func (enemy: Unit) -> void: selected_unit = enemy)
	else:
		print("Unknown type: ", type)

	var children = get_children()
	for child in children:
		if child is Spawner:
			unit_spawners.push_back(child)
		else:
			print("Child is not a Spawner: ", child.name)
	
	for i in range(unit_spawners.size()):
		print("Spawning unit: ", unit_spawners[i].unit_resource.name)
		var unit: Unit = scene.instantiate()
		unit.unit_resource = unit_spawners[i].unit_resource
		unit.global_position = unit_spawners[i].global_position
		unit.name = unit.unit_resource.name + str(i)
		current_units.push_back(unit)
		add_child(unit)

	if type == Type.Unit:
		EventBus.update_player_units.emit(current_units)
	elif type == Type.Enemy:
		EventBus.update_enemy_units.emit(current_units)
	else:
		print("Unknown type: ", type)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and selected_unit and type == Type.Unit:
		selected_unit.move_to(get_global_mouse_position())
