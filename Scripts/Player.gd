extends CharacterBody3D


const WALK_SPEED := 3.0
const RUN_SPEED := 5.0
const CROUCH_SPEED := 1.0
const ACC = .08
const FRIC = .1
const JUMP_VELOCITY = 4.5
const RUN_SPEED_ACC := .25
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var airControl = .2
var SPEED = 0
var crouch = false
var jumping = false
var can_jump = true
var running = false
var lookCam = null

@onready var camera = $Systems/Camera
@onready var camFp := $Systems/Camera/FirstPersonCamera
@onready var arm := $Systems/Camera/SpringArm3D
@onready var checkFloor := $Systems/CheckFloor
@onready var mesh := $Mesh
@onready var anim := $Mesh/Lenny2/AnimationPlayer
@onready var skeleton := $"Mesh/Lenny2/Armature/Skeleton3D"
@onready var headBone = %HeadBone
@onready var animTree := $AnimationTree
@onready var camFpc := $%FPC
@onready var camTpc := $%TPC
@onready var StandCol := $StandCollision
@onready var CrouchCol := $CrouchCollision

@export_enum("ThirdPerson", "FirstPerson") var cameraType:int = 0 : set = cameraUpdated

func can_climb():
	if !$Systems/Camera/FirstPersonCamera/ChestRay.is_colliding():
		return false
	for ray in $Systems/Camera/FirstPersonCamera/HeadRays.get_children():
		if ray.is_colliding():
			return false
		return true

func climb():
	# Restrict Movement
	velocity = Vector3.ZERO
	can_jump = false
	
	var v_move_time := 0.4
	var _h_move_time := 0.2
	if !crouch:
		#Vertical Transforms
		var vertical_movement = global_transform.origin + Vector3(0,1.85,0)
		var vm_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		var camera_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
		vm_tween.tween_property(self, "global_transform:origin", vertical_movement, v_move_time)
		camera_tween.tween_property(camera, "rotation_degrees:x", clamp(camera.rotation_degrees.x - 20.0,-85,90), v_move_time)
		camera_tween.tween_property(camera, "rotation_degrees:z", -5.0*sign(randf_range(-10000, 10000)), v_move_time)
		
		await vm_tween.finished
		
		#Horizontal Transforms
		
func _ready():
	animTree.active = true
	cameraUpdated(cameraType)

func cameraUpdated(val):
	cameraType = val
	camFpc.current = cameraType == 1;
	camTpc.current = cameraType == 0;

func _physics_process(delta):
	lookCam = arm if cameraType == 0 else camFp
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	animTree.set("parameters/MainState/conditions/onAir", !is_on_floor())
	animTree.set("parameters/MainState/conditions/onFloor", is_on_floor() or checkFloor.is_colliding())
	
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !crouch and can_jump:
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and can_climb():
		climb()
	
	if Input.is_action_just_pressed("Crouch"):
		crouch = !crouch
		StandCol.disabled = crouch
		CrouchCol.disabled = !crouch
		animTree.set("parameters/CrouchStand/transition_request", ["crouch_to_stand","stand_to_crouch"][int(crouch)])
	
	if Input.is_action_just_pressed("camSwitch"):
#		Cameras.transition(camFpc if camTpc.current else camTpc)
		cameraType = !cameraType
	
	if crouch:
		SPEED = lerpf(SPEED, CROUCH_SPEED, RUN_SPEED_ACC)
	elif Input.is_action_pressed("Run"):
		SPEED = lerpf(SPEED, RUN_SPEED, RUN_SPEED_ACC)
		running = true
	else:
		SPEED = lerpf(SPEED, WALK_SPEED, RUN_SPEED_ACC)
		running = false
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Vector3()
	input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_dir.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
#	mesh.rotation.y = arm.rotation.y - PI
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.z)).normalized()
	var __revRot = PI if cameraType == 1 else 0.0
	
	input_dir = input_dir.rotated(Vector3.UP, lookCam.rotation.y - __revRot).normalized()
	
	if cameraType == 0:
		if direction.length() > 0:
			var _mrot = Vector2(input_dir.z, input_dir.x).angle()
			mesh.rotation.y = lerp_angle(mesh.rotation.y, _mrot, .2)
	else:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, camFp.rotation.y, .2)
	
	var __control = 1.0 if is_on_floor() else airControl
	var __interpolate = ACC if direction.length() > 0 else FRIC
	velocity.x = lerp(velocity.x, input_dir.x * SPEED, __interpolate * __control) 
	velocity.z = lerp(velocity.z, input_dir.z * SPEED, __interpolate * __control) 
	var moveLength = (transform.basis * Vector3(velocity.x, 0, velocity.z))
	animTree.set("parameters/MainState/WalkRun/blend_position", (moveLength).length())
	animTree.set("parameters/CrouchIdleWalk/blend_position", (moveLength).length())
	
	
	

	move_and_slide()

func _process(_delta):
	if cameraType == 1:
		pass

