extends TileMapLayer

@onready var world_tile_map: WorldTileMap = $".."

func save() -> Dictionary:
	var save_dict: Dictionary = {
		"persist_lite_path": self.get_path(),
		"tiles": world_tile_map.get_tilemap_dict(self),
	}
	return save_dict
	
@rpc("any_peer")
func load(saved_state: Dictionary) -> void:
	if saved_state:
		if not saved_state.tiles or typeof(saved_state.tiles) != TYPE_DICTIONARY:
			push_error("Saved tiles should be a dictionary ",  saved_state.tiles)
		else:
			var saved_tiles_dict: Dictionary = saved_state.tiles 
			world_tile_map.load_tilemap_from_dict(self, saved_tiles_dict)
