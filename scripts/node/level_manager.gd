extends Node2D
class_name Level
static var instance: Level

var layerManager: LayerManager
var tileSelector: TileSelector
var unitManager: UnitManager

var player_units: Array[Player] = []
var enemy_units: Array[Enemy] = []

var aStar: AStar

func _init() -> void:
	if !instance:
		instance = self

func _ready() -> void:
	layerManager = find_child("LayerManager")
	tileSelector = layerManager.uiLayer.find_child("TileSelector")
	unitManager = find_child("UnitManager")

	aStar = AStar.create(
		is_walkable,
		layerManager.debugLayer
	)

func is_walkable(coord: Vector2i) -> bool:
	var containsObstacle := tile_contains_obstacle(coord)
	var containsEnemy := tile_contains_enemy(coord)
	var exists := tile_contains_navtile(coord)
	return exists and !containsObstacle and !containsEnemy

func tile_contains_player(coord: Vector2i) -> bool:
	return !!unitManager.get_player_at_coord(coord)

func tile_contains_enemy(coord: Vector2i) -> bool:
	return !!unitManager.get_enemy_at_coord(coord)
		
func tile_contains_unit(coord: Vector2i) -> bool:
	return !!unitManager.get_unit_at_coord(coord)

func tile_contains_obstacle(coord: Vector2i) -> bool:
	return layerManager.obstacleLayer.get_cell_tile_data(coord) != null

func tile_contains_navtile(coord: Vector2i) -> bool:
	return layerManager.navigationLayer.get_cell_tile_data(coord) != null
