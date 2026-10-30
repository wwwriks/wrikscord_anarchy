extends Area3D

@export var speed: float = 100.0
@export var damage: int = 15
@export var lifetime: float = 5.0

var direction: Vector3

func _ready() -> void:
	direction=-global_transform.basis.z
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position+=direction*speed*delta

#func _on_body_entered(body: Node3D) -> void:
	#print(body.name)
	#if body.is_in_group("player"):
		#pass
	#if body.has_method("take_damage_enemy"):
		#body.take_damage_enemy()
		#queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.name.begins_with("Hitbox"):
		if area.has_method("damage"):
			area.damage()
			queue_free()
