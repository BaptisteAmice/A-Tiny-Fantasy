extends Node
class_name SaveManager

# Signal to notify completion
signal save_confirmed

@rpc("any_peer", "call_remote", "reliable")
func save_confirmed_by_server() -> void:
	print("Client received save confirmation from server")
	emit_signal("save_confirmed")

## Coroutine
func request_save_data() -> void:
	print(Global.game_controller.network_manager.get_role_and_id() + ' is asking the server to save')
	# Clients send a request to the server
	if multiplayer.is_server():
		# If we are the server, save directly
		Global.game_controller.save_manager.save_all_data_to_file()
	else:
		# If we are a client, send an RPC to the server
		rpc_id(1, "save_all_data_to_file")
		await self.save_confirmed  # Wait for the confirmation signal from the server


func save_world() -> Dictionary:
	var world_data: Dictionary = {}
	if not multiplayer.is_server():
		printerr("This method should only be called by the server and has been called by " + Global.game_controller.network_manager.get_role_and_id())
		return world_data
	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("Persist")
	for node: Node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty() and not node.is_in_group("PersistLite"):
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

	var save_file: FileAccess = FileAccess.open(Constants.SAVE_FILE_PATH, FileAccess.WRITE)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
	save_file.close()
	print("Save made by " + Global.game_controller.network_manager.get_role_and_id())
	rpc("save_confirmed_by_server") # broadcast to clients that save is done

# RPC should not be needed for this methode because only the server calls it
func load_data_from_file() -> void:
	print(Global.game_controller.network_manager.get_role_and_id() + " is trying to load data.")
	if not multiplayer.is_server(): return
	var file: FileAccess = FileAccess.open(Constants.SAVE_FILE_PATH, FileAccess.READ)
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
		var loaded_node: Node2D = null
		var node_data: Dictionary = world_data[node_key]
		# Firstly, we need to create the object and add it to the tree and set its position.
		# Only do it for nodes not in PersistLite (so with a saved filename amongother things)
		if node_data.get("filename", "") != "":
			var file_name : String = node_data["filename"]
			var scene_resource : PackedScene = load(file_name)
			# Shouldn't need to instantiate something else than a Node2D
			loaded_node = scene_resource.instantiate()
			var node_parent_path: NodePath = node_data["parent"]
			get_node(node_parent_path).add_child(loaded_node, true)
			# Warning : could cause problems because float is on 64 bits but Vector2 use values on 32 bits
			var node_pos_x: float = node_data["pos_x"]
			var node_pos_y: float = node_data["pos_y"]
			loaded_node.position = Vector2(node_pos_x, node_pos_y)
			# Now we set the remaining variables.
			for var_name: String in node_data.keys():
				if var_name == "filename" or var_name == "parent" or var_name == "pos_x" or var_name == "pos_y":
					continue
				loaded_node.set(var_name, node_data[var_name])
		
		else:
			#for PeristLite, get the node in the tree
			var node_path_str: String = node_data.get("persist_lite_path", "")
			if node_path_str != "":
				loaded_node = get_node(node_path_str) as Node2D
				loaded_node.call("load", node_data)
			else:
				print("Warning: no filename and no path for node_key ", node_key)
				continue
				
	
	print("Load made by " + Global.game_controller.network_manager.get_role_and_id())
	
func remove_persistant_nodes() -> void :
	var persistant_nodes: Array[Node] = get_tree().get_nodes_in_group("Persist")
	for node: Node in persistant_nodes:
		if not node.is_in_group("PersistLite"):
			node.queue_free()
	
####### CLIENT SIDE SAVE AND LOAD

## Should not be used for important data, as it is dependent on the OS id, that can change.
func save_ressource_at_path(resource: Resource, path: String) -> void:
	# Can't just save as is (_ready could be updated in the file!!!), so we use a temp file to encrypt the save
	var password: String = get_encryption_password()
	var temp_path: String = Constants.TEMP_RESOURCE_SAVE_FILE_PATH
	ResourceSaver.save(resource, temp_path)
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.READ)
	var buffer: PackedByteArray = file.get_buffer(file.get_length())
	file.close()
	
	var encrypted_file: FileAccess = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, password)
	encrypted_file.store_buffer(buffer)
	encrypted_file.close()
 
	DirAccess.remove_absolute(temp_path)
	
func load_ressource_at_path(path: String, res_type: GDScript) -> Resource:
	var password: String = get_encryption_password()
	var temp_path: String = Constants.TEMP_RESOURCE_SAVE_FILE_PATH
	var file: FileAccess = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, password)
	if not file:
		return res_type.new()
 
	var buffer: PackedByteArray = file.get_buffer(file.get_length())
	file.close()
 
	var temp_file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	temp_file.store_buffer(buffer)
	temp_file.close()
 
	var res: Resource = ResourceLoader.load(temp_path)
	DirAccess.remove_absolute(temp_path)
 
	return res

func get_encryption_password() -> String:
	var salt: String = "16BitDev"
	# Can only be used on the same computer
	var password: String = (salt + OS.get_unique_id()).sha256_text()
 
	return password
