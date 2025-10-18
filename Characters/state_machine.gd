extends Node
class_name StateMachine

@export var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	if not multiplayer.is_server(): return
	for child: Node in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			(child as State).transitioned.connect(on_child_transition)
	if current_state:
		current_state.enter()
			
func _process(delta: float) -> void :
	if not multiplayer.is_server(): return
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void :
	if not multiplayer.is_server(): return
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state: State, new_state_name: String) -> void:
	if not multiplayer.is_server(): return
	if state != current_state:
		return
	var new_state: State = states.get(new_state_name.to_lower())
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state
	
