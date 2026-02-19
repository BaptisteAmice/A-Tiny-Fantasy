extends RichTextLabel

func _ready() -> void:
	if (Global.game_controller.isServer):
		text = "Server"
	else:
		text = "Client"
