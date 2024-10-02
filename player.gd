extends Node2D

class_name Player

@export var rotation_speed := 5.0
@export var bullet_scene = preload("res://bullet.tscn")  # Adjust path to your bullet scene
@export var velocity = Vector2.ZERO
@export var acceleration = 150
@export var deceleration = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure all thrusters are initially not visible
	$LeftThruster.visible = false
	$RightThruster.visible = false
	$MainThruster.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Show the opposite thruster for the intended movement direction as per Newton's third law
	if Input.is_action_pressed("ui_left"):
		$RightThruster.visible = true  
		$LeftThruster.visible = false  
		
	elif Input.is_action_pressed("ui_right"):
		$LeftThruster.visible = true  
		$RightThruster.visible = false 
		
	elif Input.is_action_pressed("ui_up"):
		$MainThruster.visible = true

	else:
		# When no keys are pressed, hide the thrusters
		$LeftThruster.visible = false
		$RightThruster.visible = false
		$MainThruster.visible = false

	# Handle firing bullets when SPACEBAR is pressed
	if Input.is_action_just_pressed("ui_select"):  # ui_select is mapped to SPACEBAR by default
		fire_bullet()

func _physics_process(delta: float) -> void:
	# writing to roation
	# workaround to rebuild contacts due to scaling a collision body
	self.rotation -= 0.0

	if Input.is_action_pressed("ui_left"):
		self.rotation -= delta*rotation_speed 
	
	if Input.is_action_pressed("ui_right"):
		self.rotation += delta*rotation_speed
	
	# Accelerate the ship when the UP arrow is pressed
	if Input.is_action_pressed("ui_up"):
		# Apply thrust in the direction the ship is facing
		var thrust = Vector2(0, -acceleration * delta).rotated(rotation)
		velocity += thrust

	# Decelerate the ship when the DOWN arrow is pressed
	if Input.is_action_pressed("ui_down"):
		if velocity.length() > 0:
			var deceleration_vector = -velocity.normalized() * deceleration * delta
			# Only apply deceleration if it does not reverse direction
			if deceleration_vector.length() > velocity.length():
				velocity = Vector2.ZERO
			else:
				velocity += deceleration_vector

	# Apply velocity to the position of the ship
	position += velocity * delta

	# Handle screen wrapping after updating position
	handle_screen_wrapping()

# Function to fire a bullet from the front of the ship
func fire_bullet() -> void:
	# Create a bullet instance
	var bullet = bullet_scene.instantiate()

	# Set the bullet's position to be at the front of the player
	# Offset the bullet's position by a distance to place it at the front of the ship
	var bullet_offset = Vector2(0, -$PlayerSprite.texture.get_height() / 6)
	bullet.global_position = global_position + bullet_offset.rotated(rotation)

	# Set the bullet's rotation to match the player's rotation
	bullet.rotation = rotation

	# Add the bullet to the current scene (to the root or a specific node)
	get_tree().root.add_child(bullet)
	
# Function to handle screen wrapping 
func handle_screen_wrapping() -> void:
	var camera = get_viewport().get_camera_2d()
	var viewport_size = get_viewport().get_visible_rect().size
	var zoom = camera.zoom

	# Adjust the viewport size based on the camera's zoom
	var adjusted_viewport_size = Vector2(
	viewport_size.x * zoom.x,
	viewport_size.y * zoom.y
	)

	# Calculate half the adjusted viewport size for boundary calculations
	var half_width = adjusted_viewport_size.x / 2
	var half_height = adjusted_viewport_size.y / 2

	# Get the camera's center position
	var camera_position = camera.global_position

	# Calculate the visible boundaries in world coordinates
	var min_x = camera_position.x - half_width
	var max_x = camera_position.x + half_width
	var min_y = camera_position.y - half_height
	var max_y = camera_position.y + half_height

	var new_position = position

	# Wrap horizontally
	if position.x < min_x:
		new_position.x = max_x
	elif position.x > max_x:
		new_position.x = min_x

	# Wrap vertically
	if position.y < min_y:
		new_position.y = max_y
	elif position.y > max_y:
		new_position.y = min_y

	position = new_position
