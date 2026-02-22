extends Node
class_name CommandProcessor

func _ready() -> void:
	Global.game_controller.signals_bus.POST_COMMAND.connect(onPostCommand)

func onPostCommand(command: Command) -> void:
	command.execute()
