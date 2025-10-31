extends CharacterBody2D
class_name Player

@onready var name_label: Label = $NameLabel
@onready var player_animation_handler: PlayerAnimationHandler = $PlayerAnimationHandler
@export var speed: int = 200
@onready var all_interactions: Array[InteractableArea] = []
@onready var interact_area: Area2D = $InteractArea
@onready var interact_label: Label = $InteractLabel
@export var player_name: String = "Default" # Displayed player name

var max_health: int = 10
var health: int = 10

#todo test inventory saving in multiplayer, add saving
@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryData

signal toggle_inventory()

func _enter_tree() -> void : set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if !is_multiplayer_authority(): return
	var player_camera: Camera2D = $Camera2D
	player_camera.enabled = true # Personal camera, not shared


func get_input() -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
		
	if Input.is_action_just_pressed("interact"):
		execute_interaction()
	
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	
	
func execute_interaction() -> void:
	if all_interactions and all_interactions.size() > 0:
		var current_interaction: InteractableArea = all_interactions[0]
		current_interaction.player_interact()

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
		
func get_drop_position() -> Vector2:
	return global_position

func save() -> Dictionary:
	print("save", position.x,)
	var save_dict: Dictionary = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"name": name, # id for saving and loading player data
		"player_name" : player_name,
		#todo
		#"inventory_data" : inventory_data.save(),
	}
	return save_dict
	
@rpc("any_peer")
func load(saved_state: Dictionary) -> void:
	if saved_state:
		if typeof(saved_state.pos_x) != TYPE_FLOAT or typeof(saved_state.pos_y) != TYPE_FLOAT:
			push_error("Saved coordinates should be floats: ",  saved_state.pos_x, saved_state.pos_y)
		var coord_x: float = saved_state.pos_x
		var coord_y: float = saved_state.pos_y
		position = Vector2(coord_x, coord_y)
		player_name = saved_state.player_name
		name_label.text = player_name
		#todo
		#inventory_data.load(saved_state.inventory_data)

		Global.get_world_scene().setup_local_player(self)


func _on_interact_area_area_entered(area: Area2D) -> void:
	all_interactions.insert(0, area)
	update_interactions()


func _on_interact_area_area_exited(area: Area2D) -> void:
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions() -> void:
	if all_interactions and all_interactions.size() > 0:
		interact_label.text = all_interactions[0].interact_text
	else:
		interact_label.text = ""

func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	
