extends Node3D

func _ready() -> void:
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func _on_yes_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Soup-o-Folder/scenes/arena.tscn")

func _on_no_button_pressed() -> void:
	get_tree().quit()
