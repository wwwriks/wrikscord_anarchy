extends CharacterBody3D
	
@onready var ball_mesh: Node3D = $MeshInstance3D
@export var ball_radius: float = 0.5

@export var moveSpeed = 6
@export var maxSpeed = 56
@export var minSpeed = 24
@export var acceleration = 48
@export var jumpForce = 110
@export var doubleJumpForce = 55
@export var grav = .7

@export var jumpMax = 1
var jumps = 0

@export var mouseSens = .002
@export var respawnPoint = Vector3.ZERO

var camPivot = 0
var camPivotPosition = Vector3.ZERO
var cam = 0
var lastContactNormal: Vector3 = Vector3.UP;

#Lock the mouse in the game window and make it invisible
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camPivot = $Node3D
	camPivotPosition = camPivot.position
	cam = $Node3D/Camera3D

func _physics_process(delta: float) -> void:
	#var forAxis = Input.get_axis("up","down")
	#var mDir = sign(forAxis) * camPivot.global_transform.basis.z.normalized()
	
	var input = Input.get_vector("left", "right", "up", "down")
	var mDir = transform.basis * Vector3(input.x, 0, input.y)
	
	var tDir = mDir * maxSpeed
	var tempAccel = 1
	if velocity.length() > maxSpeed:
		mDir = Vector3.ZERO
	if velocity.length() < minSpeed and mDir.length()>0:
		tempAccel = 3
	velocity = velocity.move_toward(tDir,delta*acceleration*tempAccel)
	velocity.y -= grav
	if is_on_floor() and velocity.y > 3:
		velocity.y *= -1.1
	if is_on_floor():
		jumps = jumpMax
	if Input.is_action_just_pressed("space") and jumps > 0:
		jumps -= 1
		if is_on_floor():
			velocity.y = jumpForce
			jumps += 1
		else:
			velocity.y = doubleJumpForce
	
	move_and_slide()

	# Camera stuff
	var spd = .35*(abs(velocity.x)+abs(velocity.z))
	var tar = camPivotPosition + Vector3(0,spd*.07,spd*.25)
	camPivot.position = lerp(camPivot.position,tar,.08)

	# Make the ball mesh rotate in the direction of the movement velocity - D
	if is_on_floor():# or is_on_wall():
		lastContactNormal = get_floor_normal()
	var movement := Vector3(velocity.x, 0.0, velocity.z)
	var distance := movement.length()
	if distance >= 0.001: # don't do the rotation if movement distance is too small
		var angle := distance * delta / ball_radius
		var rotation_axis_world := lastContactNormal.cross(movement).normalized()
		var rotation_axis_local := basis.inverse() * rotation_axis_world
		ball_mesh.quaternion = (Quaternion(rotation_axis_local, angle) * ball_mesh.quaternion).normalized()

# If an input is detected
func _input(event):
	# If escaping, bring back the mouse
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Is that input the mouse moving? And are we inside the actual game window
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate This transform's y by our event's relative x (distance moved) multipled by our mouse sensitivity (distance * multiplier)
		# This rotates via top view (so left and right)
		rotate_y(-event.relative.x * mouseSens)
		# Rotate our camera according to that as well
		camPivot.rotate_x(-event.relative.y * mouseSens/3)
		# Now clamp our rotation so we can't look up or down infinitely.
		camPivot.rotation.x = clampf(camPivot.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		cam.rotation.x = clampf(cam.rotation.x, -deg_to_rad(270), deg_to_rad(250))

func respawn():
	position = respawnPoint
