extends AnimatedSprite2D
class_name PlayerAnimationHandler

var current_animation: String = "none"

# Function to update the animation
func update_animation(velocity: Vector2) -> void :
	var new_animation: String = "none"
	
	if velocity.length() > 0:
		if abs(velocity.x) > abs(velocity.y):
			new_animation = "running"
		else:
			new_animation = "running"
	else:
		new_animation = "idle"
	
	if new_animation != current_animation:
		current_animation = new_animation
		play(current_animation)
