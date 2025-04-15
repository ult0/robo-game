extends Area2D
class_name Spawner

@export var unit_resource: UnitResource
var unit_scene: PackedScene = preload("res://scenes/unit.tscn")

func _ready() -> void:
	snap_to_grid()

func snap_to_grid() -> void:
	var tile_position = Navigation.NavigationLayer.local_to_map(global_position)
	var center_position = Navigation.NavigationLayer.map_to_local(tile_position)
	global_position = center_position

func spawn_unit() -> Unit:
	var unit: Unit = unit_scene.instantiate()
	unit.unit_resource = unit_resource
	unit.global_position = global_position
	unit.name = unit_resource.name + str(unit.get_instance_id())
	return unit

