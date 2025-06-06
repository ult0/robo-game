extends Camera2D
class_name Camera

@export var camera_speed: float = 20.0
var input_actions: Array[StringName] = ["left", "right", "up", "down"];

func _ready() -> void:
	pass

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
		position += (camera_vector).normalized() * camera_speed * delta