extends Node
class_name NetworkManager

const IP_ADDRESS: String = "localhost"
const PORT: int = 42069
var peer: ENetMultiplayerPeer
var multiplayer_spawner : MultiplayerSpawnerOfPlayer

var registered_players: Dictionary = {}
var logged_players: Array[Player] = []

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected) # Emitted to every peers
	multiplayer.peer_disconnected.connect(_on_peer_disconnected) # Emitted to every peers

func serialize_logged_players() -> Array[Dictionary]:
	var logged_data: Array[Dictionary] = []
	for player: Player in logged_players:
		logged_data.append(player.save())
	return logged_data

# Will be called for everyone at least once
func _on_peer_connected(peer_id: int) -> void:
	print("Client connected: ", peer_id, " called by ", get_role_and_id())
	
	# Send all known character form the server to the clients
	if multiplayer.is_server() :
		print("im the server " + get_role_and_id())
		rpc_id(peer_id, "_sync_players_lists_from_server", registered_players, serialize_logged_players())
	
	# Update interface for everyone
	var world_scene: World = Global.game_controller.current_scene
	world_scene.player_selection.draw_character_slots() # Used character should not be available
	world_scene.player_selection.update_connected_players_label()

	
@rpc("any_peer")
func _sync_players_lists_from_server(server_registered: Dictionary, server_logged_data: Array[Dictionary]) -> void:
	if multiplayer.is_server() : return
	print("Syncing data from server for " + get_role_and_id())
	# Merge server_registered into local registered_players
	for player_name: String in server_registered.keys():
		registered_players[player_name] = server_registered[player_name]
	
	
	#logged_players.clear() # the server always known all logged players
	#for player_data: Dictionary in server_logged_data:
	#	var new_player: Player = Global.game_controller.PLAYER.instantiate()
	#	new_player.load_from_save(player_data)
	#	logged_players.append(new_player)

	if Global.game_controller.current_scene is World:
		var world_scene: World = Global.game_controller.current_scene
		world_scene.player_selection.draw_character_slots()
		world_scene.player_selection.update_connected_players_label()


# Will be called for everyone at least once
func _on_peer_disconnected(peer_id: int) -> void:
	print("Client disconnected: ", peer_id)
	# TODO: update logged_players and broadcast to others

func print_player_lists() -> void:
	print("Registered Players names: ", registered_players.keys())
	print("Logged Players: ")
	for player: Player in logged_players:
		print(player) 

func get_role_and_id() -> String:
	var role : String = "Server" if multiplayer.is_server() else "Client"
	return "%s %d" % [role, multiplayer.get_unique_id()]

		

func start_server() -> void:
	# TODO test if a server already exists
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	Global.game_controller.save_manager.load_data_from_file()

func start_client() -> void:
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
