extends Camera2D
class_name Camera

@export var bounding_layer: TileMapLayer
@export var tile_margin: int = 8
@export var camera_speed: float = 20.0
var input_actions: Array[StringName] = ["left", "right", "up", "down"];
var focus_tween: Tween

func _ready() -> void:
	var bounding_rect: Rect2i = bounding_layer.get_used_rect().grow(tile_margin)
	var bounding_top_left = TileMapUtils.get_global_position_from_tile(bounding_rect.position)
	var bounding_bottom_right = TileMapUtils.get_global_position_from_tile(bounding_rect.end)
	print(bounding_rect)
	limit_top = bounding_top_left.y
	limit_left = bounding_top_left.x
	limit_bottom = bounding_bottom_right.y
	limit_right = bounding_bottom_right.x
	EventBus.player_selected_connect(on_unit_selected)
	EventBus.enemy_selected_connect(on_unit_selected)

func on_unit_selected(unit: Unit) -> void:
	if unit:
		focus(unit.global_position)

func focus(_position: Vector2) -> void:
	if focus_tween:
		focus_tween.kill()
	focus_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	focus_tween.tween_property(self, "position", _position, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await focus_tween.finished
	snap_in_limit()

func handle_input(delta: float) -> void:
	var camera_vector: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left"):
		camera_vector += Vector2.LEFT
	if Input.is_action_pressed("right"):
		camera_vector += Vector2.RIGHT
	if Input.is_action_pressed("up"):
		camera_vector += Vector2.UP
	if Input.is_action_pressed("down"):
		camera_vector += Vector2.DOWN

	if camera_vector != Vector2.ZERO:
		position += (camera_vector.normalized() * camera_speed * delta)
		snap_in_limit()

func snap_in_limit():
	#this code only works correctly when "Camera2D.anchor_mode" is Drag Center.
	
	#first we get the viewport size and divide it by 2 to get the viewport's center.
	var viewport_half_x = get_viewport_rect().size.x/2
	var viewport_half_y = get_viewport_rect().size.y/2
	
	#we offset the limits to acount for the viewport size
	var new_limit_left = limit_left+viewport_half_x
	var new_limit_top = limit_top+viewport_half_y
	var new_limit_right = limit_right-viewport_half_x
	var new_limit_bottom = limit_bottom-viewport_half_y
	
	#clamp the Camera2D's position between the new limits.
	var new_x = clamp(global_position.x, new_limit_left,new_limit_right)
	var new_y = clamp(global_position.y, new_limit_top,new_limit_bottom)
	
	global_position = Vector2(new_x,new_y)
