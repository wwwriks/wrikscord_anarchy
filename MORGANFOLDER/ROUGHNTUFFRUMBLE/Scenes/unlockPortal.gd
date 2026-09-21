extends Node3D

@export var portal : Node3D

func _ready() -> void:
	portal.visible = false
	portal.process_mode = Node.PROCESS_MODE_DISABLED

func unlock() -> void:
	portal.visible = true
	portal.process_mode = Node.PROCESS_MODE_ALWAYS
