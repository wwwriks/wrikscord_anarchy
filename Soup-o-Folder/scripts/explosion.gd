extends Node3D

func _ready() -> void:
	$GPUParticles3D.emitting=true

func _on_audio_stream_player_3d_finished() -> void:
	queue_free()
