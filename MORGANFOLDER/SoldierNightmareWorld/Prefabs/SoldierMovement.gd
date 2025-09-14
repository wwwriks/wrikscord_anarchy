extends CharacterBody3D

@export var moveSpeed = 6
@export var maxSpeed = 18
@export var minSpeed = 6
@export var acceleration = 65
@export var jumpForce = 25
@export var doubleJumpForce = 10
@export var grav = .5

@export var jumpMax = 1
var jumps = 0

@export var mouseSens = .002
@export var controlSens = .002
@export var respawnPoint = Vector3.ZERO

var camPivot = 0
var camPivotPosition = Vector3.ZERO
var cam = 0
var barrelPosition = Vector3.ZERO
var bulletScene = load("res://MORGANFOLDER/SoldierNightmareWorld/Prefabs/Bullet.tscn")
var bulletDamage = 15
var bulletSpeed = 50
var cooldown = 0

var sprDisplay = 0
var standSpr = load("res://MORGANFOLDER/SoldierNightmareWorld/Sprites/Standing.png")
var aimSpr = load("res://MORGANFOLDER/SoldierNightmareWorld/Sprites/overShoulder.png")
var run1 = load("res://MORGANFOLDER/SoldierNightmareWorld/Sprites/Running1.png")
var run2 = load("res://MORGANFOLDER/SoldierNightmareWorld/Sprites/Running2.png")
var run3 = load("res://MORGANFOLDER/SoldierNightmareWorld/Sprites/Running3.png")
var run4 = load("res://MORGANFOLDER/SoldierNightmareWorld/Sprites/Running4.png")
var runTimer = 0
var runFrames = [run1,run2,run3,run4]
var runSpeed = 12;

#Lock the mouse in the game window and make it invisible
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camPivot = $Node3D
	camPivotPosition = camPivot.position
	cam = $Node3D/Camera3D
	sprDisplay = $Sprite3D
	barrelPosition = $BARREL

func _physics_process(delta: float) -> void:
	var input = Input.get_vector("left", "right", "up", "down")
	#FORWARD MOVEMENT DIRECTION IS BASED ON WHERE THE CAMERA IS LOOKING
	var mDir = transform.basis * Vector3(input.x, 0, input.y)
	#SIDEWAYS MOVEMENT DIRECTION IS BASED ON WHERE THE CAMERA IS LOOKING
	#var sDir = sign(strfAxis) * camPivot.global_transform.basis.x.normalized()
	var tDir = mDir * maxSpeed
	var tempAccel = 1
	if velocity.length() > maxSpeed:
		mDir = Vector3.ZERO
	if velocity.length() < minSpeed and mDir.length()>0:
		tempAccel = 4
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
		else:
			velocity.y = doubleJumpForce
	
	if velocity.length()<3: 
		sprDisplay.texture = standSpr
	else:
		#RUNNING
		var per = .15+(velocity.length()/maxSpeed);
		runTimer+=(per*runSpeed)*delta
		var ind = runTimer
		if ind>runFrames.size():
			ind = 0
			runTimer = 0
		sprDisplay.texture = runFrames[floor(ind)]
	
	move_and_slide()
	var zoom = 2;
	if Input.is_action_pressed("m2"):
		zoom = -3
		sprDisplay.texture = aimSpr
	var tar = camPivotPosition + Vector3(0,zoom*.07,zoom*.25)
	camPivot.position = lerp(camPivot.position,tar,.08)
	
	cooldown-=1*delta
	if Input.is_action_pressed("m1") and cooldown<=0:
		var b = bulletScene.instantiate()
		b.position = barrelPosition.global_position
		b.setVelocity(cam.global_rotation,bulletSpeed)
		b.damage = bulletDamage
		get_tree().root.add_child(b)
		cooldown = 12*delta;
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
	var inputMotion
	if event is InputEventJoypadMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate This transform's y by our event's relative x (distance moved) multipled by our mouse sensitivity (distance * multiplier)
		# This rotates via top view (so left and right)
		#InputEventJoypadMotion.joyAxis
		Input.get_vector()
		var _x =  JOY_AXIS_RIGHT_X;
		var _y = JOY_AXIS_RIGHT_Y;
		print(str(_x)+" : "+str(_y))
		rotate_y(-_x * controlSens)
		# Rotate our camera according to that as well
		camPivot.rotate_x(-_y * controlSens)
		# Now clamp our rotation so we can't look up or down infinitely.
		camPivot.rotation.x = clampf(camPivot.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		cam.rotation.x = clampf(cam.rotation.x, -deg_to_rad(270), deg_to_rad(250))
	
	# Is that input the mouse moving? And are we inside the actual game window
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate This transform's y by our event's relative x (distance moved) multipled by our mouse sensitivity (distance * multiplier)
		# This rotates via top view (so left and right)
		rotate_y(-event.relative.x * mouseSens)
		# Rotate our camera according to that as well
		camPivot.rotate_x(-event.relative.y * mouseSens)
		# Now clamp our rotation so we can't look up or down infinitely.
		camPivot.rotation.x = clampf(camPivot.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		cam.rotation.x = clampf(cam.rotation.x, -deg_to_rad(270), deg_to_rad(250))

func respawn():
	position = respawnPoint
