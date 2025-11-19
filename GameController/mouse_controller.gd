extends Node2D
class_name MouseController

@onready var virtual_cursor: Sprite2D = $VirtualCursor
var virtual_mouse_position: Vector2 : set = _set_virtual_mouse_position
@onready var game_controller: GameController = $".."


func _set_virtual_mouse_position(value: Vector2) -> void:
	virtual_mouse_position = value
	virtual_cursor.global_position = value

# follow the mouse when it moves in the window
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		virtual_mouse_position = get_global_mouse_position()

# can be moved by other means
func slide_virtual_mouse_to_position(target_position: Vector2, duration: float) -> void:
	virtual_mouse_position = target_position

func _process(_delta: float) -> void:
	get_input_aside_from_real_mouse()


func get_input_aside_from_real_mouse() -> void:
	# Does nothing if playing normally
	if Global.game_controller.input_caller_controller == null: return
	# Does nothing if the player isn't set
	if PlayerManager.my_player == null: return
	
	var mouse_move_distance: float = 16.0
	var border_offset: float = 32.0

	# Move cursor based on actions
	if Input.is_action_just_pressed("mouse_move_left"):
		virtual_mouse_position.x -= mouse_move_distance
	if Input.is_action_just_pressed("mouse_move_right"):
		virtual_mouse_position.x += mouse_move_distance
	if Input.is_action_just_pressed("mouse_move_up"):
		virtual_mouse_position.y -= mouse_move_distance
	if Input.is_action_just_pressed("mouse_move_down"):
		virtual_mouse_position.y += mouse_move_distance

	# Get camera view rect in world coordinates
	var cam : Camera2D = PlayerManager.my_player.camera_2d # needs the check on player
	# Convert viewport size to float space before dividing by zoom
	var viewport_size: Vector2 = Vector2(get_viewport().size)
	var view_size: Vector2 = viewport_size / cam.zoom
	var half_view: Vector2 = view_size * 0.5


	var min_x: float = cam.global_position.x - half_view.x + border_offset
	var max_x: float = cam.global_position.x + half_view.x - border_offset
	var min_y: float = cam.global_position.y - half_view.y + border_offset
	var max_y: float = cam.global_position.y + half_view.y - border_offset

	# Clamp cursor inside camera view
	virtual_mouse_position.x = clamp(virtual_mouse_position.x, min_x, max_x)
	virtual_mouse_position.y = clamp(virtual_mouse_position.y, min_y, max_y)
