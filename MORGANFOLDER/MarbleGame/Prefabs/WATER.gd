extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.respawn()
	else:
		if body.has_method("get") and body.get("velocity"):
			body.velocity = lerp(body.velocity,Vector3.ZERO,.1)
		body.position.y+=1
