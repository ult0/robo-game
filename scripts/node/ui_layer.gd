extends TileMapLayer

var selected_player: Player
var selector_coord: Vector2i

func _ready() -> void:
	EventBus.selector_coord_changed_connect(on_tile_selector_entered)
	EventBus.player_selected_connect(on_player_selected)

func on_tile_selector_entered(coord: Vector2i) -> void:
	selector_coord = coord
	queue_redraw()

func on_player_selected(player: Player) -> void:
	selected_player = player
	queue_redraw()

func _draw() -> void:
	if selected_player and !selected_player.moving and selected_player.is_preview_layer_showing():
		var start := selected_player.tile_coord
		var end := selector_coord
		var path := Level.instance.aStar.find_path(start, end).map(func (coord: Vector2i) -> Vector2: return TileMapUtils.get_tile_center_position_from_coord(coord))
		
		if (path.is_empty() or path.size() > selected_player.unit_resource.move_speed):
			return

		# Draw the path
		var width = 4
		var color = Color.CADET_BLUE
		# Add the start points to the path to draw the first line
		path.append(TileMapUtils.get_tile_center_position_from_coord(start))

		var line_vectors: PackedVector2Array = []
		for i in range(path.size() - 1):
			var point1 = path[path.size() - (i + 1)]
			var point2 = path[path.size() - (i + 2)]
			var direction = (point2 - point1).normalized()
			line_vectors.append(point1)
			if i == path.size() - 2:
				# Draw the last line a little shorter
				line_vectors.append(point2 - (direction * (width / 2.0)))
			else:
				line_vectors.append(point2 + (direction * (width / 2.0)))
		draw_multiline(line_vectors, color, width)

		# Draw the arrow at the end of the path
		var last_point = line_vectors[line_vectors.size() - 1]
		var second_last_point = line_vectors[line_vectors.size() - 2]
		var arrow_direction = (last_point - second_last_point).normalized()
		var triangle_vectors: PackedVector2Array = [
			Vector2(last_point + arrow_direction.rotated(-PI / 2) * 4),
			Vector2(last_point + arrow_direction.rotated(PI / 2) * 4),
			Vector2(last_point + arrow_direction * 4),
		]
		draw_colored_polygon(triangle_vectors, color)
	
