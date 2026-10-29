extends Node3D

func _on_hp_box_area_body_entered(body: Node3D) -> void:
	if body.name.begins_with("player"):
		%player.hp+=1
		%player.blood_handler()
		queue_free()
