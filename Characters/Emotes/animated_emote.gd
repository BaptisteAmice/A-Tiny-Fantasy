extends AnimatedSprite2D
class_name AnimatedEmote

var _remaining_loops: int = 0

func _ready() -> void:
	visible = false
	connect("animation_finished", Callable(self, "_on_animation_finished"))

func play_emote(emote_name: String, loop_number: int = 2) -> void:
	if loop_number <= 0:
		return
	animation = emote_name
	visible = true
	_remaining_loops = loop_number
	play()

func _on_animation_finished() -> void:
	_remaining_loops -= 1
	if _remaining_loops > 0:
		play() # Play again
	else:
		visible = false
		print("Animation finished")
