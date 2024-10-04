extends Node2D

class_name asteroid_spawn_manager

@export var asteroid_scene = preload("res://asteroid.tscn")
@export var spawn_interval := 3.0  # Time between spawns in seconds
@export var spawn_distance := 50   # Distance outside the camera view to spawn asteroids
@export var min_speed := 50        # Minimum speed of asteroids
@export var max_speed := 150       # Maximum speed of asteroids
@export var angle_variance := 0.5  # Randomness in the direction (radians)

func _ready() -> void:
	# Create and start a timer to spawn asteroids periodically
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_Timer_timeout)
	add_child(timer)

func _on_Timer_timeout() -> void:
	spawn_asteroid()

func spawn_asteroid() -> void:
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		print("No camera found!")
		return

	# Get camera's boundaries in world coordinates
	var viewport_size = get_viewport().get_visible_rect().size
	var zoom = camera.zoom

	# Adjust the viewport size based on the camera's zoom
	var adjusted_viewport_size = Vector2(
		viewport_size.x * zoom.x,
		viewport_size.y * zoom.y
	)

	# Calculate half the adjusted viewport size
	var half_width = adjusted_viewport_size.x / 2
	var half_height = adjusted_viewport_size.y / 2

	# Get the camera's center position
	var camera_position = camera.global_position

	# Calculate the visible boundaries in world coordinates
	var min_x = camera_position.x - half_width
	var max_x = camera_position.x + half_width
	var min_y = camera_position.y - half_height
	var max_y = camera_position.y + half_height

	# Decide on which side to spawn the asteroid (0: top, 1: bottom, 2: left, 3: right)
	var side = randi() % 4
	var spawn_position = Vector2()

	match side:
		0:
			# Top side
			spawn_position.x = randf_range(min_x, max_x)
			spawn_position.y = min_y - spawn_distance
		1:
			# Bottom side
			spawn_position.x = randf_range(min_x, max_x)
			spawn_position.y = max_y + spawn_distance
		2:
			# Left side
			spawn_position.x = min_x - spawn_distance
			spawn_position.y = randf_range(min_y, max_y)
		3:
			# Right side
			spawn_position.x = max_x + spawn_distance
			spawn_position.y = randf_range(min_y, max_y)

	# Instantiate the asteroid
	var asteroid_instance = asteroid_scene.instantiate()
	add_child(asteroid_instance)
	asteroid_instance.global_position = spawn_position

	# Compute the direction towards the center of the camera view
	var target_position = camera_position
	var direction = (target_position - spawn_position).normalized()

	# Apply randomness to the direction
	var angle_offset = randf_range(-angle_variance, angle_variance)
	direction = direction.rotated(angle_offset)

	# Randomize the velocity magnitude
	var speed = randf_range(min_speed, max_speed)
	var initial_velocity = direction * speed

	# Set the asteroid's initial_velocity
	asteroid_instance.initial_velocity = initial_velocity
