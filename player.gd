extends Area2D

class_name player

@export var rotation_speed := 5.0
@export var bullet_scene = preload("res://bullet.tscn")
@export var velocity = Vector2.ZERO
@export var bullet_recoil := 50  # Force applied to ship when firing a bullet
@export var max_velocity := 200  # Maximum velocity of the player's ship
@export var max_health := 100  # Maximum health of the player's ship

var health := max_health  # Current health of the player's ship

# Flags to track if animations are playing
var warp_animation_playing = false
var shooting_animation_playing = false
var sparks_animation_playing = false

# Timer for reloading the scene after destruction
var reload_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure all thrusters are initially not visible
	$LeftThruster.visible = false
	$RightThruster.visible = false
	
	$WarpAnimation.visible = false
	# Connect the animation_finished signal
	$WarpAnimation.frame_changed.connect(_on_WarpAnimation_frame_changed)
	
	$ShootingAnimation.visible = false
	# Connect the animation_finished signal for shooting animation
	$ShootingAnimation.frame_changed.connect(_on_ShootingAnimation_frame_changed)
	
	# Ensure CollisionSparks is initially hidden
	$CollisionSparks.visible = false

	# Connect the area_entered signal
	area_entered.connect(_on_player_area_entered)

	# Connect the animation_finished signal for CollisionSparks
	$CollisionSparks.animation_finished.connect(_on_CollisionSparks_animation_finished)
	
	# Ensure DeathAnimation is initially hidden
	$DeathAnimation.visible = false
	# Connect the animation_finished signal for DeathAnimation
	$DeathAnimation.animation_finished.connect(_on_DeathAnimation_animation_finished)

	# Initialize the reload_timer
	reload_timer = Timer.new()
	reload_timer.wait_time = 1.0  # Wait for 1 second
	reload_timer.one_shot = true
	reload_timer.connect("timeout", Callable(self, "_on_ReloadTimer_timeout"))
	add_child(reload_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Show the opposite thruster for the intended movement direction as per Newton's third law
	if Input.is_action_pressed("ui_left"):
		$RightThruster.visible = true  
		$LeftThruster.visible = false  
	elif Input.is_action_pressed("ui_right"):
		$LeftThruster.visible = true  
		$RightThruster.visible = false 
	else:
		# When no keys are pressed, hide the thrusters
		$LeftThruster.visible = false
		$RightThruster.visible = false

	# Handle firing bullets when SPACEBAR is pressed
	if Input.is_action_just_pressed("ui_select"):  # ui_select is mapped to SPACEBAR by default
		fire_bullet()
		
	# Update health bar value
	$"../Control/HealthBar".value = health
	

func _physics_process(delta: float) -> void:
	# writing to roation
	self.rotation -= 0.0

	if Input.is_action_pressed("ui_left"):
		self.rotation -= delta*rotation_speed 
	
	if Input.is_action_pressed("ui_right"):
		self.rotation += delta*rotation_speed

	# Apply velocity to the position of the ship
	position += velocity * delta

	# Handle screen warping after updating position
	handle_screen_warping()

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
	
	# Apply recoil to the ship
	var recoil = Vector2(0, bullet_recoil).rotated(rotation)
	velocity += recoil
	
	# Play the shooting animation
	if not shooting_animation_playing:
		shooting_animation_playing = true
		$ShootingAnimation.visible = true
		$ShootingAnimation.play("default")
		
	# Play the bullet firing sound
	$BulletFireAudio.play()


# Function to handle screen warping 
func handle_screen_warping() -> void:
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
	var warped = false

	# Warp horizontally
	if position.x < min_x:
		new_position.x = max_x - 1 
		warped = true
	elif position.x > max_x:
		new_position.x = min_x + 1
		warped = true

	# Warp vertically
	if position.y < min_y:
		new_position.y = max_y - 1
		warped = true
	elif position.y > max_y:
		new_position.y = min_y + 1 
		warped = true

	# Update position and play the warp animation if warping occurred
	if warped:
		position = new_position
		if not warp_animation_playing:
			warp_animation_playing = true
			$WarpAnimation.visible = true
			$WarpAnimation.play("default")

func _on_WarpAnimation_frame_changed():
	if $WarpAnimation.frame == $WarpAnimation.sprite_frames.get_frame_count($WarpAnimation.animation) - 1:
		warp_animation_playing = false
		$WarpAnimation.visible = false
		$WarpAnimation.stop()

# Called when the shooting animation frame changes
func _on_ShootingAnimation_frame_changed():
	if $ShootingAnimation.frame == $ShootingAnimation.sprite_frames.get_frame_count($ShootingAnimation.animation) - 1:
		shooting_animation_playing = false
		$ShootingAnimation.visible = false
		$ShootingAnimation.stop()

func _on_player_area_entered(area: Area2D) -> void:
	if area is asteroid:
		# Reduce health
		health -= 20
		if health < 0:
			health = 0

		# Update the health bar
		$"../Control/HealthBar".value = health

		# Play CollisionSparks animation
		if not sparks_animation_playing:
			sparks_animation_playing = true
			$CollisionSparks.visible = true
			$CollisionSparks.play("default")  
		
			$CollisionAudio.play()
		
		$CollisionAudio.play()
		
		# Play death animation if health reaches 0
		if health == 0:
			$PlayerSprite.visible = false
			$DeathAnimation.visible = true
			$DeathAnimation.play("default")
			
			


func _on_CollisionSparks_animation_finished():
	sparks_animation_playing = false
	$CollisionSparks.visible = false


# Called when the death animation finishes
func _on_DeathAnimation_animation_finished():
	# Start the reload timer
	if not reload_timer.is_connected("timeout", Callable(self, "_on_ReloadTimer_timeout")):
		reload_timer.connect("timeout", Callable(self, "_on_ReloadTimer_timeout"))
	reload_timer.start()
	# Optionally, hide the player or perform additional cleanup
	# $PlayerSprite.queue_free()  # Uncomment if you want to remove the sprite
	
# Callback function for the reload timer
func _on_ReloadTimer_timeout():
	# Reload the current scene
	print("Reloading scene...")
	get_tree().reload_current_scene()
