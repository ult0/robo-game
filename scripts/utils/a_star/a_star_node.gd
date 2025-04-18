class_name AStarNode extends Resource

var parent: AStarNode = null
var coord: Vector2i = Vector2i()
var g: float = 0
var h: float = 0
var f: float:
	get:
		return g + h


static func create(_coord: Vector2, _parent: AStarNode = AStarNode.new()) -> AStarNode:
	var node = AStarNode.new()
	node.coord = _coord
	node.parent = _parent
	return node

func _to_string():
	return "{Position: %s, ParentPosition: %s, G: %s, H: %s, F: %s}" % [coord, parent.coord, g, h, f]
