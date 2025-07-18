extends Node2D
class_name Level
static var instance: Level

var layerManager: LayerManager
var unitManager: UnitManager

var aStar: AStar

func _init() -> void:
	if !instance:
		instance = self

func _ready() -> void:
	layerManager = find_child("LayerManager")
	unitManager = find_child("UnitManager")

	aStar = AStar.create(
		is_walkable
	)

func is_walkable(coord: Vector2i) -> bool:
	var containsObstacle := tile_contains_obstacle(coord)
	var exists := tile_contains_navtile(coord)
	return exists and !containsObstacle

func tile_contains_player(coord: Vector2i) -> bool:
	var player = unitManager.get_player_at_coord(coord)
	return !!player and not player.dead

func tile_contains_enemy(coord: Vector2i) -> bool:
	var enemy = unitManager.get_enemy_at_coord(coord)
	return !!enemy and not enemy.dead
		
func tile_contains_unit(coord: Vector2i) -> bool:
	var unit = unitManager.get_unit_at_coord(coord)
	return !!unit and not unit.dead

func tile_contains_obstacle(coord: Vector2i) -> bool:
	return layerManager.obstacleLayer.get_cell_tile_data(coord) != null

func tile_contains_navtile(coord: Vector2i) -> bool:
	return layerManager.navigationLayer.get_cell_tile_data(coord) != null
