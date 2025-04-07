extends Node

var NavigationLayer: TileMapLayer
var ObstacleLayer: TileMapLayer
var DebugLayer: TileMapLayer
var UILayer: TileMapLayer

var aStar: AStar

func _ready() -> void:
	var CurrentScene = get_tree().current_scene
	NavigationLayer = CurrentScene.find_child("NavigationLayer")
	ObstacleLayer = CurrentScene.find_child("ObstacleLayer")
	DebugLayer = CurrentScene.find_child("DebugLayer")
	UILayer = CurrentScene.find_child("UILayer")

	aStar = AStar.create(
		NavigationLayer, 
		func (coord: Vector2) -> bool: 
			return ObstacleLayer.get_cell_tile_data(ObstacleLayer.local_to_map(coord)) == null,
		DebugLayer
	)

func is_walkable(coord: Vector2) -> bool:
	return ObstacleLayer.get_cell_tile_data(ObstacleLayer.local_to_map(coord)) == null
