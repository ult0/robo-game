extends RefCounted
class_name TileMapUtils

const tile_size: int = 16
const tile_size_half: int = tile_size / 2
const tile_size_vector2i: Vector2i = Vector2i(tile_size, tile_size)
const tile_size_vector2: Vector2 = Vector2(tile_size, tile_size)
const tile_size_half_vector2i: Vector2i = Vector2i(tile_size_half, tile_size_half)
const tile_size_half_vector2: Vector2 = Vector2(tile_size_half, tile_size_half)

const movement_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

## Takes a global coordinate and returns the tile coordinate as a Vector2
static func get_tile_coord(global_coord: Vector2) -> Vector2:
	return Vector2(
			floori(global_coord.x / tile_size),
			floori(global_coord.y / tile_size)
		)

## Takes a global coordinate, converts to tile coordinates, and return the global position of the tile origin
static func get_tile_position(global_coord: Vector2) -> Vector2:
	return get_tile_coord(global_coord) * tile_size_vector2

## Takes a global coordinate and returns the center point of the tile that contains it as a global coordinate
static func get_tile_center_position(global_coord: Vector2) -> Vector2:
	return get_tile_position(global_coord) + tile_size_half_vector2

## Takes a tile coordinate and returns the global position as a Vector2
static func get_global_position_from_tile(tile_coord: Vector2i) -> Vector2:
	return Vector2(tile_coord) * tile_size_vector2
