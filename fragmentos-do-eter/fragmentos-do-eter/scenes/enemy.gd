extends CharacterBody2D

@export var player_ref: CharacterBody2D
@export var boss_enemy: Enemy
var damage_popup_node = preload("res://scenes/damage.tscn")

var direction: Vector2
var speed : float = 75.0
var damage: float
#var health: float
var knockback: Vector2
var separacao: float

var frame_counter = 0
var frame = 0

enum EstadoBoss { IDLE, PERSEGUINDO, ATACANDO, USANDO_HABILIDADE }

var estado: EstadoBoss = EstadoBoss.PERSEGUINDO
var tempo_entre_habilidades = 4.0
var cooldown_habilidade = 0.0
var habilidades = []

func _ready():
	if boss:
		habilidades = [habilidade_projetil, habilidade_area, habilidade_cura]


var drop = preload("res://scenes/pickups.tscn")


var health: float:
	set(value):
		health = value
		if health <=0:
			drop_item()
			queue_free()

var elite: bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = load("res://shaders/rainbow.tres")
			scale = Vector2(1.5,1.5)
			health *= 8
			damage *= 1.8

var boss: bool = false:
	set(value):
		boss = value
		if value and boss_enemy:
			var capsule_shape = $CollisionShape2D.shape.duplicate(true)  # Cria uma cópia independente
			$Sprite2D.texture = boss_enemy.texture
			$Sprite2D.hframes = boss_enemy.hframe
			$Sprite2D.vframes = boss_enemy.vframe
			$Sprite2D.scale.x = boss_enemy.scalesx
			$Sprite2D.scale.y = boss_enemy.scalesy
			$Sprite2D.flip_h = boss_enemy.flip
			if capsule_shape is CapsuleShape2D:
				capsule_shape.radius = boss_enemy.coll_rad
				capsule_shape.height = boss_enemy.coll_height
			$CollisionShape2D.shape = capsule_shape  # Atribui a cópia modificad
			damage = boss_enemy.damage
			health = boss_enemy.health

var type: Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		$Sprite2D.hframes = value.hframe
		$Sprite2D.vframes = value.vframe
		$Sprite2D.scale.x = value.scalesx
		$Sprite2D.scale.y = value.scalesy
		$Sprite2D.flip_h = value.flip
		$Sprite2D.set_meta("velxe", value.velxe)
		$Sprite2D.set_meta("velxd", value.velxd)
		damage = value.damage
		health = value.health


func _physics_process(delta: float) -> void:
	checar_separacao(delta)
	knockback_update(delta)
	if boss:
		cooldown_habilidade -= delta
		if cooldown_habilidade <= 0:
			usando_habilidade()
			cooldown_habilidade = tempo_entre_habilidades
	frame_counter += 1
	if frame_counter >= $Sprite2D.hframes:
		frame_counter = 0
		frame = (frame + 1) % $Sprite2D.hframes
		$Sprite2D.frame = frame  # Atualiza o frame do Sprite2D
	if velocity.x > 0 :
		$Sprite2D.frame_coords.y = $Sprite2D.get_meta("velxd")
		if $Sprite2D.get_meta("velxd") == $Sprite2D.get_meta("velxe"):
			$Sprite2D.flip_h = false
			boss_enemy.flip = false
	elif velocity.x < 0:
		$Sprite2D.frame_coords.y = $Sprite2D.get_meta("velxe")
		if $Sprite2D.get_meta("velxd") == $Sprite2D.get_meta("velxe"):
			$Sprite2D.flip_h = true	
		
		
func checar_separacao(_delta):
	separacao = (player_ref.position - position).length()
	if separacao >= 1500 and not elite:  #depende do tamanho do mapa viu dog, alterar
		queue_free()
	if separacao<player_ref.nead_enemy_distancia:
		player_ref.nead_enemy = self	
		
		
############################## boss vvvvvvvvvvvvvvvvv ####################
func usando_habilidade():
	if habilidades.size() > 0:
		var habilidade_escolhida = habilidades.pick_random()
		habilidade_escolhida.call()


func habilidade_projetil():
	var cena_proj = preload("res://scenes/projetil_boss.tscn")
	var proj = cena_proj.instantiate()
	proj.position = global_position
	proj.direcao = (player_ref.global_position - global_position).normalized()
	proj.damage = damage * 1.2
	get_tree().current_scene.add_child(proj)


func habilidade_area():
	var aoe = Area2D.new()
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 300
	col.shape = shape
	aoe.position = global_position
	aoe.add_child(col)
	get_tree().current_scene.add_child(aoe)

	# Sprite visual do efeito
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://icon.svg")  # Crie um círculo transparente simples
	sprite.scale = Vector2(1.5, 1.5)
	sprite.modulate = Color(1, 0, 0, 0.5)  # Semitransparente vermelho
	aoe.add_child(sprite)

	aoe.connect("body_entered", Callable(self, "_on_area_dano_boss"))

	await get_tree().create_timer(1.5).timeout
	aoe.queue_free()


func _on_area_dano_boss(body):
	if body.is_in_group("player"):
		body.take_damage(damage * 2)

func habilidade_cura():
	var cura = damage * 2.0
	health += cura
	damage_popup(cura, 1.0, true)

######################################### boss ^^^^^^^^^^ ##################33
func knockback_update(delta):
	velocity = (player_ref.position - position).normalized() * speed
	knockback = knockback.move_toward(Vector2.ZERO, 1)
	velocity += knockback
	var collider = move_and_collide(velocity * delta)
	if collider: 
		collider.get_collider().knockback = (collider.get_collider().global_position - global_position).normalized() * 50


func damage_popup(amount, modifier = 1.0, is_heal := false):
	var popup = damage_popup_node.instantiate()
	var final_value = amount * modifier
	popup.text = "+" + str(abs(final_value)) if is_heal else str(final_value)
	popup.position = position + Vector2(-50, -25)
	if modifier > 1.0:
		popup.set("theme_override_colors/font_color", Color.RED)
	elif is_heal:
		popup.set("theme_override_colors/font_color", Color.GREEN)
	get_tree().current_scene.add_child(popup)

	
	
func take_damage(amount):
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(3,0.25,0.25),0.2)
	tween.chain().tween_property($Sprite2D,"modulate", Color(1,1,1),0.2)
	tween.bind_node(self)
	var chance = randf()
	var modifier : float = 2.0 if (chance < (1.0 - (1.0/player_ref.luck))) else 1.0
	damage_popup(amount, modifier)
	
	health-=amount * modifier
	

func drop_item():
	if type.drops.size() == 0:
		return
	var item = type.drops.pick_random()
	if elite:
		item = load("res://resources/pickups/Chest.tres")
	
	var item_to_drop = drop.instantiate()
	
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_ref = player_ref
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop)
	queue_free()
