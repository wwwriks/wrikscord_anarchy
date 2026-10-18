extends Node2D

@onready var irc_manager: Node = $irc_manager
@onready var chat_history: RichTextLabel = $chat_history
@onready var text_write: LineEdit = $"text_write"
@onready var hide_chat_timer: Timer = $hide_chat_timer
@onready var irc_player_ui: Node2D = $"."

var chat_typing :bool= false

var msg_buffer : Array[String]
const MSG_BUFFER_MAX := 17

func insert_msg_buffer(input: String) -> void:
	if msg_buffer.size() > MSG_BUFFER_MAX:
		msg_buffer.pop_back()
	msg_buffer.append(input)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("chat"):
		if chat_typing:
			send_message()
			toggle_chat_input()
		else:
			toggle_chat_input()
			text_write.call_deferred("grab_focus")
			chat_history.visible = true

func toggle_chat_input() -> void:
			chat_typing = !chat_typing
			text_write.visible = !text_write.visible

func send_message() -> void:
	if text_write.text == "":
		chat_history.visible = false
		return
	if text_write.text == "/disable":
		irc_player_ui.set_process(false)
		irc_player_ui.visible = false
		return
	irc_manager.send_message(text_write.text)
	
	var new_line :String= irc_manager.nickname + " (YOU): "+ text_write.text + "\n"
	insert_msg_buffer(new_line)
	update_chat_history()
	
	text_write.text = ""

func _on_irc_manager_recived_irc(new_line: String) -> void:
	insert_msg_buffer(new_line+"\n")
	update_chat_history()

func update_chat_history() -> void:
	chat_history.text = ""
	for line in msg_buffer:
		chat_history.text += line
	
	chat_history.visible = true
	
	hide_chat_timer.start()


func _on_hide_chat_timer_timeout() -> void:
	if chat_typing:
		return
	chat_history.visible = false
