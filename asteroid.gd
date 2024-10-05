extends Area2D

class_name asteroid

@export var min_size := 2.0
@export var max_size := 5.0
@export var min_rotation_speed := -5.0
@export var max_rotation_speed := 5.0
@export var initial_velocity := Vector2.ZERO

@export var asteroid_scene = preload("res://asteroid.tscn")  # Preload the asteroid scene for instantiation

var rotation_speed := 0.0
var is_destroyed := false  # Flag to prevent multiple destructions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Randomize size
	var random_scale = randf_range(min_size, max_size)
	scale = Vector2(random_scale, random_scale)

	# Randomize rotational speed
	rotation_speed = randf_range(min_rotation_speed, max_rotation_speed)

	# Start asteroid moving with initial velocity
	set_physics_process(true)
	
	# Connect to the body_entered signal for collision detection
	area_entered.connect(_on_area_entered)
	
	# Ensure the explosion animation is hidden initially
	$ExplosionAnimation.visible = false
	
	# Connect to the animation_finished signal once
	$ExplosionAnimation.animation_finished.connect(_on_Explosion_animation_finished)

func _physics_process(delta: float) -> void:
	if is_destroyed:
		# Stop moving after being destroyed
		return
	
	# Update position based on velocity
	position += initial_velocity * delta

	# Rotate asteroid
	rotation += rotation_speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area is bullet and not is_destroyed:
		is_destroyed = true  # Set flag to prevent further collisions

		# Play explosion animation
		play_explosion()

		# Delete the bullet
		area.queue_free()

		# Play explosion audio
		$AsteroidExplosionAudio.play()
		
		# Determine if the asteroid should split
		var current_size = scale.x  # Assuming uniform scaling
		var new_size = current_size / 2.0

		if new_size >= min_size:
			# Spawn two smaller asteroids
			for i in range(2):
				var new_asteroid = asteroid_scene.instantiate()
				new_asteroid.scale = Vector2(new_size, new_size)
				new_asteroid.initial_velocity = calculate_new_velocity(i, new_size)
				new_asteroid.position = position  # Spawn at the same position
				get_parent().add_child(new_asteroid)
		# If the asteroid is too small, it won't split and will be removed completely
		
	elif area is player and not is_destroyed:
		# Handle collision with the ship
		var ship = area

		# Positions
		var x1 = position  # Asteroid's position
		var x2 = ship.position  # Ship's position

		# Velocities
		var v1 = initial_velocity  # Asteroid's velocity
		var v2 = ship.velocity  # Ship's velocity

		# Masses (assuming both have mass 1)
		var m1 = 1.0
		var m2 = 1.0

		# Collision normal
		var n = (x1 - x2).normalized()

		# Relative velocity
		var vr = v1 - v2

		# Relative velocity along the normal
		var vn = vr.dot(n)

		# If vn > 0, the objects are moving apart, no need to do anything
		if vn > 0:
			return

		# Coefficient of restitution (1 for elastic collision)
		var e = 1.0

		# Compute impulse scalar
		var j = -(1 + e) * vn / (1/m1 + 1/m2)

		# Apply impulse to the asteroid's velocity
		initial_velocity += (j / m1) * n

		# Apply impulse to the ship's velocity
		ship.velocity -= (j / m2) * n

func play_explosion() -> void:
	# Hide the asteroid's sprite
	$AsteroidSprite.visible = false  

	# Show and play the explosion animation
	$ExplosionAnimation.visible = true
	$ExplosionAnimation.play("default")  

func _on_Explosion_animation_finished():
	# Remove the asteroid after the explosion animation finishes
	queue_free()
	$ExplosionAnimation.visible = false

# Function to calculate bounce off the player
func _bounce_off_player(player_instance: player) -> void:
	var normal = (global_position - player_instance.global_position).normalized()

	# Reflect the velocities along the normal
	initial_velocity = initial_velocity.bounce(normal)
	player_instance.velocity = player_instance.velocity.bounce(-normal)

	# Make sure velocities are clamped to max values if necessary
	if initial_velocity.length() > max_rotation_speed:
		initial_velocity = initial_velocity.normalized() * max_rotation_speed

	if player_instance.velocity.length() > player_instance.max_velocity:
		player_instance.velocity = player_instance.velocity.normalized() * player_instance.max_velocity

# Function to calculate new velocity for the spawned asteroids
func calculate_new_velocity(index: int, new_size: float) -> Vector2:
	# Determine a direction based on the index to ensure asteroids move apart
	var angle_offset_degrees = 30.0 * (1 if index == 0 else -1)  # 30 degrees to the left and right
	var angle_offset = deg_to_rad(angle_offset_degrees)
	return initial_velocity.rotated(angle_offset).normalized() * initial_velocity.length()
