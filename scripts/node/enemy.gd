extends Unit
class_name Enemy

# Temporary inputs to test movement
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_position = get_global_mouse_position()
		var tile_position := Level.instance.NavigationLayer.local_to_map(mouse_position)
		var global_tile_position: Vector2 = Level.instance.NavigationLayer.map_to_local(tile_position)
		if global_tile_position == self.global_position:
			EventBus.enemy_selected.emit(self)


