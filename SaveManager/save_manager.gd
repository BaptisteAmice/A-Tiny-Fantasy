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
	var world_data: Dictionary = {}
	if not multiplayer.is_server():
		printerr("This method should only be called by the server and has been called by " + Global.game_controller.network_manager.get_role_and_id())
		return world_data
	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("Persist")
	for node: Node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		# Call the node's save function.
		var node_data: Dictionary = node.call("save")
		world_data[node.name] = node_data
	return world_data
		


@rpc("any_peer")
func save_all_data_to_file() -> void:
	print(Global.game_controller.network_manager.get_role_and_id() + " is trying to save data.")
	if not multiplayer.is_server(): return
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
		print("No save file found, starting creating it then loading it")
		save_all_data_to_file() 
		load_data_from_file() # careful there, could lead to infinite loop if save fails
		return # stop there, the work is done in the recursive call
	
	var json_string: String = file.get_line()
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	var data: Dictionary = json.get_data()  # get_data() returns the parsed Dictionary
	
	# Load player data
	Global.game_controller.network_manager.registered_players = data.get("players", {})
	
	# Load world data
	var world_data: Dictionary = data.get("world", {})
	# We need to revert the game state so we're not cloning objects
	# we will accomplish this by deleting saveable objects.
	remove_persistant_nodes()
	# Load the data
	for node_key: String in world_data.keys():
		var node_data: Dictionary = world_data[node_key]
		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object: Node = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object, true)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		# Now we set the remaining variables.
		for var_name: String in node_data.keys():
			if var_name == "filename" or var_name == "parent" or var_name == "pos_x" or var_name == "pos_y":
				continue
			new_object.set(var_name, node_data[var_name])
	
	print("Load made by " + Global.game_controller.network_manager.get_role_and_id())
	
func remove_persistant_nodes() -> void :
	var persistant_nodes: Array[Node] = get_tree().get_nodes_in_group("Persist")
	for node: Node in persistant_nodes:
		node.queue_free()
	
