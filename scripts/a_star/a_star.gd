class_name AStar extends Resource

var nav_layer: TileMapLayer
var debug_layer: TileMapLayer
var is_walkable: Callable
var tile_size: float:
	get:
		return nav_layer.tile_set.tile_size.x

var _frontier: PriorityQueueVar = PriorityQueueVar.new()
var _closed_list: Array[Vector2] = []
var _current: AStarNode = null
var _calculated_g: float = 0

var _path: Array[Vector2] = []:
	set(value):
		_path = value
		_frontier = PriorityQueueVar.new()
		_closed_list = []
		_current = null
		_calculated_g = 0

var coord_label_scene: PackedScene = preload("res://scenes/coord_label.tscn")

static func create(_nav_layer: TileMapLayer, _is_walkable: Callable, _debug_layer: TileMapLayer = null) -> AStar:
	var astar = AStar.new();
	astar.nav_layer = _nav_layer
	astar.is_walkable = _is_walkable
	astar.debug_layer = _debug_layer
	return astar

func create_label(position: Vector2):
	var label: Label = coord_label_scene.instantiate()
	label.global_position = position
	label.text = str(position)
	label.name = "Label-" + label.text
	nav_layer.add_child(label)

func set_debug_tile(position: Vector2, alternate_tile_id: int):
	if is_instance_valid(debug_layer):
		debug_layer.set_cell(debug_layer.local_to_map(position), 0, Vector2i(0, 0), alternate_tile_id)

func find_path(start: Vector2, target: Vector2) -> Array[Vector2]:
	_frontier.insert(AStarNode.create(start), 0)
	# print("Start:", start, "Target:", target)

	while !_frontier.is_empty():
		_current = _frontier.extract()
		_closed_list.append(_current.position)
		# create_label(_current.position)
		set_debug_tile(_current.position, 1)

		# If the current node is the target node, return the path recursively from parent to parent
		if _current.position == target:
			print("Path Found!", _current)
			print(_current.parent)
			var path: Array[Vector2] = []
			while _current.parent.parent != null:
				set_debug_tile(_current.position, 2)
				path.append(_current.position)
				_current = _current.parent
			_path = path
			return _path

		# If the current node is not the target node, get its neighbors
		# and add them to the frontier if they are not in the closed list
		for neighbor in get_neighbors(_current):
			# If the neighbor is already in the closed list, skip it
			if _closed_list.find(neighbor.position) != -1:
				continue
			

			# Calculate the g and h values for the neighbor
			neighbor.g = _current.g + tile_size
			neighbor.h = (target - neighbor.position).length()
			neighbor.parent = _current

			# If the neighbor is in the frontier but the new path is shorter
			# remove from frontier and insert back into the frontier to update the position
			var found_index = _frontier.data.find(neighbor)
			if found_index != -1 and neighbor.f < _frontier.data[found_index]["cost"]:
				print("Updating Neighbor", neighbor.position)
				_frontier.data.remove_at(found_index)
				_frontier.insert(neighbor, neighbor.f)

			# If the neighbor is not in the frontier, insert it into the frontier
			if found_index == -1:
				_frontier.insert(neighbor, neighbor.f)
			
			set_debug_tile(neighbor.position, 3)

	print("No Path Found!")
	return []

func get_neighbors(current: AStarNode) -> Array[AStarNode]:
	var neighbors: Array[AStarNode] = []
	var directions: Array[Vector2] = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	for direction in directions:
		var neighbor := current.position + (direction * Vector2(nav_layer.tile_set.tile_size))
		if get_tiledata(neighbor) != null and is_position_walkable(neighbor):
			neighbors.append(AStarNode.create(neighbor, current))
	return neighbors

func get_tiledata(position: Vector2) -> TileData:
	return nav_layer.get_cell_tile_data(((position - nav_layer.transform.get_origin()) / nav_layer.tile_set.tile_size.x))

func is_position_walkable(position: Vector2) -> bool:
	return is_walkable.call(position)
