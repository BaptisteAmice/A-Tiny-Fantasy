extends Node

### PACKED SCENES
const PLAYER: PackedScene = preload("uid://d08gn81f5b74p")

### TERRAINS
enum TERRAINS {
	Decoration = -1,
	WALLS_DIRT = 0,
	PIPES = 1,
	WALLS = 2,
}

var TERRAINS_DROPS: Dictionary[int,Resource] = {
	TERRAINS.WALLS_DIRT: preload("uid://70t0lt7uyqlc"),
}

enum BUILD_MODS {
	DISABLED = 0,
	PLACE = 1,
	DESTROY = 2
}

### ITEMS

enum ITEM_TAG {
	ANY = 0,
	FUEL = 1,
}

enum PRIORITY {
	BLOCKED = 0,
	VERY_LOW = 1,
	LOW = 2,
	NORMAL = 3,
	HIGH = 4,
	VERY_HIGH = 5
}

### CLIENT CONFIGURATION
const LANGUAGES : Dictionary = {
	EN = "en",
	FR = "fr"
}

# FILE PATHS
const SAVE_FILE_PATH: String = "user://save_data.json"
const TEMP_RESOURCE_SAVE_FILE_PATH: String = "user://temp_save.tres"
const CLIENT_CONFIG_SAVE_FILE_PATH: String = "user://client_config.tres"
