extends Node
class_name ChatCommand

var command_name_in_chat: String
var instantiated_command: Command

func _init(p_command_name_in_chat: String) -> void:
	command_name_in_chat = p_command_name_in_chat

## Retourne un string vide si il n'y a pas de problème, sinon le problème rencontré
func prepare_command(_params: Array[String]) -> String:
	return "prepare_command() not implemented for this ChatCommand!"

func execute_command() -> String:
	if instantiated_command == null:
		return "Command not set for this ChatCommand!"
	return instantiated_command.execute()
