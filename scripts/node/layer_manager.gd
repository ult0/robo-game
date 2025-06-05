class_name LayerManager
extends Node2D

var navigationLayer: TileMapLayer
var obstacleLayer: TileMapLayer
var debugLayer: TileMapLayer
var unitPreviews: Node2D
var uiLayer: TileMapLayer

func _ready() -> void:
	navigationLayer = find_child("NavigationLayer")
	obstacleLayer = find_child("ObstacleLayer")
	debugLayer = find_child("DebugLayer")
	unitPreviews = find_child("UnitPreviews")
	uiLayer = find_child("UILayer")

	EventBus.unit_spawned_connect(add_unit_preview_layer)

func add_unit_preview_layer(unit: Unit):
	var existingLayer = unitPreviews.find_child(unit.preview_layer.name)
	if unit and unit.preview_layer and not existingLayer:
		unitPreviews.add_child(unit.preview_layer)
