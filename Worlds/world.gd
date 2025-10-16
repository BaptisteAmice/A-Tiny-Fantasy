extends Node2D
class_name World

func _ready() -> void:
	pass


func _on_save_button_pressed() -> void:
	Global.game_controller.save_manager.save_all_data_to_file()


func _on_exit_button_pressed() -> void:
	#  Save data
	Global.game_controller.save_manager.save_all_data_to_file()
	# Disconnect from the server
	Global.game_controller.network_manager.disconnect_client()
	# return to main menu 
	Global.game_controller.change_scene("res://Menus/main_menu.tscn")


func _on_close_server_button_pressed() -> void:
	Global.game_controller.network_manager.close_server()
