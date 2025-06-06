class_name Enemy
extends Unit

func _ready() -> void:
	super()
	aStar = AStar.create(is_walkable)

func select() -> void:
	super()
	update_preview_layer()
	EventBus.enemy_selected_emit(self)

func unselect() -> void:
	super()
	update_preview_layer()
	EventBus.enemy_selected_emit(null)

func is_walkable(coord: Vector2i) -> bool:
	var containsObstacle := Level.instance.tile_contains_obstacle(coord)
	var containsPlayer := Level.instance.tile_contains_player(coord)
	var exists := Level.instance.tile_contains_navtile(coord)
	return exists and !containsObstacle and !containsPlayer

func move_to(coord: Vector2i) -> void:
	var path := aStar.find_path(tile_coord, coord)
	if path.size() <= unit_resource.move_speed:
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
		func (coord) -> bool: return Level.instance.tile_contains_enemy(coord)
	)

func setup_preview_layer() -> void:
	super()
	preview_component.tile_order = [preview_component.attack_tile_coord]

func set_preview_tiles() -> void:
	var walkable_tiles: Array[Vector2i] = []
	var attackable_tiles: Array[Vector2i] = []
	var tiles_with_enemies: Array[Vector2i] = []

	if is_selected or force_show_attack_range:
		for tile in get_walkable_tiles(tile_coord):
			if Level.instance.tile_contains_enemy(tile) and tile != tile_coord:
				tiles_with_enemies.append(tile)
			else:
				walkable_tiles.append(tile)
		attackable_tiles = get_attackable_tiles(walkable_tiles)
	
	preview_component.unit_walkable_tiles = walkable_tiles
	preview_component.unit_attackable_tiles = attackable_tiles
	preview_component.unit_friendly_tiles = tiles_with_enemies
