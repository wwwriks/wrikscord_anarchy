extends RigidBody3D

var canCollect = true

func collected() -> void:
	$Sprite3D.visible = false
	$CollisionShape3D.disabled = true
	canCollect = false
	$Timer.start(5)
	$GPUParticles3D.emitting = true

func _on_timer_timeout() -> void:
	$CollisionShape3D.disabled = false
	$Sprite3D.visible = true
	canCollect = true
