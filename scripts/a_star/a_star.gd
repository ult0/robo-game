class_name AStar extends Resource

var nav_layer: TileMapLayer
var debug_layer: TileMapLayer
var is_walkable: Callable
var tile_size: float:
	get:
		return nav_layer.tile_set.tile_size.x

var _frontier: PriorityQueueVar = PriorityQueueVar.create(func(element) -> int:
	for i in range(_frontier.data.size()):
		if (_frontier.data[i]["element"] as AStarNode).position == (element as AStarNode).position:
			return i
	return -1
)
var _closed_list: Array[Vector2] = []
var _current: AStarNode = null

var directions: Array[Vector2] = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var _path: Array[Vector2] = []

static func create(_nav_layer: TileMapLayer, _is_walkable: Callable, _debug_layer: TileMapLayer = null) -> AStar:
	var astar = AStar.new();
	astar.nav_layer = _nav_layer
	astar.is_walkable = _is_walkable
	astar.debug_layer = _debug_layer
	return astar

func set_debug_tile(position: Vector2, alternate_tile_id: int):
	if is_instance_valid(debug_layer):
		debug_layer.set_cell(debug_layer.local_to_map(position), 0, Vector2i(0, 0), alternate_tile_id)

func find_path(start: Vector2, target: Vector2) -> Array[Vector2]:
	_frontier.insert(AStarNode.create(start), 0)

	while !_frontier.is_empty():
		_current = _frontier.extract()
		_closed_list.append(_current.position)
		set_debug_tile(_current.position, 1)

		# If the current node is the target node, return the path recursively from parent to parent
		if _current.position == target:
			print("Path Found!", _current)
			var path: Array[Vector2] = []
			while _current.parent.parent != null:
				set_debug_tile(_current.position, 2)
				path.append(_current.position)
				_current = _current.parent
			_path = path
			reset()
			return _path

		# If the current node is not the target node, get its neighbors
		# and add them to the frontier if they are not in the closed list
		for neighbor in get_neighbors(_current):
			# If the neighbor is already in the closed list, skip it
			if _closed_list.find(neighbor.position) != -1:
				continue

			# Calculate the g value for the neighbor
			neighbor.g = _current.g + tile_size

			# Euclidean distance
			neighbor.h = (target - neighbor.position).length()

			neighbor.parent = _current

			# If the neighbor is in the frontier but the new path is shorter
			# remove from frontier and insert back into the frontier to update the position
			var found_index := _frontier.find_element(neighbor)
			if found_index != -1 and neighbor.g < _frontier.data[found_index]["element"].g:
				print("Updating Neighbor ", neighbor.position)
				_frontier.modify(found_index, neighbor, neighbor.f)
			# If the neighbor is not in the frontier, insert it into the frontier
			elif found_index == -1:
				print("Adding Neighbor", neighbor.position)
				_frontier.insert(neighbor, neighbor.f)
			
			set_debug_tile(neighbor.position, 3)

	print("No Path Found!")
	reset()
	return []

func get_neighbors(current: AStarNode) -> Array[AStarNode]:
	var neighbors: Array[AStarNode] = []
	for direction in directions:
		var neighbor := current.position + (direction * Vector2(nav_layer.tile_set.tile_size))
		if get_tiledata(neighbor) != null and is_position_walkable(neighbor):
			neighbors.append(AStarNode.create(neighbor, current))
	return neighbors

func get_tiledata(position: Vector2) -> TileData:
	return nav_layer.get_cell_tile_data(((position - nav_layer.transform.get_origin()) / nav_layer.tile_set.tile_size.x))

func is_position_walkable(position: Vector2) -> bool:
	return is_walkable.call(position)

func reset() -> void:
	_frontier.data = []
	_closed_list = []
	_current = null

# func debug_find_path(start: Vector2, target: Vector2) -> Variant:
# 	if _frontier.is_empty():
# 		print("Starting at ", start)
# 		_frontier.insert(AStarNode.create(start, h_weight), 0)
	
# 	if !_frontier.is_empty():
# 		_current = _frontier.extract()
# 		print("Checking and Closing ", _current)
# 		print_frontier()
# 		_closed_list.append(_current.position)
# 		# create_label(_current.position)
# 		set_debug_tile(_current.position, 1)

# 		# If the current node is the target node, return the path recursively from parent to parent
# 		if _current.position == target:
# 			print("Path Found!", _current)
# 			var path: Array[Vector2] = []
# 			while _current.parent.parent != null:
# 				set_debug_tile(_current.position, 2)
# 				path.append(_current.position)
# 				_current = _current.parent
# 			_path = path
# 			return _path

# 		# If the current node is not the target node, get its neighbors
# 		# and add them to the frontier if they are not in the closed list
# 		for neighbor in get_neighbors(_current):
# 			# If the neighbor is already in the closed list, skip it
# 			if _closed_list.find(neighbor.position) != -1:
# 				continue

# 			# Calculate the g value for the neighbor
# 			neighbor.g = _current.g + tile_size

# 			# Euclidean distance
# 			neighbor.h = (target - neighbor.position).length()

# 			neighbor.parent = _current

# 			# If the neighbor is in the frontier but the new path is shorter
# 			# remove from frontier and insert back into the frontier to update the position
# 			var found_index := _frontier.find_element(neighbor)
# 			if found_index != -1 and neighbor.g < _frontier.data[found_index]["element"].g:
# 				print("Updating Neighbor ", neighbor.position)
# 				_frontier.modify(found_index, neighbor, neighbor.f)
# 			# If the neighbor is not in the frontier, insert it into the frontier
# 			elif found_index == -1:
# 				print("Adding Neighbor", neighbor.position)
# 				_frontier.insert(neighbor, neighbor.f)
			
# 			set_debug_tile(neighbor.position, 3)
# 		return _current
# 	else:
# 		print("No Path Found!")
# 		return null
	
# func print_frontier():
# 	for node in _frontier.data:
# 		print(node)
