extends Node2D

class_name Player

@export var move_speed := 5.0
@export var bullet_scene = preload("res://bullet.tscn")  # Adjust path to your bullet scene


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
		self.rotation -= delta*move_speed 
	if Input.is_action_pressed("ui_right"):
		self.rotation += delta*move_speed


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
