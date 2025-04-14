class_name AStarNode extends Resource

var parent: AStarNode = null
var position: Vector2 = Vector2()
var g: float = 0
var h: float = 0
var f: float:
	get:
		return g + h


static func create(_position: Vector2, _parent: AStarNode = AStarNode.new()) -> AStarNode:
	var node = AStarNode.new()
	node.position = _position
	node.parent = _parent
	return node

func _to_string():
	return "{Position: %s, ParentPosition: %s, G: %s, H: %s, F: %s}" % [position, parent.position, g, h, f]
