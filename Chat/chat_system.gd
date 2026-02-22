extends Node
class_name ChatSystem

func send_message_from_client(message: String) -> void:
	if multiplayer.is_server(): return
	if message.strip_edges().is_empty():
		return
	if message.begins_with("/"):
		process_command_on_client_from_message(message)
	else:
		#send message to server
		rpc_id(1, "_server_receive_message", message)

func process_command_on_client_from_message(message: String) -> void:
	if multiplayer.is_server(): return 
	Global.game_controller.signals_bus.ADD_MESSAGE_TO_DISPLAY_LIST.emit(message)
	#todo
	pass

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
	
