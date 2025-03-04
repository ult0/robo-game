extends CharacterBody2D
class_name Robo

enum State {IDLE, RUN}
var state: State = State.IDLE

@export var SPEED = 150.0
@export var FRICTION = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Player = %Player

var tracked_position: Vector2

func _ready() -> void:
	if is_instance_valid(player):
		player.player_position.connect(track_player)
	animated_sprite.play("idle_down")

func track_player(player_position: Vector2) -> void:
	tracked_position = player_position
	

# var input_direction: Vector2 = Vector2.ZERO:
# 	get:
# 		return Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))

# var facing_direction: Vector2 = Vector2.DOWN:
# 	set(dir):
# 		if dir.x == Vector2.RIGHT.x:
# 			animated_sprite.flip_h = false
# 		elif dir.x == Vector2.LEFT.x:
# 			animated_sprite.flip_h = true
# 		facing_direction = dir

# func set_state(new_state: State) -> void:
# 	# handle one time changes when entering a new state
# 	match new_state:
# 		State.IDLE:
# 			pass
# 		State.RUN:
# 			pass
# 	state = new_state

# func handle_input() -> void:
# 	if input_direction.x == Vector2.RIGHT.x:
# 		if Vector2.RIGHT not in input_queue: input_queue.append(Vector2.RIGHT)
# 	else:
# 		if Vector2.RIGHT in input_queue: input_queue.erase(Vector2.RIGHT)
# 	if input_direction.x == Vector2.LEFT.x:
# 		if Vector2.LEFT not in input_queue: input_queue.append(Vector2.LEFT)
# 	else:
# 		if Vector2.LEFT in input_queue: input_queue.erase(Vector2.LEFT)
# 	if input_direction.y == Vector2.DOWN.y:
# 		if Vector2.DOWN not in input_queue: input_queue.append(Vector2.DOWN)
# 	else:
# 		if Vector2.DOWN in input_queue: input_queue.erase(Vector2.DOWN)
# 	if input_direction.y == Vector2.UP.y:
# 		if Vector2.UP not in input_queue: input_queue.append(Vector2.UP)
# 	else:
# 		if Vector2.UP in input_queue: input_queue.erase(Vector2.UP)

# 	if input_queue.size() > 0:
# 		facing_direction = input_queue[0]

# func handle_state(delta: float) -> void:
# 	match state:
# 		State.IDLE:
# 			if input_direction != Vector2.ZERO:
# 				state = State.RUN
# 			else:
# 				velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
# 				velocity.y = move_toward(velocity.y, 0, FRICTION * delta)
# 		State.RUN:
# 			if input_direction == Vector2.ZERO:
# 				state = State.IDLE
# 			else:
# 				velocity = input_direction.normalized() * SPEED


# func handle_animation() -> void:
# 	if state == State.IDLE:
# 		match facing_direction:
# 					Vector2.DOWN:
# 						animated_sprite.play("idle_down")
# 					Vector2.UP:
# 						animated_sprite.play("idle_up")
# 					Vector2.LEFT, Vector2.RIGHT:
# 						animated_sprite.play("idle_side")
# 	elif state == State.RUN:
# 		match facing_direction:
# 				Vector2.DOWN:
# 					animated_sprite.play("run_down")
# 				Vector2.UP:
# 					animated_sprite.play("run_up")
# 				Vector2.LEFT, Vector2.RIGHT:
# 					animated_sprite.play("run_side")
# 	else:
# 		pass


func _physics_process(_delta: float) -> void:
	# handle_input()
	# handle_state(delta)
	# handle_animation()
	var distance_to_player = global_position.distance_to(tracked_position)
	print("Distance to player: " + str(distance_to_player))
	if tracked_position and distance_to_player > 20:
		# var track_x: float = move_toward(position.x, tracked_position.x, 50)
		# var track_y: float = move_toward(position.y, tracked_position.y, 50)
		# var tracked: Vector2 = Vector2(track_x, track_y).normalized()
		# print("Tracked " + str(tracked) + " Robo " + str(position) + " Player " + str(tracked_position))
		# 3,3 - 0,1 = 3,2 
		var direction := (tracked_position - global_position).normalized()
		velocity = velocity.lerp(direction * SPEED, 0.1)
		animated_sprite.flip_h = direction.x < 0
		animated_sprite.play("run_down")
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle_down")

	move_and_slide()
 
