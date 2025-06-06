# @tool
extends Area2D
class_name Spawner

@export var unit_resource: UnitResource
var player_scene: PackedScene = preload("uid://2rgqo6x3a48k")
var enemy_scene: PackedScene = preload("uid://dy5vf63kayq5l")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if unit_resource == null:
		warnings.append("Unit resource must be assigned to the spawner")
	if player_scene == null and enemy_scene == null:
		warnings.append("At least one unit scene must be assigned to the spawner")
	return warnings

func _ready() -> void:
	global_position = TileMapUtils.get_tile_center_position(global_position)

func spawn_unit(unit_type: int) -> Unit:
	var unit: Unit
	if unit_type == Constants.UnitType.PLAYER:
		unit = player_scene.instantiate()
	elif unit_type == Constants.UnitType.ENEMY:
		unit = enemy_scene.instantiate()
	unit.unit_resource = unit_resource
	unit.global_position = global_position
	unit.name = unit_resource.name + str(unit.get_instance_id())
	return unit
