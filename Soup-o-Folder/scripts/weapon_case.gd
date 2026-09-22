extends Node3D

func _on_weapon_box_area_body_entered(body: Node3D) -> void:
	if body.name.begins_with("player"):
		%player.change_weapon("machinegun")
		queue_free()
