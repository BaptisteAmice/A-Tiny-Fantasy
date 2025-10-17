extends Control
class_name PlayerSelection

@onready var create_character_line_edit: LineEdit = $ScrollContainer/CharacterSlotsVBoxContainer/HBoxContainer/CreateCharacterLineEdit

@onready var character_slots_v_box_container: VBoxContainer = $ScrollContainer/CharacterSlotsVBoxContainer
@onready var error_label: Label = $ScrollContainer/CharacterSlotsVBoxContainer/ErrorLabel
@onready var connected_players_label: Label = $ScrollContainer/CharacterSlotsVBoxContainer/ConnectedPlayersLabel


const CHARACTER_SELECT_SLOT: PackedScene = preload("uid://r083atw3w18a")

const CHARACTER_NAME_MIN_LENGHT: int = 1;
const CHARACTER_NAME_MAX_LENGHT: int = 20;

func _ready() -> void:
	#TODO update on client side
	error_label.visible = false
	if self.visible: 
		draw_character_slots()
		update_connected_players_label()
	
func update_connected_players_label() -> void:
	var label_new_text: String = "Connected players: "
	for player: Player in Global.game_controller.network_manager.logged_players:
		label_new_text += player.player_name
	connected_players_label.text = label_new_text
	

func draw_character_slots() -> void:
	# Remove all existing CharacterSelectSlot children
	for child: Node in character_slots_v_box_container.get_children():
		if child is CharacterSelectSlot:
			child.queue_free()  # safely removes the node
	
	# Add new slots
	for player_name: String in Global.game_controller.network_manager.registered_players.keys():
		var slot: CharacterSelectSlot = CHARACTER_SELECT_SLOT.instantiate()
		character_slots_v_box_container.add_child(slot)
		slot.label.text = player_name

func show_error_message(message: String) -> void:
	error_label.visible = true
	error_label.text = "Error:" + message
	

func _on_create_character_button_pressed() -> void:
	var new_name: String = create_character_line_edit.text
	var name_lenght: int = new_name.length()
	if name_lenght < CHARACTER_NAME_MIN_LENGHT:
		show_error_message("Character name is too short")
	elif name_lenght > CHARACTER_NAME_MAX_LENGHT:
		show_error_message("Character name is too long")
	elif new_name in Global.game_controller.network_manager.registered_players.keys():
		show_error_message("Character name is already taken")
	else:
		Global.game_controller.network_manager.register_player(new_name)
		draw_character_slots()
