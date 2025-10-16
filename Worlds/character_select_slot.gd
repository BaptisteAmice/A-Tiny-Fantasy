extends HBoxContainer
class_name CharacterSelectSlot

var character_name: String
@onready var label: Label = $Label

func _on_select_character_button_pressed() -> void:
	select_character(character_name)

func select_character(selected_name: String) -> void:
	print("select_char")
	#if character_name in Global.game_controller.network_manager.logged_players:
	#	print("Character is already logged")
	#	return # Already logged in # TODO GET NAME FROPM OBJECTS
	Global.game_controller.network_manager.multiplayer_spawner.request_spawn.rpc(selected_name)
