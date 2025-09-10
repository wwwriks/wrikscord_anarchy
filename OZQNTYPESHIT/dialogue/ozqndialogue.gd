extends CanvasLayer

@export var character_label: Label
@export var dialogue_label: DialogueLabel
@export var response_menu: DialogueResponsesMenu
@export var animator: AnimationPlayer

var current_text: DialogueResource
var line: DialogueLine

var in_dialogue: bool = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("progress_dialogue"):
		if self.visible:
			if dialogue_label.is_typing:
				dialogue_label.skip_typing()
				return
			if line.responses.size()>0:
				return
			next()

func _ready() -> void:
	dialogue_label.finished_typing.connect(finished_typing)
	response_menu.response_selected.connect(response_selected)
	animator.animation_finished.connect(on_anim_finished)
	hide()

func start(dialogue_path: String = "uid://2b8xc8gk53r4") -> void:
	in_dialogue = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	current_text = await OzqnLoader.load(dialogue_path, get_tree()) as DialogueResource
	line = await current_text.get_next_dialogue_line("start")
	character_label.text = line.character
	dialogue_label.visible_characters = 0
	dialogue_label.dialogue_line = line
	show()
	animator.play("fade_in")

func next(next_id: String = "") -> void:
	if next_id:
		line = await current_text.get_next_dialogue_line(next_id)
	else:
		line = await current_text.get_next_dialogue_line(line.next_id)
	
	if line == null:
		end()
		return
	
	dialogue_label.dialogue_line = line
	character_label.text = line.character
	dialogue_label.type_out()

func end() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	in_dialogue = false
	animator.play("fade_out")
	#hide()
	#current_text = null
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func response_selected(response: DialogueResponse) -> void:
	next(response.next_id)
	response_menu.responses = []

func finished_typing() -> void:
	response_menu.responses = line.responses

func on_anim_finished(animation: StringName) -> void:
	match animation:
		"fade_out":
			hide()
			current_text = null
		"fade_in":
			dialogue_label.type_out()
