extends TileMapLayer

var selected_player: Unit = null
var selected_unit_walkable_tiles: Array[Vector2i] = []
var move_tile_coord: Vector2i = Vector2i(21, 5)

func _ready() -> void:
	EventBus.player_selected.connect(on_selected_player)

func _process(_delta: float) -> void:
	if selected_player and !selected_player.moving:
		erase_walkable_tiles()
		selected_unit_walkable_tiles = get_walkable_tiles(selected_player)
		draw_walkable_tiles()
	else:
		erase_walkable_tiles()

func on_selected_player(unit: Unit) -> void:
	selected_player = unit

func draw_walkable_tiles() -> void:
	for tile in selected_unit_walkable_tiles:
			set_cell(tile, 0, move_tile_coord, 0)

func erase_walkable_tiles() -> void:
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

	var walkable_tiles = checked_tiles.keys() as Array[Vector2i]
	var walkable_tiles_without_players = walkable_tiles.filter(func(tile: Vector2i) -> bool: return !Navigation.tile_contains_player(TileMapUtils.get_global_position_from_tile(tile)))
	return walkable_tiles_without_players

func get_neighbor_coords(tile_coord: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for direction in TileMapUtils.movement_directions:
		var neighbor := tile_coord + direction
		# Can't move through obstacles or enemies
		var containsObstacle := Navigation.tile_contains_obstacle(TileMapUtils.get_global_position_from_tile(neighbor))
		var containsEnemy := Navigation.tile_contains_enemy(TileMapUtils.get_global_position_from_tile(neighbor))
		if !containsObstacle and !containsEnemy:
			neighbors.append(neighbor)
	return neighbors

func is_tile_walkable(coord: Vector2) -> bool:
	for tile in selected_unit_walkable_tiles:
		if tile == Vector2i(TileMapUtils.get_tile_coord(coord)):
			return true
	return false
