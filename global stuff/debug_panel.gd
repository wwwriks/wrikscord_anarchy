extends CanvasLayer

const levels: Dictionary[String, String] = {
	"ozqn one" : "uid://cm3krxqvjwrwt",
	"ball level" : "uid://cyq0iwyu5wu5h"
}

@export var level_options: OptionButton
@export var level_change_button: Button
@export var loading_screen: CanvasLayer

var selected_level: String

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug"):
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			hide()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			show()

func _ready() -> void:
	var keys := levels.keys() as Array[String]
	for i in keys.size():
		level_options.add_item(keys[i], i)
	
	selected_level = level_options.get_item_text(0)
	
	level_change_button.button_down.connect(level_change_pressed)
	level_options.item_selected.connect(on_level_option_selected)

func on_level_option_selected(index: int) -> void:
	selected_level = level_options.get_item_text(index)

func level_change_pressed() -> void:
	var tree := get_tree()
	loading_screen.visible = true
	var new_scene := await OzqnLoader.load(levels[selected_level], tree) as PackedScene
	tree.change_scene_to_packed(new_scene)
	loading_screen.visible = false
	hide()
