extends Node3D

@export var wind_audio: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wind_audio.volume_db = -60.0
	wind_audio.play()
	tween_volume()

func tween_volume() -> void:
	var tween := create_tween()
	tween.tween_property(wind_audio, "volume_db", -30.0, 3.0)
