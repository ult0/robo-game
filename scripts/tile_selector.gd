extends Node2D
class_name TileSelector

var last_tile_entered: Vector2 = Vector2.INF
var current_node: Node = null
@onready var area2D: Area2D = $Area2D

func _ready() -> void:
	area2D.area_entered.connect(on_area_entered)
	area2D.area_exited.connect(on_area_exited)

func _process(_delta: float) -> void:
	var tile_center_position = TileMapUtils.get_tile_center_position(get_global_mouse_position())
	if last_tile_entered != tile_center_position:
		global_position = tile_center_position
		last_tile_entered = tile_center_position

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left-click"):
		if current_node and current_node.has_method("select"):
			current_node.select()
	elif event.is_action_pressed("right-click") and current_node and current_node.has_method("unselect"):
		current_node.unselect()

func on_area_entered(area: Area2D) -> void:
	current_node = area.owner
	if area.owner.has_method("on_enter_hover"):
		area.owner.on_enter_hover()

func on_area_exited(area: Area2D) -> void:
	current_node = null
	if area.owner.has_method("on_exit_hover"):
		area.owner.on_exit_hover()
