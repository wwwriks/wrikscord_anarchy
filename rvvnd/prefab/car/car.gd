extends CharacterBody3D

@onready var rightWheel: MeshInstance3D = $"Model/wheel-front-right"
@onready var leftWheel: MeshInstance3D = $"Model/wheel-front-left"
@onready var carBody: MeshInstance3D = $Model/body
@onready var camera: Camera3D = $Camera

@export_group("Movement/Acceleration & Speed")
@export var accel := 40.0
@export var accel_against := 160.0
@export var max_speed := 150.0
@export var min_turn_speed := 10.0
@export_group("Movement/Friction & Turning")
@export var friction := 60.0
@export var turn_speed := 2.5
@export var bank_angle := 15.0
@export_group("Movement/Gravity")
@export var gravity := 30.0
@export var fall_gravity := 45.0
@export_group("Camera")
@export var base_fov := 70.0
@export var max_fov := 100.0
@export var fov_lerp_speed := 5.0
@export var camera_follow_smoothness := 5.0
@export var camera_offset_strength := 0.5

var input_dir := Vector2.ZERO
var accel_input := 0.0
var steer_input := 0.0

## Internal running speed along car forward (u/s)
var _speed := 0.0

func _handle_input():
	input_dir = Input.get_vector("left", "right", "up", "down")
	accel_input = -input_dir.y
	steer_input = input_dir.x

func _update_meshes(delta: float):
	var wheel_rotation = _speed * delta * 0.1
	rightWheel.rotation.x += wheel_rotation
	leftWheel.rotation.x += wheel_rotation

	var steer_angle = deg_to_rad(25.0) * steer_input
	rightWheel.rotation.y = -steer_angle
	leftWheel.rotation.y = -steer_angle

	var target_bank = deg_to_rad(-steer_input * bank_angle) * get_speed_percent()
	carBody.rotation.z = lerp(carBody.rotation.z, target_bank, 8.0 * delta)

	var accel_pitch = clamp(accel_input * 0.1, -0.15, 0.15)
	carBody.rotation.x = lerp(carBody.rotation.x, accel_pitch, 3.0 * delta)

func _update_physics(delta: float):
	var forward = -global_transform.basis.z.normalized()
	var current_speed = _speed

	if accel_input > 0.01:
		current_speed += accel * delta * accel_input
	elif accel_input < -0.01:
		if current_speed > 0.0:
			current_speed = max(0.0, current_speed - accel_against * delta * (-accel_input))
		else:
			current_speed -= accel * delta * (-accel_input)
	else:
		var friction_step = friction * delta
		if abs(current_speed) <= friction_step:
			current_speed = 0.0
		else:
			current_speed -= sign(current_speed) * friction_step

	var max_reverse = max_speed * 0.5
	current_speed = clamp(current_speed, -max_reverse, max_speed)
	_speed = current_speed

	var speed_factor = clamp(abs(_speed), min_turn_speed, max_speed)
	speed_factor = (speed_factor - min_turn_speed) / (max_speed - min_turn_speed) # normalized 0-1
	var rot_amount = -steer_input * turn_speed * delta * speed_factor * sign(_speed) if _speed != 0.0 else 0.0
	rotate_y(rot_amount)

	if is_on_floor():
		velocity.y = -0.1
	else:
		velocity.y -= fall_gravity * delta

	velocity.x = forward.x * _speed
	velocity.z = forward.z * _speed
	move_and_slide()

	if abs(_speed) < 0.01:
		_speed = 0.0

func _update_camera(delta: float):
	var target_fov = lerp(base_fov, max_fov, get_speed_percent())
	camera.fov = lerp(camera.fov, target_fov, fov_lerp_speed * delta)

	var base_offset = Vector3(0, 3, 8).rotated(Vector3.UP, rotation.y)
	var side_offset = global_transform.basis.x * steer_input * get_speed_percent() * camera_offset_strength
	var desired_pos = global_transform.origin + base_offset + side_offset
	camera.global_transform.origin = camera.global_transform.origin.lerp(desired_pos, camera_follow_smoothness * delta)

	var target_look = global_transform.origin + Vector3.UP * 1.5
	camera.look_at(target_look, Vector3.UP)

func _update_ddraw(_delta):
	if OS.has_feature("debug"):
		DebugDraw2D.set_text("C:Speed", "%d (%d) | Scaled:%d | Y: %d | %d%% of desired" % \
			[
				self.velocity.length(),
				(self.velocity * REWIND.FLATTEN_MASK).length(),
				(self.velocity.length() / REWIND.Q_INVERSE_SCALE),
				self.velocity.y,
				get_speed_percent() * 100
			]
		)
		DebugDraw2D.set_text("C:Inputs", "Accel: %.2f | Steer: %.2f" % [accel_input, steer_input])
		DebugDraw2D.set_text("C:WheelRot", "RightWheel: %.2f | LeftWheel: %.2f" % [rightWheel.rotation.x, leftWheel.rotation.x])

func get_speed_percent() -> float:
	return _speed / max_speed

func _physics_process(delta: float) -> void:
	_handle_input()
	_update_meshes(delta)
	_update_physics(delta)
	_update_camera(delta)
	_update_ddraw(delta)
