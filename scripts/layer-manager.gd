extends Node2D

@onready var navigationLayer: TileMapLayer = %NavigationLayer
@onready var obstacleLayer: TileMapLayer = %ObstacleLayer
@onready var debugLayer: TileMapLayer = %DebugLayer
@onready var uiLayer: TileMapLayer = %UILayer

var last_tile: Vector2i = Vector2i.MAX

func _process(_delta: float) -> void:
	var mouse_position = get_global_mouse_position() - navigationLayer.transform.origin
	var map_position = uiLayer.local_to_map(mouse_position)
	if is_instance_valid(uiLayer) and last_tile != map_position:
		uiLayer.erase_cell(last_tile)
		uiLayer.set_cell(map_position, 0, Vector2i(0, 0))
		last_tile = map_position
	

