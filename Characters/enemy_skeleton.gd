extends Character
class_name SkeletonEnemy

func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server(): return
	move_and_slide()
	
	target_player() # TODO do it less if it take too much resources
	
	if velocity.length() > 0:
		animated_sprite_2d.play("running")
	else:
		animated_sprite_2d.play("idle")
		
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true
		
func save() -> Dictionary:
	print("save", position.x,)
	var save_dict: Dictionary = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
	}
	return save_dict
