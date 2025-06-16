class_name Player
extends Unit

func _ready() -> void:
	super()
	EventBus.turn_start_connect(on_turn_start)

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

func on_turn_start(_turn_num: int) -> void:
	unit_resource.movement = unit_resource.max_movement
