extends Area3D

@export var bulletSpeed = 50

@export var damage = 15
var lifetime = 3

var hit = false

func _ready() -> void:
	$GPUParticles3D.emitting = true

func _physics_process(delta: float) -> void:
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * bulletSpeed * delta)
	lifetime -= 1*delta
	if lifetime<=0: queue_free()

func _on_body_entered(body: Node) -> void:
	#if hit: pass
	if body.is_in_group("player"):
		pass
	else:
		hit = true
		queue_free()
