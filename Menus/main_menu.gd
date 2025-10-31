extends Node

func _on_host_button_pressed() -> void:
	Global.game_controller.network_manager.start_server()
	Global.game_controller.audio_manager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MENU_BUTTON_VALIDATE)


func _on_play_button_pressed() -> void:
	Global.game_controller.network_manager.start_client()
	Global.game_controller.audio_manager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.MENU_BUTTON_VALIDATE)
