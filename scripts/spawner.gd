extends Area2D
class_name Spawner

@export var unit_resource: UnitResource
var unit_scene: PackedScene = preload("res://scenes/unit.tscn")

func _ready() -> void:
	snap_to_grid()

func snap_to_grid() -> void:
	var center_position = TileMapUtils.get_tile_center_position(global_position)
	global_position = center_position

func spawn_unit(script: Script) -> Unit:
	var unit := unit_scene.instantiate()
	unit.set_script(script)
	unit.unit_resource = unit_resource
	unit.global_position = global_position
	unit.name = unit_resource.name + str(unit.get_instance_id())
	return unit
