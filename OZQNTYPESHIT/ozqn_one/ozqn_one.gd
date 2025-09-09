@tool
extends Node3D

@export_tool_button("Unwrap UV2 of meshes") var callable = unwrap_all_uv2s
@export var wind_audio: AudioStreamPlayer

func _ready() -> void:
	if Engine.is_editor_hint(): return
	wind_audio.volume_db = -60.0
	wind_audio.play()
	tween_volume()

func tween_volume() -> void:
	var tween := create_tween()
	tween.tween_property(wind_audio, "volume_db", -30.0, 3.0)

func unwrap_all_uv2s() -> void:
	var mesh_children := OzqnUtils.get_all_children_of_type(self, MeshInstance3D) as Array[MeshInstance3D]
	for mesh in mesh_children:
		ArrayMesh
		pass
