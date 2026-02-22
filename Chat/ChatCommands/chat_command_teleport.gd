extends ChatCommand
class_name ChatCommandTeleport

var COMMAND_NAME_IN_CHAT : String = "tp"
const COMMAND_TELEPORT = preload("uid://cqt83qc7j8if8")


func _init() -> void:
	super(COMMAND_NAME_IN_CHAT)

func prepare_command(params: Array[String]) -> String:
	if params == null || params.size() < 1:
		return "Deux paramètres sont attendus"
	if !params[0].is_valid_float():
		return "Le premier paramètre doit être un nombre (la position X)"
	if !params[1].is_valid_float():
		return "Le deuxième paramètre doit être un nombre (la position Y)"	
	self.instantiated_command = COMMAND_TELEPORT.new(
		PlayerManager.my_player,
		Vector2(float(params[0]), float(params[1]))
	)
	return ""
