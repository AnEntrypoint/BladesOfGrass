extends CharacterBody3D

@onready var visuals = $visuals
@onready var spring_arm_3d = $CameraController/SpringArm3D

@export var min_pitch = -80  # Minimum pitch angle in degrees
@export var max_pitch = 80   # Maximum pitch angle in degrees
@export var sensitivity = 0.5 # Mouse sensitivity

#@export var acceleration = 70
#@export var friction = 60
#@export var air_friction = 10

var SPEED = 0 # Initial speed
var walk_speed = 3.0 # Walking speed
var run_speed = 10 # Running speed
var running = false

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # lock cursor
	pass

func _unhandled_input(event):
	if event.is_action_pressed("click"): # if left click pressed
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # lock cursor
	
	if event.is_action_pressed("toggle_mouse_captured"): # if escape pressed
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: # check cursor lock
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # toggle cursor lock
		else: 
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # lock cursor

func _input(event):
	if event is InputEventMouseMotion:
		# Rotate the spring arm based on the mouse movement
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		visuals.rotate_y(deg_to_rad(event.relative.x * sensitivity))
		spring_arm_3d.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		# Clamp the pitch angle to the specified range
		var current_pitch = spring_arm_3d.rotation_degrees.x
		current_pitch = clamp(current_pitch, min_pitch, max_pitch)
		spring_arm_3d.rotation_degrees.x = current_pitch

func _physics_process(delta):
	
	if Input.is_action_just_pressed("run"):
		print("i should be running")
		running = true
		SPEED = run_speed
	else:
		print("i should be walking") 
		running = false
		SPEED = walk_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
#	$AnimationTree.set("parameters/conditions/idle1", input_dir == Vector2.ZERO && is_on_floor())
#	$AnimationTree.set("parameters/conditions/walking1", input_dir != Vector2.ZERO && is_on_floor())
#	$AnimationTree.set("parameters/conditions/runnnng2", running == true && is_on_floor())
	move_and_slide()
