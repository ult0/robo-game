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
## The filter callable expects a Vector2i representing the tile coordinate and returns a boolean - true to include, false to exclude
## By default, it includes all neighbors
static func get_neighbor_coords(
	tile_coord: Vector2i, 
	filter: Callable = func (_neighbor: Vector2i) -> bool: return true
) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for direction in TileMapUtils.movement_directions:
		var neighbor := tile_coord + direction
		# Apply the method to filter neighbors
		if filter.call(neighbor):
			neighbors.append(neighbor)
	return neighbors

## Takes a initial array of coordinates and a range limit to flood-fill tiles from
## The include_filter callable expects a Vector2i representing the tile coordinate and returns a boolean - true to include, false to exclude
## The post_exclude_filter callable is applied after the flood-fill to exclude any coordinates - defaults to not exclude anything
## Returns a dictionary of coordinates and their distance from the start positions
static func get_tiles_in_range_with_distances(
	start_positions: Array[Vector2i],
	range_limit: int,
	include_filter: Callable = func (_coord: Vector2i) -> bool: return true,
	post_exclude_filter: Callable = func (_coord: Vector2i) -> bool: return false
) -> Dictionary[Vector2i, int]:
	var frontier: Array[Vector2i] = start_positions.duplicate()
	var next_frontier: Array[Vector2i] = []
	var tiles_in_range: Dictionary[Vector2i, int] = {}

	# iterate from zero to range_limit
	for i in range(0, range_limit + 1):
		for coord in frontier:
			if !tiles_in_range.has(coord):
				tiles_in_range[coord] = i
				next_frontier.append_array(get_neighbor_coords(coord, include_filter))
		frontier = next_frontier
		next_frontier = []
	# Apply the post-filter
	for coord in tiles_in_range.keys():
		if post_exclude_filter.call(coord):
			tiles_in_range.erase(coord)
	
	return tiles_in_range

## Uses get_tiles_in_range_with_distances to return only the keys (tile coordinates)
static func get_tiles_in_range(
	start_positions: Array[Vector2i],
	range_limit: int,
	filter: Callable = func (_coord: Vector2i) -> bool: return true,
	post_exclude_filter: Callable = func (_coord: Vector2i) -> bool: return false
) -> Array[Vector2i]:
	return get_tiles_in_range_with_distances(
		start_positions,
		range_limit,
		filter,
		post_exclude_filter
	).keys() as Array[Vector2i]
