extends Area2D

class_name bullet

@export var speed: float = 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to the "body_entered" signal
	body_entered.connect(_on_Bullet_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move the bullet forward
	position += Vector2(0, -speed * delta).rotated(rotation)

func _on_visible_on_screen_notifier_2d_screen_exited():
		queue_free()

func _on_Bullet_body_entered(body: Node) -> void:
	# Check if the body is an asteroid
	if body is asteroid:
		# Remove the bullet
		queue_free()
