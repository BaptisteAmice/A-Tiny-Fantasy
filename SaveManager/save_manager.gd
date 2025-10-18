extends Node
class_name SaveManager

const SAVE_FILE_PATH: String = "user://save_data.json"

func request_save_data() -> void:
	print(Global.game_controller.network_manager.get_role_and_id() + ' is asking the server to save')
	# Clients send a request to the server
	if multiplayer.is_server():
		# If we are the server, save directly
		Global.game_controller.save_manager.save_all_data_to_file()
	else:
		# If we are a client, send an RPC to the server
		rpc_id(1, "save_all_data_to_file")


func save_world() -> Dictionary:
	return {} # TODO

@rpc("any_peer")
func save_all_data_to_file() -> void:
	print(Global.game_controller.network_manager.get_role_and_id() + " is trying to save data.")
	if not multiplayer.is_server(): return
	# TODO: MAKE DICT BY SERVER ONLY
	var data: Dictionary = {
		"players": {},  # We'll fill this with all saved players
		"world": save_world()
	}
	
	# Update connected players in saved players
	for player: Player in Global.game_controller.network_manager.get_local_connected_players() :
		Global.game_controller.network_manager.registered_players[player.player_name] = player.save()
	# Add all saved players to data
	for player_name: String in Global.game_controller.network_manager.registered_players.keys():
		data["players"][player_name] = Global.game_controller.network_manager.registered_players[player_name]
	
	# JSON provides a static method to serialized JSON string.
	var json_string: String = JSON.stringify(data)
	print("json_string"+json_string)

	# TODO: SAVE THE FILES FOR THE SERVER ONLY?
	
	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
	save_file.close()
	print("Save made by " + Global.game_controller.network_manager.get_role_and_id())

# RPC should not be needed for this methode because only the server calls it
func load_data_from_file() -> void:
	print(Global.game_controller.network_manager.get_role_and_id() + " is trying to load data.")
	if not multiplayer.is_server(): return
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		print("No save file found, starting fresh")
		return
	
	var json_string: String = file.get_line()
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	var data: Dictionary = json.get_data()  # get_data() returns the parsed Dictionary
	
	# Load player data
	Global.game_controller.network_manager.registered_players = data.get("players", {})
	
	# Load world data TODO
	
	print("Load made by " + Global.game_controller.network_manager.get_role_and_id())
