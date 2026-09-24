extends Node


@export var navigation: NavigationAgent3D
@export var character: CharacterBody3D
@export var speed: float = 2.0


func _physics_process(_delta: float) -> void:
    character.velocity = character.global_position.direction_to(navigation.get_next_path_position()) * speed
    character.velocity += character.get_gravity()
    character.move_and_slide()
