extends Area2D

var direction: Vector2
var speed: float = 200

var frame_counter = 0
var frame = 0

@export var type: Pickups:
	set(value):
		type = value
		$Sprite2D.hframes = value.horframe
		$Sprite2D.texture = value.icon
		$Sprite2D.scale.x = value.scales
		$Sprite2D.scale.y = value.scales
@export var player_ref: CharacterBody2D:
	set(value):
		player_ref = value
		type.player_ref = value

var can_follow: bool = false

#func _ready() -> void:
	#$Sprite2D.texture = type.icon

func _physics_process(delta: float) -> void:
	frame_counter +=1
	if frame_counter >= type.horframe:
		frame_counter=0
		frame = (frame + 1) % type.horframe
		$Sprite2D.frame = frame  # Atualiza o frame do Sprite2D
	if player_ref and can_follow:
		direction = (player_ref.position - position).normalized()
		position += direction * speed * delta

func follow(_target: CharacterBody2D, gem_flag= false):
	if type is Chest:
		return
	if gem_flag == true:
		if type is Chi:
			can_follow = true
		return
	can_follow = true

func _on_body_entered(_body: Node2D) -> void:
	type.activate()
	queue_free()
