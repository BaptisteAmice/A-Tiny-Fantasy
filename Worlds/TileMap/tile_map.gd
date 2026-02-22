extends Node2D
class_name WorldTileMap

@onready var world: World = $".."
@onready var ground: TileMapLayer = $Ground
@onready var carpet: TileMapLayer = $Carpet
@onready var walls: TileMapLayer = $Walls
@onready var interactable_layer: Node2D = $InteractableLayer

func _ready() -> void:
	Global.game_controller.mouse_controller.tilemap = self

###### ALL TILEMAPS

func get_tilemap_dict(tilemap: TileMapLayer) -> Dictionary:
	var data: Dictionary = {}
	var used_cells: Array[Vector2i] = tilemap.get_used_cells()
	
	for cell: Vector2i in used_cells:
		var cell_id: String = str(cell.x) + "_" + str(cell.y)
		data[cell_id] = {
			"x": cell.x,
			"y": cell.y,
			"cell_type": BetterTerrain.get_cell(tilemap, cell)
		}
	
	return data

func load_tilemap_from_dict(tilemap: TileMapLayer, data: Dictionary) -> void:
	# Add or update cells from data
	for cell_id: String in data:
		var cell_data: Dictionary = data[cell_id]
		var cell_pos: Vector2i = Vector2i(cell_data["x"], cell_data["y"])
		var cell_type: int = cell_data["cell_type"]
		place_cells_on_layer(tilemap, [cell_pos], cell_type)

	# Remove any cells that are not in the data
	var used_cells: Array[Vector2i] = tilemap.get_used_cells()
	for cell: Vector2i in used_cells:
		var cell_id: String = str(cell.x) + "_" + str(cell.y)
		if not data.has(cell_id):
			BetterTerrain.set_cell(tilemap, cell, Constants.TERRAINS.Decoration) # remove cell

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
	#todo also update ennemies and chest

# Client receives full map
@rpc("any_peer")
func _client_receive_full_map(data: Dictionary) -> void:
	if multiplayer.is_server():
		return # server doesn't need to receive it
	load_tilemap_from_dict(walls, data)

####### Placing and removing tiles

func get_clicked_wall_cell() -> Vector2i:
	var virtual_mouse_position: Vector2 = Global.game_controller.mouse_controller.virtual_mouse_position
	var clicked_cell: Vector2i = walls.local_to_map(walls.to_local(virtual_mouse_position))
	return clicked_cell

func place_wall_at_mouse(cell_id: int) -> void:
	if not walls:
		push_warning("No tilemaplayer available to place a wall") #todo see if normal
		return
	var cell_pos: Vector2i = get_clicked_wall_cell()
	place_cells_on_layer(walls, [cell_pos], cell_id)
	
func place_cells_on_layer(layer: TileMapLayer, cells: Array[Vector2i], cell_type: int) -> void:
	if multiplayer.is_server():
		_server_place_cells_on_layer(layer.get_path(), cells, cell_type)
	else:
		# send request to server (server id is usually 1)
		rpc_id(1, "_server_place_cells_on_layer", layer.get_path(), cells, cell_type)
	
func remove_wall_at_mouse() -> void:
	if not walls:
		push_warning("No tilemaplayer available to remove a wall")
		return
	var cell_pos: Vector2i = get_clicked_wall_cell()
	var removed_cell_type: int = BetterTerrain.get_cell(walls, cell_pos)
	place_cells_on_layer(walls, [cell_pos], Constants.TERRAINS.Decoration) # todo dunno if Decoration is the right id for empty
	# drop tile item at cell position
	var global_cell_pos: Vector2 = walls.map_to_local(cell_pos)
	spawn_terrain_drop(removed_cell_type, global_cell_pos)
	
	

func locally_place_cell(layer: TileMapLayer, cells: Array[Vector2i], cell_type: int) -> void:
	for cell_pos: Vector2i in cells:
		BetterTerrain.set_cell(layer, cell_pos, cell_type)
	# Update the terrain area
	if cells.size() > 0:
		var min_x: int = cells[0].x
		var min_y: int = cells[0].y
		var max_x: int = cells[0].x
		var max_y: int = cells[0].y
		for cell_pos: Vector2i in cells:
			min_x = min(min_x, cell_pos.x)
			min_y = min(min_y, cell_pos.y)
			max_x = max(max_x, cell_pos.x)
			max_y = max(max_y, cell_pos.y)
		var update_rect: Rect2i = Rect2i(Vector2i(min_x, min_y), Vector2i(max_x - min_x + 1, max_y - min_y + 1))
		BetterTerrain.update_terrain_area(layer, update_rect, true)

func spawn_terrain_drop(spawned_terrain_type: int, spawn_position: Vector2) -> void:
	if Constants.TERRAINS_DROPS.has(spawned_terrain_type):
		var dropped_slot_data: SlotData = SlotData.new()
		dropped_slot_data.quantity = 1
		var item_data: ItemData = Constants.TERRAINS_DROPS[spawned_terrain_type]
		dropped_slot_data.item_data = item_data

		world.drop_slot_data_at_position(dropped_slot_data, spawn_position, null)

# -------------------------
# Server functions
# -------------------------
@rpc("any_peer")
func _server_place_cells_on_layer(layer_path: String, cells: Array[Vector2i], cell_type: int) -> void:	
	if not multiplayer.is_server():
		push_error("Server only action called by client")
		return

	if cells.size() < 1:
		return

	var layer: TileMapLayer = get_node_or_null(layer_path)
	if layer == null:
		push_error("Invalid layer path sent to server: " + layer_path)
		return

	# Place cells on server
	locally_place_cell(layer, cells, cell_type)
	
	# broadcast to all clients
	rpc("_client_update_layer_cells", layer.get_path(), cells, cell_type)

# -------------------------
# Client updates from server
# -------------------------
@rpc("any_peer")
func _client_update_layer_cells(layer_path: String, cells: Array[Vector2i], cell_type: int) -> void:
	if multiplayer.is_server(): return
	var layer: TileMapLayer = get_node_or_null(layer_path)
	if layer == null:
		push_error("Invalid layer path sent to client: " + layer_path)
		return
	locally_place_cell(layer, cells, cell_type)
