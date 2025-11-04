extends Node
class_name Localization

func _ready() -> void:
	Global.localization = self
	
	var language: String = "automatic"
	# Load here language from the user settings file
	if language == "automatic":
		var preferred_language: String = OS.get_locale_language()
		TranslationServer.set_locale(preferred_language)
	else:
		TranslationServer.set_locale(language)
