extends ShapeCast3D

@export var shadow: MeshInstance3D

@onready var _initial_rotation: Basis = shadow.global_transform.basis

func _physics_process(delta: float) -> void:
	for index in range(self.get_collision_count()):
		shadow.global_position = self.get_collision_point(index)

		var normal: Vector3 = self.get_collision_normal(index)

		var forward: Vector3 = normal.cross(Vector3.RIGHT)
		if forward.length_squared() < 0.001:
			forward = normal.cross(Vector3.BACK)
		forward = forward.normalized()
		var right: Vector3 = forward.cross(normal).normalized()

		var slope_basis := Basis(right, normal, -forward)

		shadow.global_transform.basis = slope_basis * _initial_rotation
