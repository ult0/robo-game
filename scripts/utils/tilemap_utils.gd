extends RefCounted
class_name TileMapUtils

const tile_size: int = 16
const tile_size_half: int = tile_size / 2
const tile_size_vector2i: Vector2i = Vector2i(tile_size, tile_size)
const tile_size_vector2: Vector2 = Vector2(tile_size, tile_size)
const tile_size_half_vector2i: Vector2i = Vector2i(tile_size_half, tile_size_half)
const tile_size_half_vector2: Vector2 = Vector2(tile_size_half, tile_size_half)

const movement_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

## Takes a global coordinate and returns the tile coordinate as a Vector2i
static func get_tile_coord(global_coord: Vector2) -> Vector2i:
	return Vector2i(
			floori(global_coord.x / tile_size),
			floori(global_coord.y / tile_size)
		)

## Takes a tile coordinate and returns the global position as a Vector2
static func get_global_position_from_tile(tile_coord: Vector2i) -> Vector2:
	return Vector2(tile_coord) * tile_size_vector2

## Takes a global coordinate, converts to tile coordinates, and return the global position of the tile origin
static func get_tile_origin_position(global_coord: Vector2) -> Vector2:
	return Vector2(get_tile_coord(global_coord)) * tile_size_vector2

## Takes a global coordinate and returns the center point of the tile that contains it as a global coordinate
static func get_tile_center_position(global_coord: Vector2) -> Vector2:
	return get_tile_origin_position(global_coord) + tile_size_half_vector2

## Takes a tile coordinate and returns the center point of the tile as a global coordinate
static func get_tile_center_position_from_coord(coord: Vector2i) -> Vector2:
	return get_global_position_from_tile(coord) + tile_size_half_vector2

## Takes a tile coordinate and returns the neighboring coordinates based on movement_directions
## The method parameter expects a callable that takes a Vector2i representing the tile coordinate and returns a boolean - true to include, false to exclude
## By default, it includes all neighbors
static func get_neighbor_coords(tile_coord: Vector2i, method: Callable = func (_neighbor: Vector2i) -> bool: return true) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for direction in TileMapUtils.movement_directions:
		var neighbor := tile_coord + direction
		# Apply the method to filter neighbors
		if method.call(neighbor):
			neighbors.append(neighbor)
	return neighbors
