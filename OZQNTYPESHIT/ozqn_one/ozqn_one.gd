extends Node3D

@export var wind_audio: AudioStreamPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("progress_dialogue") and DialogueUI.visible == false:
		DialogueUI.start()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	wind_audio.volume_db = -60.0
	wind_audio.play()
	tween_volume()

func tween_volume() -> void:
	var tween := create_tween()
	tween.tween_property(wind_audio, "volume_db", -30.0, 3.0)
