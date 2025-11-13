extends Node
class_name NetworkManager

const IP_ADDRESS: String = "localhost"
const PORT: int = 42069
var peer: ENetMultiplayerPeer
var multiplayer_spawner : MultiplayerSpawnerOfPlayer

var registered_players: Dictionary = {}

const WORLD_SCENE_STRING: String = "uid://c7ho8gxtkvxyg"

# TODO good handling of deconnections and server closing

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected) # Emitted to every peers
	multiplayer.peer_disconnected.connect(_on_peer_disconnected) # Emitted to every peers

	# Check command line args to start a server if needed
	var args : PackedStringArray= OS.get_cmdline_args()
	print("Command line args: ", args)
	if "--server" in args:
		print("=====Starting server=====")
		await get_tree().create_timer(0.1).timeout # todo need to wait for everything to be ready #todo bad practice
		start_server()

func get_local_connected_players() -> Array[Player]:
	var players : Array[Player] = []
	if Global.get_world_scene() == null:
		print("Warning: world is null for " + get_role_and_id())
		return []
	for child: Node in Global.get_world_scene().get_children():
		if child is Player:
			players.append(child)
	return players

# Will be called for everyone at least once
func _on_peer_connected(peer_id: int) -> void:
	print("Client connected: ", peer_id, " called by ", get_role_and_id())
	print(get_local_connected_players())
	
	# Send all known character form the server to the clients
	if multiplayer.is_server() :
		print("im the server " + get_role_and_id())
		rpc_id(peer_id, "_sync_registered_players_from_server", registered_players)

	# Update interface for everyone
	var world_scene: World = Global.game_controller.current_scene
	world_scene.player_selection.draw_character_slots() # Used character should not be available

	# Put here all clients request on login
	# Clients should request the full map when they connect
	if not multiplayer.is_server():
		world_scene.world_tile_map.request_full_map()
	
@rpc("any_peer")
func _sync_registered_players_from_server(server_registered: Dictionary) -> void:
	if multiplayer.is_server() : return
	print("Syncing data from server for " + get_role_and_id())
	# Merge server_registered into local registered_players
	for player_name: String in server_registered.keys():
		registered_players[player_name] = server_registered[player_name]
	
	# Draw character slots
	var world_scene: World = Global.get_world_scene() 
	world_scene.player_selection.draw_character_slots()


# Will be called for everyone at least once
func _on_peer_disconnected(peer_id: int) -> void:
	print("Client disconnected: ", peer_id)
	# TODO: update logged_players and broadcast to others or not if not needed

func print_player_lists() -> void:
	print("Registered Players names: ", registered_players.keys())
	print("Logged Players: ")
	for player: Player in get_local_connected_players():
		print(player) 

func get_role_and_id() -> String:
	var role : String = "Server" if multiplayer.is_server() else "Client"
	return "%s %d" % [role, multiplayer.get_unique_id()]


## Create the server in a new window/process
func create_server(headless: bool = false) -> void:
	print("Creating dedicated server...")
	# create a new process that runs the game in dedicated server mode
	var args: Array = []
	args.append("--server")
	if headless:
		args.append("--headless") #todo need to be able to delete process when the client closes
	var server_pid: int = OS.create_process(OS.get_executable_path(), args)
	if server_pid == -1:
		print("Failed to create dedicated server process: ", server_pid)

func start_server() -> void:
	# TODO test if a server already exists
	Global.game_controller.change_scene(WORLD_SCENE_STRING) # should be done before loading data
	Global.game_controller.save_manager.load_data_from_file() # don't think it matters if done before or after creating the peer
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	Global.game_controller.change_scene(WORLD_SCENE_STRING)
	Global.game_controller.save_manager.remove_persistant_nodes() # should remove duplicates
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func close_server() -> void : # todo test
	if multiplayer.is_server() and multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close() # TODO to test
		multiplayer.multiplayer_peer = null

func disconnect_client() -> void:
	#TODO remove from logged players
	multiplayer.multiplayer_peer.disconnect_peer(1)

func register_player(player_name: String) -> void :
	# Create temp new player
	var new_player: Player = Global.game_controller.PLAYER.instantiate()
	Global.game_controller.current_scene.add_child(new_player)
	# Set it's name and other custom var
	new_player.player_name = player_name
	# Save it in the list in memory (not in the file, should save the world for that)
	registered_players[player_name] = new_player.save()
	# Free the new player
	new_player.queue_free()
	
func get_player(registered_player_name: String) -> Dictionary :
	return registered_players.get(registered_player_name, null)
