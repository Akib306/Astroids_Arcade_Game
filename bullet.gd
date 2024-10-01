extends Area2D

@export var speed: float = 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move the bullet forward
	position += Vector2(0, -speed * delta).rotated(rotation)

func _on_visible_on_screen_notifier_2d_screen_exited():
		queue_free()
