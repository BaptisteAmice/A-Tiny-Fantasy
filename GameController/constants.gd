extends Node

enum TERRAIN_SETS {
	WALLS = 0, 
}

enum TERRAINS {
	DIRT_WALLS = 0,
	PIPES = 1,
}

const LANGUAGES : Dictionary = {
	EN = "en",
	FR = "fr"
}

const SAVE_FILE_PATH: String = "user://save_data.json"
const TEMP_RESOURCE_SAVE_FILE_PATH: String = "user://temp_save.tres"
const CLIENT_CONFIG_SAVE_FILE_PATH: String = "user://client_config.tres"
