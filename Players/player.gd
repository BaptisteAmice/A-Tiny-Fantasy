extends CharacterBody2D
class_name Player

@onready var player_animation_handler: PlayerAnimationHandler = $PlayerAnimationHandler
@export var speed: int = 200
@onready var all_interactions: Array = []
var player_name: String = "Default" # Displayed player name

func _enter_tree() -> void : set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if !is_multiplayer_authority(): return
	var player_camera: Camera2D = $Camera2D
	player_camera.enabled = true # Personal camera, not shared
	


func get_input() -> void:
	#if Input.is_action_just_pressed("inventory"):
	#	toggle_inventory.emit()
		
#	if Input.is_action_just_pressed("interact"):
#		execute_interaction()
	
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
#func execute_interaction():
#	if all_interactions:
#		var current_interaction = all_interactions[0]
#		current_interaction.player_interact()

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	get_input()
	# Flip left or right
	if velocity.x != 0:
		player_animation_handler.flip_h = velocity.x < 0
	player_animation_handler.update_animation(velocity)

	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
	
	# Print if collision is detected with collision layer of tilemap
	if is_on_wall():
		print("Collision detected")

# Interaction methods


func save() -> Dictionary: #TODO coordinates aren't saved as expected but to 0,0
	var save_dict: Dictionary = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"name": name, # id for saving and loading player data
		"player_name" : player_name,
	}
	return save_dict
	
func load(saved_state: Variant) -> void:
	if saved_state:
		position = Vector2(saved_state.pos_x, saved_state.pos_y)
		player_name = saved_state.player_name
