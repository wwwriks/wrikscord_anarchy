extends Node

@export var navigation: NavigationAgent3D
@export var character: CharacterBody3D
@export var speed: float = 2.0
@export var rotation_speed: float = 10.0
@export var player: Node3D

func _physics_process(delta: float) -> void:
	var next_pos = navigation.get_next_path_position()
	var direction = character.global_position.direction_to(next_pos)
	character.velocity = direction * speed
	character.velocity += character.get_gravity()
	character.move_and_slide()
	var target_pos: Vector3 = player.global_position if player else next_pos
	var look_dir = character.global_position.direction_to(target_pos)
	look_dir.y = 0
	if look_dir.length_squared() > 0.001:
		var target_yaw = atan2(look_dir.x, look_dir.z)
		character.rotation.y = lerp_angle(character.rotation.y, target_yaw, rotation_speed * delta)
