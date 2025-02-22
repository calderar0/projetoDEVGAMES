extends Node2D

@onready var sfx_player: AudioStreamPlayer

func play_sfx(sfx: AudioStream):
	if sfx:
		sfx_player = AudioStreamPlayer.new()
		add_child(sfx_player)
		
		sfx_player.stream = sfx
		sfx_player.bus = "SFX"
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
