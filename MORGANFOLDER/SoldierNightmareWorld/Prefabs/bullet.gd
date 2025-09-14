extends RigidBody3D

@export var damage = 15
var lifetime = 3

func setVelocity(dir,mag):
	rotation = dir
	linear_velocity = dir*mag
	pass

func _process(delta: float) -> void:
	lifetime -= 1*delta
	if lifetime<=0: queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		pass
	else:
		queue_free()
