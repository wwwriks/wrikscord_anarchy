extends Area3D

var obj = preload("res://MORGANFOLDER/SoldierNightmareWorld/Prefabs/EvilPeanut.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var p = obj.instantiate()
		get_tree().root.add_child(p)
		p.global_position = global_position - Vector3(0,-$CollisionShape3D.shape.radius,0)
		queue_free()
