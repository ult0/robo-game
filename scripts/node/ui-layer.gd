extends TileMapLayer

@onready var tileSelector: TileSelector = $TileSelector
var last_tile_position: Vector2i = Vector2i.MAX
var selected_player: Unit

func _ready() -> void:
	EventBus.player_selected.connect(func (unit: Unit) -> void: selected_player = unit)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if tileSelector.last_tile_entered != Vector2.INF and selected_player and !selected_player.moving:
		var start := selected_player.global_position
		var end := tileSelector.last_tile_entered
		var path := Navigation.aStar.find_path(start, end)
		
		if (path.size() == 0  or path.size() > selected_player.unit_resource.move_speed):
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
	
