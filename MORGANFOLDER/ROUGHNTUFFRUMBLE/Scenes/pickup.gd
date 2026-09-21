extends RigidBody3D

@export var unlocksPortal : bool
@export var unlockAmount : int
@export var portalUnlock : Node3D
var canCollect = true

func collected(_off) -> void:
	$Sprite3D.visible = false
	$CollisionShape3D.disabled = true
	canCollect = false
	$Timer.start(7.5)
	$GPUParticles3D.emitting = true
	
	if unlocksPortal:
		if portalUnlock!=null and _off.score>=unlockAmount:
			portalUnlock.unlock()

func _on_timer_timeout() -> void:
	$CollisionShape3D.disabled = false
	$Sprite3D.visible = true
	canCollect = true
