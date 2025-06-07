class_name Enemy
extends Unit

var force_show_attack_range: bool = false:
	set(value):
		force_show_attack_range = value
		update_action_tiles()
		var preview: PreviewComponent = unit_components.get("PreviewComponent")
		if preview: preview.update()

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
