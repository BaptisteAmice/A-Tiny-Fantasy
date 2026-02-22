extends Control
class_name ChatContainer

var MAX_SAVED_MESSAGES: int = 5
var MAX_DISPLAY_SECONDS: int = 10
var CLEANUP_INTERVAL_SECONDS: float = 0.1

@onready var messages_container: VBoxContainer = $MessagesContainer
@onready var line_edit: LineEdit = $LineEdit
@onready var cleanup_timer: Timer
var message_labels: Array[MessageLabel] = []

func _ready() -> void:
	Global.game_controller.signals_bus.ADD_MESSAGE_TO_DISPLAY_LIST.connect(add_message)
	Global.game_controller.signals_bus.OPEN_GAME_CHAT.connect(open_game_chat)
	Global.game_controller.signals_bus.EXIT_GAME_CHAT.connect(close_game_chat)

	for i: int in range(MAX_SAVED_MESSAGES):
		var message_label: MessageLabel = MessageLabel.new()
		messages_container.add_child(message_label)
		message_labels.append(message_label)

	prepare_timer()
	close_game_chat()

func prepare_timer() -> void:
	cleanup_timer = Timer.new()
	self.add_child(cleanup_timer)
	cleanup_timer.timeout.connect(_on_cleanup_timer_timeout)
	cleanup_timer.wait_time = CLEANUP_INTERVAL_SECONDS
	cleanup_timer.start()

func open_game_chat() -> void:
	line_edit.show()
	line_edit.grab_focus()

func close_game_chat() -> void:
	line_edit.hide()

func add_message(text: String) -> void:
	for i: int in range(0, MAX_SAVED_MESSAGES - 1):
		message_labels[i].text = message_labels[i + 1].text
		message_labels[i].set_creation_time(message_labels[i + 1].get_creation_time())
	message_labels[MAX_SAVED_MESSAGES - 1].text = text
	message_labels[MAX_SAVED_MESSAGES - 1].set_creation_time(Time.get_ticks_msec())

func _on_line_edit_text_submitted(new_text: String) -> void:
	line_edit.clear()
	Global.game_controller.chat_system.send_message_from_client(new_text)

	# todo find how to Re-focus the line edit after sending a message
	pass

func _on_cleanup_timer_timeout() -> void:
	var current_time: int = Time.get_ticks_msec()
	for message_label: MessageLabel in message_labels:
		if message_label.is_expired(current_time, MAX_DISPLAY_SECONDS):
			message_label.text = ""
	
