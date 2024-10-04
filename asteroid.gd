extends Area2D

class_name asteroid

@export var min_size := 2.0
@export var max_size := 5.0
@export var min_rotation_speed := -5.0
@export var max_rotation_speed := 5.0
@export var initial_velocity := Vector2.ZERO

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

# Function to handle collision
func _on_area_entered(area: Area2D) -> void:
	# Check if the colliding area is a bullet and if the asteroid has not already been destroyed
	if area is bullet and not is_destroyed:
		is_destroyed = true  # Set flag to prevent further collisions

		# Disable collision immediately to prevent further interactions
		$CollisionPolygon2D.disabled = true

		# Play explosion animation
		play_explosion()

		# Delete the bullet
		area.queue_free()

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
