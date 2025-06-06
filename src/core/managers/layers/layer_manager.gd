class_name LayerManager
extends Node2D

var navigationLayer: TileMapLayer
var obstacleLayer: TileMapLayer

func _ready() -> void:
	navigationLayer = find_child("NavigationLayer")
	obstacleLayer = find_child("ObstacleLayer")
