class_name PreviewLayer
extends TileMapLayer

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

func update() -> void:
	if unit.is_selected:
		clear()
		draw_all_tiles()
		enabled = true
	else:
		clear()
		enabled = false

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
		set_cell(tile, 0, tile_coord, 0)
