extends Node3D

@export var rotate_speed = 0.02

func _process(_delta: float) -> void:
	$PoliceRotator.rotation.y += rotate_speed

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_collision_layer_value(4):
		get_tree().change_scene_to_file("res://axelthings/lvl-jail.tscn")
