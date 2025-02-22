extends Resource
class_name Enemy

@export var title: String
@export var texture: Texture2D
@export var hframe: int = 1
@export var vframe: int = 1
@export var scalesx: float = 1.0
@export var scalesy: float = 1.0
@export var flip: bool = false
@export var velxd: int = 0
@export var velxe: int = 0
@export var health: float
@export var damage: float
@export var drops: Array[Pickups]
@export var coll_rad: int = 10
@export var coll_height: int = 20
@export_multiline var about: String
@export var icon: Texture2D
