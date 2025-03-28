extends CharacterBody2D

@export var moves_per_second: float = 1.0;
@export var target: Node2D;
@export var nav_layer: TileMapLayer;
@export var obstacle_layer: TileMapLayer;
@export var debug_layer: TileMapLayer;

@onready var up: RayCast2D = $up
@onready var down: RayCast2D = $down
@onready var left: RayCast2D = $left
@onready var right: RayCast2D = $right

var a_star: AStar
var moves: Array[Vector2] = []

var tile_size: Vector2 = Vector2(16, 16)
var tween: Tween
var elapsed_time: float = 1.0

func _ready() -> void:
	a_star = AStar.create(nav_layer, is_walkable, 2, debug_layer)

func is_walkable(coord: Vector2) -> bool:
	return obstacle_layer.get_cell_tile_data(obstacle_layer.local_to_map(coord)) == null

func _physics_process(delta: float) -> void:
	# if Input.is_action_just_pressed("up") and !$up.is_colliding():
	# 	_move(Vector2.UP)
	# if Input.is_action_just_pressed("down") and !$down.is_colliding():
	# 	_move(Vector2.DOWN)
	# if Input.is_action_just_pressed("left") and !$left.is_colliding():
	# 	_move(Vector2.LEFT)
	# if Input.is_action_just_pressed("right") and !$right.is_colliding():
	# 	_move(Vector2.RIGHT)

	# if is_instance_valid(target) and moves.is_empty():
	# 	var distance = (target.global_position - global_position) / tile_size
	# 	if distance.length() != 1:
	# 		for i in range(0, absi(distance.x)):
	# 			if distance.x > 0:
	# 				moves.append(Vector2.RIGHT)
	# 			elif distance.x < 0:
	# 				moves.append(Vector2.LEFT)
	# 		for i in range(0, absi(distance.y)):
	# 			if distance.y > 0:
	# 				moves.append(Vector2.DOWN)
	# 			elif distance.y < 0:
	# 				moves.append(Vector2.UP)

	elapsed_time += delta
	if elapsed_time >= 1.0 / moves_per_second and moves.size() > 0:
		var m = moves.pop_back()
		move(m)
		elapsed_time = 0.0

func move(coord: Vector2) -> void:
	var temp_position := global_position
	global_position = coord
	$Sprite2D.global_position = temp_position

	if tween:
		tween.kill()
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_SPACE:
		a_star.debug_find_path(global_position, target.global_position)
		# print(path)
		# moves = path



	
