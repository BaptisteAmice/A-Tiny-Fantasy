extends State
class_name CharacterFollow

@export var character: Character
@export var move_speed: float = 10.0

@export var distance_min_to_follow : int
@export var distance_max_to_follow: int
@export var distance_max_emote: String

func enter() -> void:
	pass
	
		
func physics_update(_delta: float) -> void:
	if not multiplayer.is_server(): return
	var direction: Vector2 = character.target.global_position - character.global_position
	
	if direction.length() > distance_min_to_follow:
		character.velocity = direction.normalized() * move_speed
	else:
		character.velocity = Vector2()
		
	if direction.length() > distance_max_to_follow \
	or direction.length() < distance_min_to_follow:
		# play an emote
		if character.animated_emote and distance_max_emote:
			character.animated_emote.play_emote(distance_max_emote)
		#change state
		transitioned.emit(self,"CharacterIdle")
