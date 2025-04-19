class_name AStar extends Object

var debug_layer: TileMapLayer
var is_walkable: Callable

var _frontier: PriorityQueue = PriorityQueue.new()
var _closed_list: Array[Vector2i] = []
var _current: AStarNode = null

var _path: Array[Vector2i] = []

static func create(_is_walkable: Callable, _debug_layer: TileMapLayer = null) -> AStar:
	var astar = AStar.new();
	astar.is_walkable = _is_walkable
	astar.debug_layer = _debug_layer
	return astar

func set_debug_tile(coord: Vector2i, alternate_tile_id: int, debug_mode = false):
	if is_instance_valid(debug_layer) and debug_mode:
		debug_layer.set_cell(coord, 0, Vector2i(0, 0), alternate_tile_id)

func find_path(start: Vector2i, target: Vector2i, debug_mode = false) -> Array[Vector2i]:
	_frontier.insert(AStarNode.create(start), 0)

	while !_frontier.is_empty():
		_current = _frontier.extract()
		_closed_list.append(_current.coord)
		set_debug_tile(_current.coord, 1, debug_mode)

		# If the current node is the target node, return the path recursively from parent to parent
		if _current.coord == target:
			var path: Array[Vector2i] = []
			while _current.parent.parent != null:
				set_debug_tile(_current.coord, 2, debug_mode)
				path.append(_current.coord)
				_current = _current.parent
			_path = path
			reset()
			return _path

		# If the current node is not the target node, get its neighbors
		# and add them to the frontier if they are not in the closed list
		for neighbor in get_neighbors(_current):
			# If the neighbor is already in the closed list, skip it
			if _closed_list.find(neighbor.coord) != -1:
				continue

			# Calculate the g value for the neighbor
			neighbor.g = _current.g + 1.0

			# Euclidean distance
			neighbor.h = (Vector2(target) - Vector2(neighbor.coord)).length()

			neighbor.parent = _current

			# If the neighbor coord is in the frontier but the new path is shorter
			# modify this neighbor in the frontier to update the g cost and parent
			var found_index := _frontier.data.find_custom(func (node: AStarNode) -> bool: return node.coord == neighbor.coord)
			if found_index != -1 and neighbor.g < _frontier.data[found_index].g:
				_frontier.modify(found_index, neighbor, neighbor.f)
			# If the neighbor is not in the frontier, insert it into the frontier
			elif found_index == -1:
				_frontier.insert(neighbor, neighbor.f)
			
			set_debug_tile(neighbor.coord, 3, debug_mode)
	reset()
	return []

func get_neighbors(current: AStarNode) -> Array[AStarNode]:
	var neighbors: Array[AStarNode] = []
	for direction in TileMapUtils.movement_directions:
		var neighbor := current.coord + direction
		if is_walkable.call(neighbor):
			neighbors.append(AStarNode.create(neighbor, current))
	return neighbors

func reset() -> void:
	_frontier.data = []
	_frontier.dict = {}
	_closed_list = []
	_current = null
