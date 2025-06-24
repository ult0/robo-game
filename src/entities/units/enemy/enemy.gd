class_name Enemy
extends Unit

var force_show_attack_range: bool = false:
	set(value):
		force_show_attack_range = value
		update_action_tiles()
		var preview: PreviewTilesComponent = unit_components.get("PreviewTilesComponent")
		if preview: preview.update()

func _ready() -> void:
	super()
	EventBus.enemy_turn_end_connect(on_turn_start)

func select() -> void:
	super()
	EventBus.enemy_selected_emit(self)

func unselect() -> void:
	super()
	EventBus.enemy_selected_emit(null)

func tile_contains_opposing_unit(coord: Vector2i) -> bool:
	return Level.instance.tile_contains_player(coord)

func tile_contains_friendly_unit(coord: Vector2i) -> bool:
	return Level.instance.tile_contains_enemy(coord)

func on_turn_start(_turn_num: int) -> void:
	unit_resource.movement = unit_resource.max_movement

#region AI

func choose_target(players: Array[Unit]) -> Unit:
	for player in players:
		if player.dead:
			assert(false, "Enemy was given a dead player as target")
			return null
	if players.is_empty():
		assert(false, "Enemy was given a dead player as target")
		return null

	# Sort by distance
	players.sort_custom(
		func (a: Unit, b: Unit) -> bool:
			return TileMapUtils.euclidean(tile_coord, a.tile_coord) < TileMapUtils.euclidean(tile_coord, b.tile_coord)
	)
	 
	# In Range
	var units_in_range_by_distance: Array[Unit] = get_units_in_attack_range(players)
	
	# If no units in range, return closest
	if units_in_range_by_distance.is_empty():
		return players[0]
	# Else, return closest in range
	else:
		return units_in_range_by_distance[0]

func get_units_in_attack_range(players: Array[Unit]) -> Array[Unit]:
	var units_in_range: Array[Unit] = []
	for player in players:
		if can_attack_after_moving(player.tile_coord):
			units_in_range.append(player)
	return units_in_range
		



#endregion
