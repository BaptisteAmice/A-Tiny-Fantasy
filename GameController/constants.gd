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
const CLIENT_CONFIG_SAVE_FILE_PATH: String = "user://client_config.tres"
