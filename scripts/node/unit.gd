extends Node2D
class_name Unit

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var clickBox: Area2D = $ClickBox
@export var unit_resource: UnitResource

var tile_coord: Vector2i:
	get:
		return TileMapUtils.get_tile_coord(global_position)

signal selected(unit: Unit)
signal unselected(unit: Unit)
signal entered_hover(unit: Unit)
signal exited_hover(unit: Unit)

var tween: Tween

@export var moves_per_second: float = 5.0
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

func move(coords) -> void:
	if coords.size() == 0:
		moving = false
		select()
		return
	moving = true
	var coord = coords.pop_back()

	if tween:
		tween.kill()
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "global_position", TileMapUtils.get_tile_center_position_from_coord(coord), 1.0 / moves_per_second).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(move.bind(coords))

func move_to(coord: Vector2i) -> void:
	var path := Level.instance.aStar.find_path(tile_coord, coord)
	if path.size() <= unit_resource.move_speed:
		unselect()
		move(path)

func select() -> void:
	selected.emit(self)

func unselect() -> void:
	unselected.emit(self)

func on_enter_hover() -> void:
	entered_hover.emit(self)

func on_exit_hover() -> void:
	exited_hover.emit(self)
