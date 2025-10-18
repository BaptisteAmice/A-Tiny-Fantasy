extends Node

func _on_host_button_pressed() -> void:
	Global.game_controller.network_manager.start_server()


func _on_play_button_pressed() -> void:
	Global.game_controller.network_manager.start_client()
