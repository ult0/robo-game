extends Node2D
class_name Level
static var instance: Level

var NavigationLayer: TileMapLayer
var ObstacleLayer: TileMapLayer
var DebugLayer: TileMapLayer
var OverlayLayer: TileMapLayer
var UILayer: TileMapLayer
var tileSelector: TileSelector

var unitManager: UnitManager

var player_units: Array[Player] = []
var enemy_units: Array[Enemy] = []

var aStar: AStar

func _init() -> void:
	if !instance:
		instance = self

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
		is_walkable,
		DebugLayer
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
	return ObstacleLayer.get_cell_tile_data(coord) != null

func tile_contains_navtile(coord: Vector2i) -> bool:
	return NavigationLayer.get_cell_tile_data(coord) != null
