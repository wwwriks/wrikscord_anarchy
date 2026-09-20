extends CharacterBody3D

var speed=6.0
var jump_velocity=4

var mouse_sens=0.05

var current_gun="pistol"

func _ready() -> void:
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity+=get_gravity() * delta
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y=jump_velocity
	var input_dir:=Input.get_vector("left", "right", "up", "down")
	var direction:=(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x=direction.x*speed
		velocity.z=direction.z*speed
	else:
		velocity.x=move_toward(velocity.x, 0, speed)
		velocity.z=move_toward(velocity.z, 0, speed)

	move_and_slide()
