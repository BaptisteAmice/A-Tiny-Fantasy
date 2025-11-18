extends Node
class_name GameController

@onready var mouse_controller: MouseController = $MouseController


var current_scene: Node
var removed_scenes: Dictionary = {}

@onready var save_manager: SaveManager = $SaveManager
@onready var network_manager: NetworkManager = $NetworkManager

@onready var music_audio_stream_player: AudioStreamPlayer = $MusicAudioStreamPlayer
@onready var audio_manager: AudioManager = $AudioManager

@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

var client_config: ClientConfig

func _ready() -> void:
	# Singleton
	Global.game_controller = self
	
	# Load client config
	client_config = save_manager.load_ressource_at_path(Constants.CLIENT_CONFIG_SAVE_FILE_PATH, ClientConfig)
	
	# Connect signals
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	# Set main menu
	change_scene("res://Menus/main_menu.tscn", false)

func change_scene(new_scene: String, play_animation: bool = true) -> void:
	if not current_scene == null:
		current_scene.queue_free() # remove node entirely
		
	var new_scene_instance: Node = null
	if removed_scenes.has(new_scene):
		new_scene_instance = removed_scenes[new_scene]
		removed_scenes.erase(new_scene)
		print_debug("Reusing scene")
	else:
		var scene_res: PackedScene = load(new_scene)
		new_scene_instance = scene_res.instantiate()
		print_debug("not Reusing scene")
	self.add_child(new_scene_instance)
	current_scene = new_scene_instance
	
	if play_animation:
		play_transition_animation()
		
func play_transition_animation() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	color_rect.show()
	animation_player.play("fade_in_out")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in_out":
		color_rect.hide()
