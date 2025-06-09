extends Area2D
class_name Spawner

@export var unit_resource: UnitResource
@export var player_scene: PackedScene
@export var enemy_scene: PackedScene

func _ready() -> void:
	global_position = TileMapUtils.get_tile_center_position(global_position)

func spawn_unit(unit_type: int) -> Unit:
	var unit: Unit
	if unit_type == Constants.UnitType.PLAYER:
		unit = player_scene.instantiate()
	elif unit_type == Constants.UnitType.ENEMY:
		unit = enemy_scene.instantiate()
	unit.unit_resource = unit_resource.duplicate()
	unit.global_position = global_position
	unit.name = unit_resource.name + str(unit.get_instance_id())
	return unit
