extends Node2D
class_name MouseController

#todo la grid ne s'update pas au bon moment, il faudrait l'update en mm temps que Global.game_controller.build_mod 

@onready var virtual_cursor: Sprite2D = $VirtualCursor
var virtual_mouse_position: Vector2 : set = _set_virtual_mouse_position
@onready var game_controller: GameController = $".."

var tilemap: Node2D = null;
var previous_top_layer: TileMapLayer = null
	
func _set_virtual_mouse_position(value: Vector2) -> void:
	virtual_mouse_position = value
	virtual_cursor.global_position = value
	update_grid(value)


func get_top_tilemap_layer_at_position(value: Vector2) -> TileMapLayer:
	# todo le classement des layers ne devrait etre fait qu'une fois
	# Récupère tous les TileMapLayer enfants
	var layers: Array = []
	for child: Node in tilemap.get_children():
		if child is TileMapLayer:
			layers.append(child)

	# Trier par z_index décroissant (le plus haut visuellement d'abord)
	layers.sort_custom(func(a: TileMapLayer, b: TileMapLayer) -> bool : 
		return a.z_index > b.z_index
	)
	#todo ################### fin classement à fair eune seule fois

	# Tester chaque layer
	for layer: TileMapLayer in layers:
		var local_pos: Vector2 = layer.to_local(value)
		var cell: Vector2i = layer.local_to_map(local_pos)

		# Vérifie si une tile existe
		if layer.get_cell_source_id(cell) != -1:
			return layer
	return null


func need_grid_to_build() -> bool:
	return Global.game_controller.build_mod == Constants.BUILD_MODS.PLACE \
		or Global.game_controller.build_mod == Constants.BUILD_MODS.DESTROY
	

func update_grid(value: Vector2) -> void:
	# On attend d'avoir une référence au tilemap avant d'essayer de faire quoi que ce soit
	if not tilemap: return
	
	var should_diplay_grid: bool = need_grid_to_build()

	# récupère le layer de tilemap le plus haut sous la souris
	var top_layer: TileMapLayer = get_top_tilemap_layer_at_position(value)

	#todo une méthode
	# Si le la layer sous la souris a changé depuis la dernière mise à jour, on met à jour le shader du layer
	if top_layer != previous_top_layer:
		# On désactive le shader de l'ancien layer
		if previous_top_layer and previous_top_layer.material:
			(previous_top_layer.material as ShaderMaterial).set_shader_parameter("enabled", false)
		# On active le shader du nouveau layer
		if should_diplay_grid && top_layer and top_layer.material:
			(top_layer.material as ShaderMaterial).set_shader_parameter("enabled", true)
		previous_top_layer = top_layer

	#todo une méthode
	# met à jour la position de la grille dans le shader du layer
	if should_diplay_grid && top_layer and top_layer != null && top_layer.material:
		# show the material
		(top_layer.material as ShaderMaterial).set_shader_parameter(
			"mouse_position",
			top_layer.to_local(value)
		)


# follow the mouse when it moves in the window
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		virtual_mouse_position = get_global_mouse_position()

# can be moved by other means
func slide_virtual_mouse_to_position(target_position: Vector2, _duration: float) -> void:
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
