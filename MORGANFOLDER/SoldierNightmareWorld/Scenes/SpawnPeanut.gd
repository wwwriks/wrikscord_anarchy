extends Area3D

var obj = preload("res://MORGANFOLDER/SoldierNightmareWorld/Prefabs/EvilPeanut.tscn")
@export var marker : Marker3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var p = obj.instantiate()
		get_tree().root.add_child(p)
		p.global_position = marker.global_position
		queue_free()
