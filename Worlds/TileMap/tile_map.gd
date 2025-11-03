extends Node2D
class_name WorldTileMap

enum TERRAIN_SETS {
	WALLS = 0, 
}

enum TERRAINS {
	DIRT_WALLS = 0,
}

@onready var ground: TileMapLayer = $Ground
@onready var walls: TileMapLayer = $Walls
@onready var interactable_layer: Node2D = $InteractableLayer

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
