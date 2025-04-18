extends Node2D
class_name TileSelector

var last_tile_entered: Vector2i:
	set(coord):
		last_tile_entered = coord
		tile_entered.emit(coord)
signal tile_entered(coord: Vector2i)
var current_node: Node = null
var move_tween: Tween = null
var tile_coord: Vector2i:
	get:
		return TileMapUtils.get_tile_coord(global_position)

@onready var area2D: Area2D = $Area2D

func _ready() -> void:
	area2D.area_entered.connect(on_area_entered)
	area2D.area_exited.connect(on_area_exited)

func _process(_delta: float) -> void:
	var mouse_coord := TileMapUtils.get_tile_coord(get_global_mouse_position())
	
	visible = Level.instance.tile_contains_navtile(mouse_coord)
	if last_tile_entered != mouse_coord:
		global_position = TileMapUtils.get_tile_center_position(get_global_mouse_position())
		last_tile_entered = mouse_coord
		visible = Level.instance.tile_contains_navtile(mouse_coord)
		# if move_tween:
		# 	move_tween.kill()
		# move_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		# move_tween.tween_property(self, "global_position", tile_center_position, 0.05).set_trans(Tween.TRANS_SINE)

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
