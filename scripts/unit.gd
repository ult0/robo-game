extends Node2D

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var aStar: AStar
@onready var nav_layer: TileMapLayer = %NavigationLayer

var tween: Tween

var elapsed_time: float = 0.0
@export var moves_per_second: float = 5.0
var moves: Array[Vector2] = []

func is_walkable(coord: Vector2) -> bool:
	return %ObstacleLayer.get_cell_tile_data(%ObstacleLayer.local_to_map(coord)) == null

func _ready() -> void:
	animatedSprite.play("idle")
	aStar = AStar.create(%NavigationLayer, is_walkable)

func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= 1.0 / moves_per_second and moves.size() > 0:
		var m = moves.pop_back()
		move(m)
		elapsed_time = 0.0

func move(coord: Vector2) -> void:
	var temp_position := global_position
	global_position = coord
	animatedSprite.global_position = temp_position

	if tween:
		tween.kill()
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(animatedSprite, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)

func move_to(coord: Vector2) -> void:
	var path = aStar.find_path(global_position, coord)
	moves = path

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var mouse_position = get_global_mouse_position()
		var grid_position = nav_layer.local_to_map(mouse_position) * nav_layer.tile_set.tile_size
		move_to(grid_position)
