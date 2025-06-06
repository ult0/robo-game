extends Node
class_name PreviewComponent

@onready var preview_layer: TileMapLayer = $PreviewLayer
@onready var preview_arrow: Node2D = $PreviewArrow

@export var walk_tile_coord: Vector2i = Vector2i(21, 5)
@export var attack_tile_coord: Vector2i = Vector2i(22, 4)
@export var friendly_tile_coord: Vector2i = Vector2i(22, 5)

# Should be set by unit before entering layer manager
var unit: Unit
var tiles_to_show: Dictionary[Vector2i, Array]
var tile_order: Array[Vector2i]
var unit_walkable_tiles: Array[Vector2i] = []
var unit_friendly_tiles: Array[Vector2i] = []
var unit_attackable_tiles: Array[Vector2i] = []

var selector_coord: Vector2i

func _ready() -> void:
	EventBus.selector_coord_changed_connect(on_tile_selector_entered)

func on_tile_selector_entered(coord: Vector2i) -> void:
	selector_coord = coord
	preview_arrow.redraw(selector_coord)

func update() -> void:
	if unit.is_selected or unit.force_show_attack_range:
		preview_layer.clear()
		draw_all_tiles()
		preview_layer.enabled = true
		preview_arrow.redraw(selector_coord)
	else:
		preview_layer.clear()
		preview_layer.enabled = false
		preview_arrow.redraw(selector_coord)

func draw_all_tiles() -> void:
	for tile_type in tile_order:
		match tile_type:
			attack_tile_coord:
				draw_tiles(unit_attackable_tiles, tile_type)
			walk_tile_coord:
				draw_tiles(unit_walkable_tiles, tile_type)
			friendly_tile_coord:
				draw_tiles(unit_friendly_tiles, tile_type)

func draw_tiles(tiles: Array[Vector2i], tile_coord: Vector2i) -> void:
	for tile in tiles:
		preview_layer.set_cell(tile, 0, tile_coord, 0)
