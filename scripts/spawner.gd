extends Area2D
class_name Spawner

@export var unit_resource: UnitResource

func _ready() -> void:
	snap_to_grid()

func snap_to_grid() -> void:
	var tile_position = Navigation.NavigationLayer.local_to_map(global_position)
	var center_position = Navigation.NavigationLayer.map_to_local(tile_position)
	global_position = center_position
