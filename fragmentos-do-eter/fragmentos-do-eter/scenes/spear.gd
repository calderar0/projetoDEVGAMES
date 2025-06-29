extends Weapon
class_name Spear

const SPAWN_DISTANCE = 100
const ATTACK_DURATION = 0.5
const CONE_ANGLE = deg_to_rad(70)
const MAX_DISTANCE = 150

var linha_desejada = 5  # Linha do spritesheet que você quer usar
var current_projectile: Area2D = null
var frame_time = 0.0
var current_frame = 0
@export var animation_speed = 1
@export var frame_count = 9

func activate(source, target, scene_tree):
	reset()
	add_to_player(source)

func add_to_player(source):
	var projectile = projeto_node.instantiate()
	projectile.speed = 0
	projectile.damage = damage
	projectile.source = source
	
	# Configurar o Sprite
	var sprite = projectile.find_child("Sprite2D")
	if sprite:
		sprite.texture = texture
		sprite.scale = Vector2(escala, escala)
		sprite.hframes = horframe
		sprite.vframes = verframe

	
	current_projectile = projectile
	source.call_deferred("add_child", projectile)
	
	# Configura a posição inicial
	projectile.position = Vector2.ZERO
	# Aplica dano na área
	deal_damage(source)
	
	# Timer para remover a lança
	await source.get_tree().create_timer(ATTACK_DURATION).timeout
	reset()

func deal_damage(source):
	if not current_projectile:
		return
	var mouse_pos = source.get_global_mouse_position()
	var attack_direction = (mouse_pos - source.global_position).normalized()
	for body in source.get_tree().current_scene.get_children():
		if body.has_method("take_damage") and body != source:
			var to_target = (body.global_position - source.global_position).normalized()
			var angle = abs(attack_direction.angle_to(to_target))
			var distance = source.global_position.distance_to(body.global_position)
			if angle <= CONE_ANGLE and distance <= MAX_DISTANCE:
				body.take_damage(damage)

func update(delta):
	if current_projectile and current_projectile.source:
		var source = current_projectile.source
		var mouse_pos = source.get_global_mouse_position()
		var sprite = current_projectile.find_child("Sprite2D")
		
		if sprite:
			# Atualiza a animação
			var relative_mouse = mouse_pos - source.global_position
			current_projectile.rotation = relative_mouse.angle()
			var angle = relative_mouse.angle()
			sprite.flip_h = true
			if angle > -PI/2 and angle < PI/2:
				sprite.flip_v = false
			else:
				sprite.flip_v = true
				
			# Corrigindo a lógica de frames
			frame_time += delta
			if frame_time >= (1.0 / animation_speed):
				frame_time = 0.0
				current_frame = current_frame + 1
				sprite.frame = current_frame

func reset():
	if current_projectile:
		current_projectile.queue_free()
		current_projectile = null
	frame_time = 0
	current_frame = 0

func upgrade_item():
	if max_level_reached():
		slot.item = evolution
		return
		
	if not is_upgradable():
		return
	
	var upgrade = upgrades[level - 1]
	damage += upgrade.damage
	cooldown += upgrade.cooldown
	level += 1
