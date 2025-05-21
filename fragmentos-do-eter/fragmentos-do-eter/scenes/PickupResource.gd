extends Resource
class_name Pickups

@export var title: String
@export var icon: Texture2D
@export_multiline var description: String
@export var sound : AudioStream
@export var horframe: int = 1
@export var scales: float = 1.0
@export var weight: float

var player_ref: CharacterBody2D


func activate():
	SoundManager.play_sfx(sound)
