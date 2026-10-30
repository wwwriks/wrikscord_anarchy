extends Node3D

var weapon_pool=["machinegun", "gun", "shotgun", "awp"]

func _on_weapon_box_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var weapon_type=randi_range(1,len(weapon_pool))
		body.change_weapon(weapon_pool[weapon_type-1])
		queue_free()
