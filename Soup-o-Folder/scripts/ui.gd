extends Node2D

@export var scale_amount: float=0.4
@export var smooth_speed: float=18.0
@export var sensitivity: float=150.0
@export var threshold: float=0.15
@onready var hearts=[$Heart1, $Heart2, $Heart3]

var start_scales: Array[Vector2]=[]
var spectrum: AudioEffectSpectrumAnalyzerInstance

func _ready():
	for heart in hearts:
		start_scales.append(heart.scale)
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index==-1:
		return
	spectrum = AudioServer.get_bus_effect_instance(bus_index, 0)

func _process(delta):
	heart_handler(delta)

func heart_handler(delta):
	if not spectrum:
		return
	var volume=spectrum.get_magnitude_for_frequency_range(40.0, 150.0).length()
	var pulse=clamp((volume-threshold)*sensitivity, 0.0, scale_amount)
	for i in range(hearts.size()):
		var target_scale=start_scales[i]*(1.0+pulse)
		hearts[i].scale=hearts[i].scale.lerp(target_scale, clamp(delta*smooth_speed, 0.0, 1.0))
