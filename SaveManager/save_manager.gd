extends Node
class_name SaveManager

const SAVE_FILE_PATH: String = "user://save_data.json"

func save_world() -> Dictionary:
	return {} # TODO


func save_all_data_to_file() -> void:
	var data: Dictionary = {
		"players": {},  # We'll fill this with all saved players
		"world": save_world()
	}
	
	# Update connected players in saved players
	for player: Player in Global.game_controller.network_manager.logged_players:
		Global.game_controller.network_manager.registered_players[player.player_name] = player.save()
	# Add all saved players to data
	for player_name: String in Global.game_controller.network_manager.registered_players.keys():
		data["players"][player_name] = Global.game_controller.network_manager.registered_players[player_name]
	
	# JSON provides a static method to serialized JSON string.
	var json_string: String = JSON.stringify(data)
	print("json_string"+json_string)
	
	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
	save_file.close()
	
func load_data_from_file() -> Dictionary:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		print("No save file found, starting fresh")
		return {}
	
	var json_string: String = file.get_line()
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return {}
	var data: Dictionary = json.get_data()  # get_data() returns the parsed Dictionary
	return data
