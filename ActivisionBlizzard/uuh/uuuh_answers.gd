extends Node2D

@onready var holy_light: DirectionalLight2D = $holy_light
@onready var ding_1: AudioStreamPlayer = $Ding_1
@onready var ding_2: AudioStreamPlayer = $Ding_2
@onready var l: RichTextLabel = $label

func _physics_process(delta: float) -> void:
	holy_light.energy += 1*delta;

func _ready() -> void:
	ding_1.play()
	if UuuhGlobal.progress == 1:
		l.text = "I am the angry pumpkin."
	if UuuhGlobal.progress == 2:
		l.text = "The architect and the builder, they arrive calmly from their escalator with the sense of purpose."
	if UuuhGlobal.progress == 3:
		l.text = "They are playing at their residence. The head is soaring."

func _on_last_sound_timeout() -> void:
	ding_2.play()



func _on_ding_2_finished() -> void:
	if UuuhGlobal.progress < 3:
		get_tree().change_scene_to_file("res://ActivisionBlizzard/uuh/uuh.tscn")
	if UuuhGlobal.progress >= 3:
		# replace with any cool place
		get_tree().change_scene_to_file("res://ActivisionBlizzard/tomato_museum/museum.tscn")
		
	UuuhGlobal.progress += 1
