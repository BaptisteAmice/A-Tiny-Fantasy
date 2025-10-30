extends State
class_name CharacterIdle

@export var character: Character
@export var move_speed: float = 10.0

var move_direction: Vector2
var wander_time: float

@export var distance_min_to_notice : int
@export var distance_max_to_notice: int
@export var target_noticed_action: String


func randomize_wander() -> void:
	if not multiplayer.is_server(): return
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1,3)
	
func enter() -> void:
	if not multiplayer.is_server(): return
	randomize_wander()
	
func update(delta: float) -> void:
	if not multiplayer.is_server(): return
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
		
func physics_update(_delta: float) -> void:
	if not multiplayer.is_server(): return
	if character:
		character.velocity = move_direction * move_speed
		
		if character.target and target_noticed_action:
			var direction: Vector2 = character.target.global_position - character.global_position
			if direction.length() < distance_max_to_notice \
					and direction.length() > distance_min_to_notice:
				# play the exclamation emote
				if character.animated_emote:
					character.animated_emote.play_emote("exclamation")
				# transition to the new state
				transitioned.emit(self, target_noticed_action)
			
