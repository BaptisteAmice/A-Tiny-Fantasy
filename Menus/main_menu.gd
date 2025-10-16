extends Node

const WORLD_SCENE_STRING: String = "uid://c7ho8gxtkvxyg"


func _on_host_button_pressed() -> void:
	Global.game_controller.network_manager.start_server()
	Global.game_controller.change_scene(WORLD_SCENE_STRING)


func _on_play_button_pressed() -> void:
	Global.game_controller.network_manager.start_client()
	Global.game_controller.change_scene(WORLD_SCENE_STRING)
