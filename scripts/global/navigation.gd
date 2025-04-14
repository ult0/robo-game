extends Node

var NavigationLayer: TileMapLayer
var ObstacleLayer: TileMapLayer
var DebugLayer: TileMapLayer
var OverlayLayer: TileMapLayer
var UILayer: TileMapLayer

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

	aStar = AStar.create(
		NavigationLayer, 
		is_walkable,
		DebugLayer
	)

	EventBus.update_player_units.connect(func (units) -> void:
		print("Players", units)
		player_units = units)
	EventBus.update_enemy_units.connect(func (units) -> void:
		print("Enemies", units)
		enemy_units = units)

func is_walkable(coord: Vector2, tile = false) -> bool:
	if tile:
		coord = TileMapUtils.get_global_position_from_tile(coord)
	var containsObstacle := ObstacleLayer.get_cell_tile_data(ObstacleLayer.local_to_map(coord)) != null
	var containsUnit := false
	var units := player_units + enemy_units
	for unit in units:
		if NavigationLayer.local_to_map(unit.global_position) == NavigationLayer.local_to_map(coord):
			containsUnit = true
			break
	
	return !containsObstacle and !containsUnit
