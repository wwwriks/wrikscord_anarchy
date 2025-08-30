extends CharacterBody3D

const MOVE_SPEED: float = 5.0

@export var camera: Camera3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera.rotation.x -= event.relative.y * 0.002
		camera.rotation.y -= event.relative.x * 0.002
		camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -89, 89)
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	
	if !is_on_floor():
		velocity.y -= 20.0*delta
	
	var input := Input.get_vector("left", "right", "up", "down")
	var direction := Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, camera.rotation.y)
	var h_vel := direction * MOVE_SPEED
	
	velocity = Vector3(h_vel.x, velocity.y, h_vel.z)
	
	move_and_slide()
