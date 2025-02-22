extends Area2D

var direcao: Vector2 = Vector2.RIGHT 
var speed: float = 200
var damage: float = 1
var knockback: float = 90
var source

var frame_counter: int = 0
var frame = 0


func _physics_process(delta: float) -> void:
	frame_counter += 1
	if frame_counter >= $Sprite2D.hframes:
		frame_counter = 0
		frame = (frame + 1) % $Sprite2D.hframes
		$Sprite2D.frame = frame  # Atualiza o frame do Sprite2D
	position += direcao*speed*delta


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		if "might" in source:
			body.take_damage(damage * source.might)
		else:
			body.take_damage(damage)
		body.knockback = direcao*knockback

		

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area) -> void:
	if area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)
