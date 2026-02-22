extends Node
class_name ChatSystem

@onready var chat_commands_manager: ChatCommandsManager = $ChatCommandsManager


func send_message_from_client(message: String) -> void:
	if multiplayer.is_server(): return
	message = message.strip_edges()
	if message.is_empty():
		return
	if message.begins_with("/"):
		process_command_on_client_from_message(message)
	else:
		# add the player's name to the message
		message = PlayerManager.my_player.name_label.text + "> " + message
		#send message to server
		rpc_id(1, "_server_receive_message", message)

func process_command_on_client_from_message(message: String) -> void:
	if multiplayer.is_server(): return
	Global.game_controller.signals_bus.ADD_MESSAGE_TO_DISPLAY_LIST.emit(message)
	var command_result: String = chat_commands_manager.parse_command_from_message(message)
	Global.game_controller.signals_bus.ADD_MESSAGE_TO_DISPLAY_LIST.emit(command_result)
	

@rpc("any_peer")
func _server_receive_message(message: String) -> void:
	if !multiplayer.is_server(): return
	Global.game_controller.signals_bus.ADD_MESSAGE_TO_DISPLAY_LIST.emit(message)
	#broadcast message to clients
	rpc("_client_receive_message", message)
	
	

@rpc("any_peer")
func _client_receive_message(message: String) -> void:
	if multiplayer.is_server(): return
	Global.game_controller.signals_bus.ADD_MESSAGE_TO_DISPLAY_LIST.emit(message)
	
