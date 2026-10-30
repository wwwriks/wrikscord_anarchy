extends Node3D

func _on_hp_box_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.hp=min(body.hp+1,3)
		body.blood_handler()
		queue_free()
