extends Node2D

@export var spawn_locations: Array[Marker2D] = []
@export var player_units: Array[UnitResource] = []

var current_units: Array[Unit] = []
var selected_unit: Unit = null
var unit_scene: PackedScene = preload("res://scenes/unit.tscn")

func _ready() -> void:
	EventBus.unit_selected.connect(func (unit: Unit) -> void: selected_unit = unit)
	for i in range(spawn_locations.size()):
		var unit: Unit = unit_scene.instantiate()
		unit.unit_resource = player_units[i]
		unit.global_position = spawn_locations[i].global_position
		unit.name = unit.unit_resource.name + str(i)
		current_units.push_back(unit)
		add_child(unit)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and selected_unit:
		var mouse_position = get_global_mouse_position()
		var global_tile_position = Navigation.NavigationLayer.local_to_map(mouse_position) * Navigation.NavigationLayer.tile_set.tile_size
		selected_unit.move_to(global_tile_position)
