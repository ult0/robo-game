extends Unit
class_name Player

var walkable_tiles: Array[Vector2i] = []
var attackable_tiles: Array[Vector2i] = []
var tiles_with_players: Array[Vector2i] = []
@onready var aStar: AStar = AStar.create(is_walkable)

func is_walkable(coord: Vector2i) -> bool:
	var containsObstacle := Level.instance.tile_contains_obstacle(coord)
	var containsEnemy := Level.instance.tile_contains_enemy(coord)
	var exists := Level.instance.tile_contains_navtile(coord)
	return exists and !containsObstacle and !containsEnemy

func move_to(coord: Vector2i) -> void:
	var path := aStar.find_path(tile_coord, coord)
	if path.size() <= unit_resource.move_speed:
		# unselect()
		move(path)

func get_walkable_tiles(coord: Vector2i) -> Array[Vector2i]:
	return TileMapUtils.get_tiles_in_range(
		[coord],
		unit_resource.move_speed,
		is_walkable
	)

func get_attackable_tiles(starting_tiles: Array[Vector2i]) -> Array[Vector2i]:
	return TileMapUtils.get_tiles_in_range(
		starting_tiles,
		unit_resource.attack_range,
		Level.instance.tile_contains_navtile,
		func (coord) -> bool: return Level.instance.tile_contains_player(coord)
	)

func set_tile_options() -> void:
	for tile in get_walkable_tiles(tile_coord):
		if Level.instance.tile_contains_player(tile) and tile != tile_coord:
			tiles_with_players.append(tile)
		else:
			walkable_tiles.append(tile)
	attackable_tiles = get_attackable_tiles(walkable_tiles)

func clear_tile_options() -> void:
	walkable_tiles.clear()
	attackable_tiles.clear()
	tiles_with_players.clear()
