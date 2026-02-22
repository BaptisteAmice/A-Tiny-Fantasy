extends Node
class_name ChatCommandsManager


func parse_command_from_message(message: String) -> String:
	# Remove the leading "/" if it's still there
	if message.begins_with("/"):
		message = message.substr(1, message.length() - 1)
	var parts: PackedStringArray = message.split(" ")
	if parts.size() == 0:
		return "The command is empty!"
	var command_name: String = parts[0]
	var params: PackedStringArray = parts.slice(1, parts.size())
	return execute_chat_command(command_name, params)

func execute_chat_command(command_name: String, params: PackedStringArray) -> String:
	var chat_command: ChatCommand = search_command_by_name(command_name)
	if chat_command == null:
		return "Unknown chat command: " + command_name
	var preparation_error_message: String = chat_command.prepare_command(params)
	if preparation_error_message and preparation_error_message.length() > 0:
		return preparation_error_message
	return chat_command.execute_command()
	
	
## Search in children for a ChatCommand with the given command_name_in_chat
func search_command_by_name(command_name: String) -> ChatCommand:
	for child: Node in get_children():
		if child is ChatCommand:
			var chat_command: ChatCommand = child as ChatCommand
			if chat_command.command_name_in_chat == command_name:
				return chat_command
	return null
