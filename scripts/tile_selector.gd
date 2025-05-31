extends Node2D
class_name TileSelector

var last_tile_entered: Vector2i:
	set(coord):
		last_tile_entered = coord
		EventBus.tile_selector_coord_changed.emit(coord)

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

func on_area_entered(area: Area2D) -> void:
	current_node = area.owner
	if area.owner.has_method("enter_hover"):
		area.owner.enter_hover()

func on_area_exited(area: Area2D) -> void:
	current_node = null
	if area.owner.has_method("exit_hover"):
		area.owner.exit_hover()
