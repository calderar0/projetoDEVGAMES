extends PanelContainer

@export var item: PassiveItem:
	set(value):
		item = value
		$TextureRect.texture = value.texture
		item.passiveslot =  self

@export var player_refe: CharacterBody2D

func _ready() -> void:
	if item != null:
		item.player_ref = player_refe  # Atribua o player_ref ao item
		
