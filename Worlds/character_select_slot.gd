extends HBoxContainer
class_name CharacterSelectSlot

@onready var label: Label = $Label
@onready var select_character_button: Button = $SelectCharacterButton

func _ready() -> void:
	# Disable interactions for server
	if multiplayer.is_server():
		select_character_button.disabled = true

func _on_select_character_button_pressed() -> void:
	select_character(label.text)

func select_character(selected_name: String) -> void:
	#if character_name in Global.game_controller.network_manager.logged_players: #TODO error signal if already selected + also disable button on draw
	#	print("Character is already logged")
	#	return # Already logged in # TODO GET NAME FROPM OBJECTS
	Global.game_controller.network_manager.multiplayer_spawner.request_spawn.rpc(selected_name)
