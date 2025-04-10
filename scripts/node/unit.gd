extends Node2D
class_name Unit

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@export var unit_resource: UnitResource

var tween: Tween

var elapsed_time: float = 0.0
@export var moves_per_second: float = 5.0
var moves: Array[Vector2] = []
var moving: bool = false

func _ready() -> void:
	setup_animated_sprite()

func setup_animated_sprite() -> void:
	var animation_name = "idle"
	var sprite_frames := SpriteFrames.new()
	animatedSprite.sprite_frames = sprite_frames

	sprite_frames.add_animation(animation_name)
	sprite_frames.set_animation_loop(animation_name, true)
	sprite_frames.set_animation_speed(animation_name, 3)
	
	var sprite_path = unit_resource.sprite_path
	var sprite_texture: CompressedTexture2D = load(sprite_path)

	var hframes = 24
	var vframes = 8
	var frame_width = sprite_texture.get_width() / hframes
	var frame_height = sprite_texture.get_height() / vframes

	# Extract and add each frame from the texture to the animation
	# Create an image from the texture
	var full_image = sprite_texture.get_image()
	
	# TODO: Fix this to use all frames
	for x in range(2):
		# Define the region in the texture for the current frame
		var frame_region = Rect2(x * frame_width, 0 * frame_height, frame_width, frame_height)
		
		# Create a new image for the frame
		var frame_image = Image.create(frame_width, frame_height, false, full_image.get_format())
		
		# Copy the region from the full image to the frame image
		frame_image.blit_rect(full_image, frame_region, Vector2(0, 0))
		
		# Convert the image to a texture
		var frame_texture = ImageTexture.create_from_image(frame_image)
		
		# Add the frame texture to the animation
		sprite_frames.add_frame(animation_name, frame_texture)

	# Set the current animation to play
	animatedSprite.animation = animation_name
	animatedSprite.play(animation_name)


func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= 1.0 / moves_per_second and moves.size() > 0:
		moving = true
		var m = moves.pop_back()
		if moves.size() == 0: moving = false
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
	var path = Navigation.aStar.find_path(global_position, coord)
	moves = path

# Temporary inputs to test movement
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_position = get_global_mouse_position()
		var tile_position := Navigation.NavigationLayer.local_to_map(mouse_position)
		var global_tile_position: Vector2 = Navigation.NavigationLayer.map_to_local(tile_position)
		if global_tile_position == self.global_position:
			print("Selecting Unit: ", unit_resource.name)
			EventBus.unit_selected.emit(self)
