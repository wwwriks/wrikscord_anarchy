extends Node3D

@export_file("*.tscn") var scene: String

# D
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var level: PackedScene = load(scene)
		get_tree().change_scene_to_packed(level)
