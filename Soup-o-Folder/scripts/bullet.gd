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

func _on_area_entered(area: Area3D) -> void:
	if area.name.begins_with("Hitbox"):
		if area.has_method("damage"):
			area.damage()
		var player=get_tree().get_first_node_in_group("Player")
		if player and player.current_gun=="awp":
			return
		queue_free()
