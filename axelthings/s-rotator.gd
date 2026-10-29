extends MeshInstance3D

@export var speed = 0.01

func _process(delta: float) -> void:
	self.rotation.y += speed
