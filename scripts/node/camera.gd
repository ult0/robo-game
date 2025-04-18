extends Camera2D
class_name Camera

@export var camera_speed: float = 20.0

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if Input.is_action_pressed("left"):
		position.x -= camera_speed * _delta
	elif Input.is_action_pressed("right"):
		position.x += camera_speed * _delta
	if Input.is_action_pressed("up"):
		position.y -= camera_speed * _delta
	elif Input.is_action_pressed("down"):
		position.y += camera_speed * _delta