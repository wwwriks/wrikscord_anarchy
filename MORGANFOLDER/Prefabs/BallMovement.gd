extends CharacterBody3D

@export var moveSpeed = 6
@export var maxSpeed = 56
@export var minSpeed = 24
@export var acceleration = 48
@export var jumpForce = 110
@export var grav = 2.4

@export var mouseSens = .002

@export var camPivot = 0
@export var cam = 0

#Lock the mouse in the game window and make it invisible
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camPivot = $Node3D
	cam = $Node3D/Camera3D

func _physics_process(delta: float) -> void:
	var forAxis = Input.get_axis("up","down")
	var mDir = sign(forAxis) * camPivot.global_transform.basis.z.normalized()
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
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = jumpForce
	move_and_slide()
	pass
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
