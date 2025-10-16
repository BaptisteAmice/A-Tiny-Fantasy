extends Control
@onready var create_character_line_edit: LineEdit = $ScrollContainer/CharacterSlotsVBoxContainer/HBoxContainer/CreateCharacterLineEdit

@onready var character_slots_v_box_container: VBoxContainer = $ScrollContainer/CharacterSlotsVBoxContainer

const CHARACTER_SELECT_SLOT: PackedScene = preload("uid://r083atw3w18a")

const CHARACTER_NAME_MIN_LENGHT: int = 1;
const CHARACTER_NAME_MAX_LENGHT: int = 20;

func _ready() -> void:
	print("player selection ready")
	#TODO update on client side
	draw_character_slots()

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
	

func _on_create_character_button_pressed() -> void:
	var new_name: String = create_character_line_edit.text
	var name_lenght: int = new_name.length()
	#TODO FEEDBACK error
	if name_lenght < CHARACTER_NAME_MIN_LENGHT:
		print("error too short")
	elif name_lenght > CHARACTER_NAME_MAX_LENGHT:
		print("error too long")
	elif new_name in Global.game_controller.network_manager.registered_players.keys():
		print("error already taken")
	Global.game_controller.network_manager.register_player(new_name)
	draw_character_slots()
