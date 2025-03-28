class_name AStarNode extends Resource

var parent: AStarNode = null
var position: Vector2 = Vector2()
var g: float = 0
var h: float = 0
var w: float
var f: float:
	get:
		return g + (h * w)


static func create(_position: Vector2, _h_weight: float = 2, _parent: AStarNode = AStarNode.new()) -> AStarNode:
	var node = AStarNode.new()
	node.position = _position
	node.parent = _parent
	node.w = _h_weight
	return node

func _to_string():
	return "{Position: %s, ParentPosition: %s, G: %s, H: %s, F: %s}" % [position, parent.position, g, h, f]
