extends TileMapLayer

var last_tile_position: Vector2i = Vector2i.MAX
var selected_unit: Unit

func _ready() -> void:
	EventBus.unit_selected.connect(func (unit: Unit) -> void: selected_unit = unit)

func _process(_delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var tile_position = self.local_to_map(mouse_position)
	if last_tile_position != tile_position:
		self.erase_cell(last_tile_position)
		self.set_cell(tile_position, 0, Vector2i(0, 0))
		last_tile_position = tile_position
	
	if selected_unit:
			queue_redraw()

func _draw() -> void:
	if last_tile_position != Vector2i.MAX and selected_unit and !selected_unit.moving:
		# Get player position somehow
		var start := selected_unit.global_position
		# Where mouse is
		var end := Vector2(last_tile_position) * TileMapUtils.tile_size_vector2

		var path := Navigation.aStar.find_path(start, end)
		if (path.size() == 0):
			return

		# Draw the path
		var width = 4
		var color = Color.CADET_BLUE
		# Add the start points to the path to draw the first line
		# path.push_front(Vector2(path[path.size() - 1]) + offset)
		path.append(Vector2(start))

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
	
