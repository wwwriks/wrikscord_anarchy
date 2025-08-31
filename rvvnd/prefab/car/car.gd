# by rewind
class_name RewindCar extends CharacterBody3D

@export_group("Movement/Acceleration & Speed")
@export var acceleration := 40.0
@export var max_speed := 150.0
@export_group("Movement/Friction & Turning")
@export var friction := 60.0
@export var turn_speed := 2.5
@export var bank_angle := 15.0
@export_group("Movement/Gravity")
@export var gravity := 30.0
@export var fall_gravity := 45.0

@export_group("Camera/Settings")
@export var cam_smooth_speed := 5.0
@export var cam_offset := Vector3(0, 4, -10)
@export var cam_side_offset := 3
@export_group("Camera/Effects/FOV")
@export var fov_min := 75.0
@export var fov_max := 120.0
@export var fov_speed := 1.5
@export_group("Camera/Effects/Shake")
@export var shake_speed_threshold := 120.0
@export var shake_magnitude := 0.4

@onready var meshroot: Node3D = $meshroot
@onready var cam: Camera3D = $Camera3D

var shake_offset := Vector3.ZERO

func _ready():
	cam.fov = fov_min

func _get_grav():
	return gravity if velocity.y > 0.0 else fall_gravity

func _physics_process(delta):
	var input_dir = Input.get_vector("right","left","down","up")

	if !is_on_floor():
		velocity.y -= _get_grav() * delta

	var forward = -transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	if input_dir.y != 0:
		velocity += forward * input_dir.y * acceleration * delta
	else:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	if velocity.length() > 0.1:
		var turn = input_dir.x * turn_speed * delta * (velocity.length() / max_speed)
		rotation.y += turn
		velocity = velocity.rotated(Vector3.UP, turn)

	move_and_slide()

	_update_mesh(delta, input_dir, get_floor_normal())
	_update_cam(input_dir, delta)
	_update_fov(delta)

func _update_mesh(delta, input_dir: Vector2, floor_normal: Vector3):
	var target_bank = input_dir.x * deg_to_rad(bank_angle) * (velocity.length() / max_speed)

	var forward = -transform.basis.z
	var right = transform.basis.x

	# Project onto floor to find tilt
	var tilt_x = forward.dot(floor_normal) # nose up/down
	var tilt_z = right.dot(floor_normal)   # roll left/right

	var slope_tilt = Vector3(-tilt_x, 0, -tilt_z)

	var target_rot = Vector3(slope_tilt.x, meshroot.rotation.y, target_bank + slope_tilt.z)

	meshroot.rotation.x = lerp(meshroot.rotation.x, target_rot.x, 5.0 * delta) if true else target_rot.x
	meshroot.rotation.z = lerp(meshroot.rotation.z, target_rot.z, 5.0 * delta) if true else target_rot.z

func _update_cam(input_dir, delta):
	var desired_pos = global_transform.origin \
		+ (-global_transform.basis.z * cam_offset.z) \
		+ (Vector3.UP * cam_offset.y)

	if velocity.length() > shake_speed_threshold:
		var shake_strength = (velocity.length() / max_speed) * shake_magnitude
		shake_offset = Vector3(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		shake_offset = Vector3.ZERO

	desired_pos += shake_offset

	cam.global_transform.origin = cam.global_transform.origin.lerp(desired_pos, cam_smooth_speed * delta)

	var target_look = global_transform.origin + Vector3.UP * 1.5
	cam.look_at(target_look, Vector3.UP)

	var side_offset = transform.basis.x * (input_dir.x * cam_side_offset * (velocity.length() / max_speed))
	cam.global_transform.origin = cam.global_transform.origin.lerp((cam.global_transform.origin + side_offset), 5.0 * delta)

func _update_fov(delta):
	var speed_ratio = velocity.length() / max_speed
	var target_fov = lerp(fov_min, fov_max, speed_ratio)
	cam.fov = lerp(cam.fov, target_fov, fov_speed * delta)
