extends Node2D

@onready var irc_manager: Node = $IRC_Manager
@onready var chat_history: RichTextLabel = $chat_history
@onready var line_edit: LineEdit = $LineEdit


func _on_button_pressed() -> void:
	irc_manager.send_message(line_edit.text)
	
	chat_history.text += irc_manager.nickname + " (YOU): "+ line_edit.text + "\n"
	
	line_edit.text = ""


func _on_irc_manager_recived_irc(message) -> void:
	chat_history.text += message
	chat_history.text += "\n"
