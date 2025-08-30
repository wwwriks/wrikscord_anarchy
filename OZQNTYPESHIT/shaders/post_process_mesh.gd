@tool
extends MeshInstance3D

@export var shader: ShaderMaterial:
	set(value):
		shader = value
		self.material_override = shader
