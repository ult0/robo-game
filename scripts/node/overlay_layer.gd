extends TileMapLayer

var selected_player: Unit = null
var selected_unit_walkable_tiles: Array[Vector2i] = []
var other_unit_tiles: Array[Vector2i] = []
var selected_unit_attackable_tiles: Array[Vector2i] = []

var move_tile_coord: Vector2i = Vector2i(21, 5)
var attack_tile_coord: Vector2i = Vector2i(22, 4)
var player_tile_coord: Vector2i = Vector2i(22, 5)

func _ready() -> void:
	EventBus.player_selected.connect(on_selected_player)

func on_selected_player(unit: Unit) -> void:
	selected_player = unit
	if selected_player and !selected_player.moving:
		# Clear any tiles from previous selection
		clear()
		# Get all walkable tiles - including tiles with other player units
		var walkable_tiles = get_walkable_tiles(selected_player)
		# Separate tiles with and without players - this allows players to move through each other
		var tiles_with_players: Array[Vector2i] = []
		var tiles_without_players: Array[Vector2i] = []
		# This should put all walkable_tiles into 2 groups except the selected player tile will be ignored
		for coord in walkable_tiles:
			if Level.instance.tile_contains_player(coord) and coord != selected_player.tile_coord:
				tiles_with_players.append(coord)
			else:
				tiles_without_players.append(coord)

		selected_unit_walkable_tiles = tiles_without_players
		other_unit_tiles = tiles_with_players
		selected_unit_attackable_tiles = get_attack_range_tiles(selected_player, selected_unit_walkable_tiles)
		draw_attack_range_tiles()
		draw_walkable_tiles()
		draw_player_tiles()
	else:
		clear()

func draw_walkable_tiles() -> void:
	for tile in selected_unit_walkable_tiles:
			set_cell(tile, 0, move_tile_coord, 0)

func draw_attack_range_tiles() -> void:
	for tile in selected_unit_attackable_tiles:
		set_cell(tile, 0, attack_tile_coord, 0)

func draw_player_tiles() -> void:
	for tile in other_unit_tiles:
		set_cell(tile, 0, player_tile_coord, 0)

func get_walkable_tiles(unit: Unit) -> Array[Vector2i]:
	var frontier: Array[Vector2i] = [unit.tile_coord]
	var next_frontier: Array[Vector2i] = []
	var walkable_tiles: Dictionary[Vector2i, int] = {}
	var move_range: int = unit.unit_resource.move_speed

	# iterate from zero to move_range, zero represents the initial unit position
	for i in range(0, move_range + 1):
		for j in range(frontier.size()):
			if !walkable_tiles.has(frontier[j]):
				walkable_tiles[frontier[j]] = i
				next_frontier.append_array(get_walkable_neighbor_coords(frontier[j]))
		frontier = next_frontier

	return walkable_tiles.keys() as Array[Vector2i]

func get_walkable_neighbor_coords(tile_coord: Vector2i) -> Array[Vector2i]:
	return TileMapUtils.get_neighbor_coords(tile_coord, Level.instance.is_walkable)

func get_attack_range_tiles(unit: Unit, walkable_tiles: Array[Vector2i]) -> Array[Vector2i]:
	var frontier: Array[Vector2i] = walkable_tiles.duplicate()
	var next_frontier: Array[Vector2i] = []
	var attackable_tiles: Dictionary[Vector2i, int] = {}
	var attack_range = unit.unit_resource.attack_range
	
	# iterate from zero to attack_range, zero represents the initial walkable_tiles
	for i in range(0, attack_range + 1):
		for j in range(frontier.size()):
			if !attackable_tiles.has(frontier[j]):
				attackable_tiles[frontier[j]] = i
				next_frontier.append_array(get_attackable_nieghbor_coords(frontier[j]))
		frontier = next_frontier

	return attackable_tiles.keys() as Array[Vector2i]

func get_attackable_nieghbor_coords(tile_coord: Vector2i) -> Array[Vector2i]:
	return TileMapUtils.get_neighbor_coords(tile_coord, Level.instance.is_attackable)
		
# Used in UnitManager
func is_tile_walkable(coord: Vector2i) -> bool:
	return selected_unit_walkable_tiles.has(coord)

func is_tile_attackable(coord: Vector2i) -> bool:
	return selected_unit_attackable_tiles.has(coord)
