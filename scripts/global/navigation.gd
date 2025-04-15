extends Node

var NavigationLayer: TileMapLayer
var ObstacleLayer: TileMapLayer
var DebugLayer: TileMapLayer
var OverlayLayer: TileMapLayer
var UILayer: TileMapLayer
var tileSelector: TileSelector

var unitManager: UnitManager

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []

var aStar: AStar

func _ready() -> void:
	var sceneTree := get_tree()
	var currentScene := sceneTree.current_scene
	NavigationLayer = currentScene.find_child("NavigationLayer")
	ObstacleLayer = currentScene.find_child("ObstacleLayer")
	DebugLayer = currentScene.find_child("DebugLayer")
	OverlayLayer = currentScene.find_child("OverlayLayer")
	UILayer = currentScene.find_child("UILayer")
	tileSelector = UILayer.find_child("TileSelector")

	unitManager = currentScene.find_child("UnitManager")

	aStar = AStar.create(
		NavigationLayer, 
		is_walkable,
		DebugLayer
	)

func is_walkable(coord: Vector2) -> bool:
	var containsObstacle := tile_contains_obstacle(coord)
	return !containsObstacle

func tile_contains_player(coord: Vector2) -> bool:
	for unit in unitManager.player_group.current_units:
		if TileMapUtils.get_tile_coord(unit.global_position) == TileMapUtils.get_tile_coord(coord):
			return true
	return false

func tile_contains_enemy(coord: Vector2) -> bool:
	for unit in unitManager.enemy_group.current_units:
		if TileMapUtils.get_tile_coord(unit.global_position) == TileMapUtils.get_tile_coord(coord):
			return true
	return false

func tile_contains_unit(coord: Vector2) -> bool:
	return tile_contains_player(coord) or tile_contains_enemy(coord)

func tile_contains_obstacle(coord: Vector2) -> bool:
	return ObstacleLayer.get_cell_tile_data(ObstacleLayer.local_to_map(coord)) != null
