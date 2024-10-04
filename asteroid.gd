extends Area2D

class_name asteroid

@export var min_size := 2.0
@export var max_size := 5.0
@export var min_rotation_speed := -2.0
@export var max_rotation_speed := 2.0
@export var initial_velocity := Vector2.ZERO

var rotation_speed := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Randomize size
	var random_scale = randf_range(min_size, max_size)
	scale = Vector2(random_scale, random_scale)

	# Randomize rotational speed
	rotation_speed = randf_range(min_rotation_speed, max_rotation_speed)

	# Start asteroid moving with initial velocity
	set_physics_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Update position based on velocity
	position += initial_velocity * delta

	# Rotate asteroid
	rotation += rotation_speed * delta
