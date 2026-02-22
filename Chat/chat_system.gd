extends Node
class_name ChatSystem

@onready var signals_bus: SignalsBus = $"../SignalsBus"
@onready var chat_commands_manager: ChatCommandsManager = $ChatCommandsManager
var my_messages_history: Array[String] = []
const DEFAULT_HISTORY_INDEX : int = -1
var history_index: int = DEFAULT_HISTORY_INDEX


func _ready() -> void:
	signals_bus.GO_TO_PREVIOUS_GAME_CHAT_MESSAGE_IN_HISTORY.connect(previous_message_in_history)
	signals_bus.GO_TO_NEXT_GAME_CHAT_MESSAGE_IN_HISTORY.connect(next_message_in_history)

func send_message_from_client(message: String) -> void:
	if multiplayer.is_server(): return
	message = message.strip_edges()
	if message.is_empty():
		return
	add_message_to_history(message)
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
	

#### Messages history

func add_message_to_history(message: String) -> void:
	my_messages_history.append(message)
	# On met volontairement à + 1 pour y revenir avec un scroll up
	history_index = my_messages_history.size()
	
func next_message_in_history() -> void :
	var message: String
	if my_messages_history.is_empty():
		message = ""
		history_index = DEFAULT_HISTORY_INDEX
	else:
		history_index = min(
			history_index+1,
			my_messages_history.size() - 1
		)
		message =  my_messages_history[history_index]
	signals_bus.SET_GAME_CHAT_INPUT.emit(
		message
	)

func previous_message_in_history() -> void :
	var message: String
	if my_messages_history.is_empty():
		message =  ""
		history_index = DEFAULT_HISTORY_INDEX
	else:
		history_index = max(
			history_index - 1,
			0
		)
		message =  my_messages_history[history_index]
	signals_bus.SET_GAME_CHAT_INPUT.emit(
		message
	)
