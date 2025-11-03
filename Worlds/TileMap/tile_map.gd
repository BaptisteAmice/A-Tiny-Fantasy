extends Node2D
class_name WorldTileMap

@onready var ground: TileMapLayer = $Ground
@onready var walls: TileMapLayer = $Walls
@onready var interactable_layer: Node2D = $InteractableLayer

###### ALL TILEMAPS

func get_tilemap_dict(tilemap: TileMapLayer) -> Dictionary:
	var data: Dictionary = {}
	var used_cells: Array[Vector2i] = tilemap.get_used_cells()
	
	for cell: Vector2i in used_cells:
		var cell_id: String = str(cell.x) + "_" + str(cell.y) 
		
		var tile_data: TileData =  tilemap.get_cell_tile_data(cell)
		
		data[cell_id] = {
			"x": cell.x,
			"y": cell.y,
			"terrain_set": tile_data.terrain_set,
			"terrain": tile_data.terrain
		}
	
	return data

func load_tilemap_from_dict(tilemap: TileMapLayer, data: Dictionary) -> void:	
	# Add or update tiles
	for cell_id: String in data:
		var cell_data: Dictionary = data[cell_id]
		var cell_pos: Vector2i = Vector2i(cell_data["x"], cell_data["y"])
		var terrain_set: int = cell_data["terrain_set"]
		var terrain: int = cell_data["terrain"]
		place_wall_at_cell_pos(cell_pos, terrain_set, terrain)

# -------------------------
# Full tilemap sync
# -------------------------

# Client requests full map from server
func request_full_map() -> void:
	if multiplayer.is_server():
		# If server calls it locally, does nothing
		return
	else:
		rpc_id(1, "_server_send_full_map_request", multiplayer.get_unique_id())

# Server receives request from client
@rpc("any_peer")
func _server_send_full_map_request(client_id: int) -> void:
	if not multiplayer.is_server():
		push_error("Server only action called by client")
		return
	_send_full_map_to_client(client_id)

# Server sends the full map to a client
func _send_full_map_to_client(client_id: int) -> void:
	var wall_data: Dictionary = get_tilemap_dict(walls)
	# could also include ground, interactable layers etc.
	rpc_id(client_id, "_client_receive_full_map", wall_data)

# Client receives full map
@rpc("any_peer")
func _client_receive_full_map(data: Dictionary) -> void:
	if multiplayer.is_server():
		return # server doesn't need to receive it
	load_tilemap_from_dict(walls, data)

####### WALLS

const ERASE_CELL_ID: int = -1
#todo place ground, walls, interacables, make multiplayer and saves work

func get_clicked_wall_cell() -> Vector2i:
	var clicked_cell: Vector2i = walls.local_to_map(walls.get_local_mouse_position())
	return clicked_cell
	
func place_wall_at_mouse(terrain_set: int, terrain: int) -> void:
	if not walls:
		push_warning("No tilemaplayer available to place a wall") #todo see if normal
		return
	var cell_pos: Vector2i = get_clicked_wall_cell()
	place_wall_at_cell_pos(cell_pos, terrain_set, terrain)
	
func place_wall_at_cell_pos(cell_pos: Vector2i, terrain_set: int, terrain: int) -> void:
	if multiplayer.is_server():
		_server_place_wall(cell_pos, terrain_set, terrain)
	else:
		# send request to server (server id is usually 1)
		rpc_id(1, "_server_place_wall", cell_pos, terrain_set, terrain)
	
func remove_wall_at_mouse() -> void:
	if not walls:
		push_warning("No tilemaplayer available to remove a wall")
		return
	var cell_pos: Vector2i = get_clicked_wall_cell()
	remove_wall_cell_pos(cell_pos) 
	
func remove_wall_cell_pos(cell_pos: Vector2i) -> void:
	if multiplayer.is_server():
		_server_remove_wall(cell_pos)
	else:
		rpc_id(1, "_server_remove_wall", cell_pos)
		
# -------------------------
# Server functions
# -------------------------
@rpc("any_peer")
func _server_place_wall(cell_pos: Vector2i, terrain_set: int, terrain: int) -> void:	
	if not multiplayer.is_server():
		push_error("Server only action called by client")
		return
	walls.set_cells_terrain_connect([cell_pos], terrain_set, terrain)
	
	# broadcast to all clients
	rpc("_client_update_wall", cell_pos, terrain_set, terrain)

@rpc("any_peer")
func _server_remove_wall(cell_pos: Vector2i) -> void:
	# default atlas coord (only given for rpc call)
	var atlas_coord: Vector2i = Vector2i(-1,-1)
	if not multiplayer.is_server():
		push_error("Server only action called by client")
		return
	walls.set_cell(cell_pos, ERASE_CELL_ID, atlas_coord)
	rpc("_client_update_wall", cell_pos, ERASE_CELL_ID, atlas_coord)

# -------------------------
# Client updates from server
# -------------------------
@rpc("any_peer")
func _client_update_wall(cell_pos: Vector2i, terrain_set: int, terrain: int) -> void:
	if multiplayer.is_server(): return
	walls.set_cells_terrain_connect([cell_pos], terrain_set, terrain)
