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
	EventBus.enemy_turn_start_connect(on_turn_start)

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
	if not players.is_empty():
		return players[0]
	return null

#endregion
