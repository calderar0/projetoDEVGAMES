extends PanelContainer

@export var item: PassiveItem:
	set(value):
		item = value
		$TextureRect.texture = value.texture

func _ready() -> void:
	if item != null:
		item.player_ref = owner
