extends Node3D

func _process(delta: float) -> void:
	if $Ball.global_position.y < -1000.0:
		get_tree().change_scene_to_file("res://Anna/world.tscn")
