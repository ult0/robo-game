extends TileMapLayer

var selected_unit_walkable_tiles: Array[Vector2i] = []
var move_tile_coord: Vector2i = Vector2i(21, 5)

func _ready() -> void:
	EventBus.unit_selected.connect(on_selected_unit)

func on_selected_unit(unit: Unit) -> void:
	if unit:
		for tile in selected_unit_walkable_tiles:
			erase_cell(tile)
		selected_unit_walkable_tiles = get_walkable_tiles(unit)
		for tile in get_walkable_tiles(unit):
			set_cell(tile, 0, move_tile_coord, 0)
	else:
		for tile in selected_unit_walkable_tiles:
			erase_cell(tile)
	
func get_walkable_tiles(unit: Unit) -> Array[Vector2i]:
	var unit_tile_coord := TileMapUtils.get_tile_coord(unit.global_position)
	var frontier: Array[Vector2i] = get_neighbor_coords(unit_tile_coord)
	var checked_tiles: Dictionary[Vector2i, bool] = {}
	var move_range: int = unit.unit_resource.move_speed

	for i in range(move_range):
		for j in range(frontier.size()):
			if !checked_tiles.has(frontier[j]):
				checked_tiles[frontier[j]] = true
				frontier.append_array(get_neighbor_coords(frontier[j]))
			
	# while !frontier.is_empty() && move_range > 0:
	# 	var current_tile: Vector2i = frontier.pop_front()
	# 	move_range -= 1
	# 	checked_tiles[current_tile] = true
	# 	var neighbors = get_neighbor_coords(current_tile)
	# 	for neighbor in neighbors:
	# 		if !checked_tiles.has(neighbor):
	# 			frontier.append(neighbor)

	return checked_tiles.keys() as Array[Vector2i]

func get_neighbor_coords(tile_coord: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for direction in TileMapUtils.movement_directions:
		var neighbor := tile_coord + direction
		if Navigation.is_walkable(neighbor, true):
			neighbors.append(neighbor)
	return neighbors
