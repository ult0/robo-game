extends Node2D

@export var spawn_locations: Array[Area2D] = []
@export var player_units: Array[UnitResource] = []
var unit_scene: PackedScene = preload("res://scenes/unit.tscn")

func _ready() -> void:
	for i in range(spawn_locations.size()):
		var unit: Unit = unit_scene.instantiate()
		unit.unit_resource = player_units[i]
		unit.global_position = spawn_locations[i].global_position
		unit.name = unit.unit_resource.name + str(i)
		add_child(unit)
