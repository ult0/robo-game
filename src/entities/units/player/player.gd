class_name Player
extends Unit

func select() -> void:
	super()
	EventBus.player_selected_emit(self)

func unselect() -> void:
	super()
	EventBus.player_selected_emit(null)

func tile_contains_opposing_unit(coord: Vector2i) -> bool:
	return Level.instance.tile_contains_enemy(coord)

func tile_contains_friendly_unit(coord: Vector2i) -> bool:
	return Level.instance.tile_contains_player(coord)
