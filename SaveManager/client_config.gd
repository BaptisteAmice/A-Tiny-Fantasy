class_name ClientConfig
extends Resource

@export var language: String : set = set_language
@export var global_volume: float = 1.0 : set = set_global_volume
@export var music_volume: float = 1.0 : set = set_music_volume
@export var sfx_volume: float = 1.0 : set = set_sfx_volume

func set_language(value: String) -> void:
	language = value
	# Set the currently used langage
	TranslationServer.set_locale(value)
	Global.game_controller.save_manager.save_ressource_at_path(self, Constants.CLIENT_CONFIG_SAVE_FILE_PATH)

func set_global_volume(value: float) -> void:
	global_volume = value
	#todo specific treatment
	Global.game_controller.save_manager.save_ressource_at_path(self, Constants.CLIENT_CONFIG_SAVE_FILE_PATH)

func set_music_volume(value: float) -> void:
	music_volume = value
	#todo specific treatment
	Global.game_controller.save_manager.save_ressource_at_path(self, Constants.CLIENT_CONFIG_SAVE_FILE_PATH)

func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	#todo specific treatment
	Global.game_controller.save_manager.save_ressource_at_path(self, Constants.CLIENT_CONFIG_SAVE_FILE_PATH)
