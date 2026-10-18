extends Node

var server := "irc.vaaraniemi.se"
var port := 6667
var nickname := "bobbykotick"
var channel := "#wriksanarchy"

var tcp_stream := StreamPeerTCP.new()
var buffer := ""
var joined_irc = false
signal recived_irc(message: String)

@export var log_console = false

func gen_epic_name() -> String:
	var food = ["burger", "cheeze", "nugget", "tomato", "pizza", "burrito", "chicken", "salsa", "kebab"]
	var proprietary_random_number_generator = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "33", "34", "35", "42", "89", "19", "04", "53", "34", "81", "99", "15", "98", "04", "02", "01", "X", "64", "32", "16", "25"]
	var name = food[randi_range(0, food.size()-1)] + proprietary_random_number_generator[randi_range(0, proprietary_random_number_generator.size()-1)]
	if len(name) > 9:
		name = gen_epic_name()
	return name

func _ready() -> void:
	nickname = gen_epic_name()
	tcp_stream.connect_to_host(server, port)
	printl("Initating...")

func _process(delta):
	var tcp_status = tcp_stream.get_status()
	tcp_stream.poll()
	
	if tcp_status == StreamPeerTCP.STATUS_CONNECTING:
		printl("Connecting....")
		pass
	if tcp_status == StreamPeerTCP.STATUS_ERROR:
		printl("Error :()")
		pass
	if tcp_status == StreamPeerTCP.STATUS_CONNECTED:
		if !joined_irc:
			youshouldIRCyourselfNOW()
			joined_irc = true
		var available_bytes = tcp_stream.get_available_bytes()
		if available_bytes > 0:
			var recived_data = tcp_stream.get_data(available_bytes)
			if recived_data[0] == OK:
				buffer += recived_data[1].get_string_from_utf8()
				while "\r\n" in buffer:
					var line = buffer.split("\r\n")[0]
					buffer = buffer.substr(line.length() + 2)
					
					if "PRIVMSG #wriksanarchy :" in line:
						var nick_suffix = "!"
						var nick_end = line.find(nick_suffix)-1
						var nick = line.substr(1, nick_end)
						
						var message_prefix = "PRIVMSG #wriksanarchy :"
						var message_start_index = line.find(message_prefix) + len(message_prefix)
						var message = line.substr(message_start_index)
						
						var full_message = nick + ": "+ message
						
						printl(full_message)
						emit_signal("recived_irc", full_message)

func youshouldIRCyourselfNOW():
	printl("Connecting...")
	
	var data := ("NICK %s\r\n" % nickname).to_utf8_buffer()
	tcp_stream.put_data(data)
	
	data = ("USER %s 0 * :%s\r\n" % [nickname, nickname]).to_utf8_buffer()
	tcp_stream.put_data(data)
	
	data = ("JOIN %s\r\n" % channel).to_utf8_buffer()
	tcp_stream.put_data(data)
	
	printl("Joined "+channel)

func send_message(message):
	var data := ("PRIVMSG %s :%s\r\n" % [channel, message]).to_utf8_buffer()
	tcp_stream.put_data(data)

func printl(text):
	if log_console:
		print("[IRC] "+text)
