extends AudioStreamPlayer

func _ready() -> void:
	maintain_dev_sanity(true) # todo temp disable musics during dev
		
func maintain_dev_sanity(disable_musics: bool) -> void:
	if not disable_musics: return
	autoplay = false
	stop()
