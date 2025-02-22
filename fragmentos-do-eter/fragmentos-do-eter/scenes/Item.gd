extends Resource
class_name Item

@export var title: String
@export var icon: Texture2D
@export var texture: Texture2D
@export var escala: float
@export var horframe: int
@export var verframe: int
@export var maxframe: int

var level = 1

func upgrade_item():
	pass
