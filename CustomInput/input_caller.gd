extends Node
class_name InputCaller

@export var action_name: String

# Warning: some action need a minimal press time to be registered properly
func trigger_press(release_delay: float) -> void:
	var ev: InputEventAction = InputEventAction.new()
	ev.action = action_name
	ev.pressed = true
	Input.parse_input_event(ev)

	# Release after delay
	await Global.get_tree().create_timer(release_delay).timeout

	
	var ev_release: InputEventAction = InputEventAction.new()
	ev_release.action = action_name
	ev_release.pressed = false
	Input.parse_input_event(ev_release)
