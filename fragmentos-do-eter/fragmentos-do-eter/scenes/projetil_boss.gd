extends Area2D

@export var speed: float = 300.0
var direcao: Vector2 = Vector2.ZERO
var damage: float = 100.0

func _physics_process(delta):
	position += direcao.normalized() * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()
