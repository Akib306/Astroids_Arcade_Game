extends Node2D

class_name Player

@export var move_speed := 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure all thrusters are initially not visible
	$LeftThruster.visible = false
	$RightThruster.visible = false
	$MainThruster.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle left movement
	if Input.is_action_pressed("ui_left"):
		$RightThruster.visible = true  # Show right thruster animation
		$LeftThruster.visible = false  # Hide left thruster
		
	elif Input.is_action_pressed("ui_right"):
		$LeftThruster.visible = true  # Show left thruster animation
		$RightThruster.visible = false  # Hide right thruster
	elif Input.is_action_pressed("ui_up"):
		$MainThruster.visible = true
	else:
		# When no keys are pressed, hide the thrusters
		$LeftThruster.visible = false
		$RightThruster.visible = false
		$MainThruster.visible = false
	
func _physics_process(delta: float) -> void:
	# writing to roation
	# workaround to rebuild contacts due to scaling a collision body
	self.rotation -= 0.0

	if Input.is_action_pressed("ui_left"):
		self.rotation -= delta*move_speed 
	if Input.is_action_pressed("ui_right"):
		self.rotation += delta*move_speed
