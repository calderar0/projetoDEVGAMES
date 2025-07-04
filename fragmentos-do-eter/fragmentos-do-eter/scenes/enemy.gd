extends CharacterBody2D

# Removido: @export var boss_enemy: Enemy, mini_boss1, etc.
var knockback_recovery: float = 200.0 
# A propriedade 'type' agora controla tudo.

@export var player_ref: CharacterBody2D
@export var type: Enemy: # Esta é a propriedade mais importante agora
	set(value):
		type = value
		if type == null: return

		# --- Configuração Visual e de Status (como já estava) ---
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
		
		var capsule_shape = $CollisionShape2D.shape.duplicate(true)
		if capsule_shape is CapsuleShape2D:
			capsule_shape.radius = value.coll_rad
			capsule_shape.height = value.coll_height
		$CollisionShape2D.shape = capsule_shape

		# --- NOVA LÓGICA PARA CONTROLAR O COMPORTAMENTO ---
		self.knockback_recovery = value.knockback_recovery # <-- ADICIONE ESTA LINHA
		# Define se este inimigo é um chefe (principal ou mini)
		self.boss = type.is_boss 
		# Define se este inimigo específico usa habilidades
		self.uses_skills = type.uses_skills

var damage_popup_node = preload("res://scenes/damage.tscn")
var drop = preload("res://scenes/pickups.tscn")

var direction: Vector2
var speed : float = 75.0
var damage: float
var knockback: Vector2
var separacao: float

# Contador estático para todos os chefes.
# Nota: Variáveis estáticas são compartilhadas entre todas as instâncias da classe.
static var bossCounter: int = 0

var frame_counter = 0
var frame = 0

# Flags de comportamento que serão definidas pelo 'type'
var boss: bool = false
var uses_skills: bool = false

var tempo_entre_habilidades = 4.0
var cooldown_habilidade = 0.0

var health: float:
	set(value):
		health = value
		if health <= 0:
			# A lógica agora é simples: se era um chefe (qualquer um), faça a ação.
			if boss:
				bossCounter += 1 # É uma boa prática decrementar o contador
				print("Um chefe foi derrotado! Chefes restantes: ", bossCounter)
				Savedata.saveFase()
			
			drop_item()
			queue_free() #é chamado dentro de drop_item, então talvez não precise aqui.
			# Se drop_item não chama queue_free(), descomente a linha abaixo.
			# queue_free()

func _ready():
	# Se este inimigo foi definido como um chefe no recurso, incrementa o contador global.
	if boss:
		print("Um chefe apareceu! Total de chefes na fase: ", bossCounter)
		
	# A habilidade de cura não precisa estar numa lista se só o chefe principal a usa.
	# A lógica de qual habilidade usar pode ser mais simples.

# A propriedade 'elite' pode continuar funcionando como antes, sem problemas.
var elite: bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = load("res://shaders/rainbow.tres")
			scale = Vector2(1.5,1.5)
			if not boss:
				health *= 8
				damage *= 1.8

func _physics_process(delta: float) -> void:
	checar_separacao(delta)
	knockback_update(delta)
	
	# MUDANÇA IMPORTANTE: Agora só checa se tem permissão para usar skills.
	# O chefe principal terá 'boss' = true e 'uses_skills' = true.
	# Um miniboss terá 'boss' = true e 'uses_skills' = false.
	if boss and uses_skills:
		cooldown_habilidade -= delta
		if cooldown_habilidade <= 0:
			usando_habilidade()
			cooldown_habilidade = tempo_entre_habilidades
			
	frame_counter += 1
	if frame_counter >= $Sprite2D.hframes:
		frame_counter = 0
		frame = (frame + 1) % $Sprite2D.hframes
		$Sprite2D.frame = frame
	
	if velocity.x > 0:
		var linha = int($Sprite2D.get_meta("velxd"))
		$Sprite2D.frame_coords.y = linha if linha < $Sprite2D.vframes else 0
		if $Sprite2D.get_meta("velxd") == $Sprite2D.get_meta("velxe"):
			$Sprite2D.flip_h = false
	elif velocity.x < 0:
		var linha = int($Sprite2D.get_meta("velxe"))
		$Sprite2D.frame_coords.y = linha if linha < $Sprite2D.vframes else 0
		if $Sprite2D.get_meta("velxd") == $Sprite2D.get_meta("velxe"):
			$Sprite2D.flip_h = true

# ... o resto do seu código (usando_habilidade, knockback_update, take_damage, etc.)
# pode permanecer exatamente o mesmo, pois a lógica dele já depende da flag 'boss',
# que agora é configurada corretamente para todos os tipos de chefes.

# O único cuidado é na função drop_item:
func die_from_screen_wipe():
	if type.is_boss == true:
		return
	drop_item()

func drop_item():
	if type == null or type.drops.size() == 0:
		queue_free() # Certifique-se de que o inimigo seja removido mesmo sem drop
		return
		
	var item_resource = type.drops.pick_random()
	if elite:
		item_resource = load("res://resources/pickups/Chest.tres")
	
	var item_to_drop = drop.instantiate()
	item_to_drop.type = item_resource
	item_to_drop.position = position
	item_to_drop.player_ref = player_ref
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop)
	queue_free() # Movido de fora para garantir que sempre seja chamado no final.

# ... Cole o resto das suas funções aqui (checar_separacao, usando_habilidade, etc)
# Elas não precisam de alteração.
func checar_separacao(_delta):
	separacao = (player_ref.position - position).length()
	if separacao >= 1500 and not elite:
		queue_free()
	if separacao < player_ref.nead_enemy_distancia:
		player_ref.nead_enemy = self

func usando_habilidade():
	var distancia = position.distance_to(player_ref.position)
	var max_engagement_range = 700.0
	if distancia > max_engagement_range:
		return
	if health < type.health * 0.25 and randf() < 0.4:
		habilidade_cura.call()
	elif distancia < 500:
		habilidade_area.call()
	elif distancia < max_engagement_range:
		habilidade_projetil.call()

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
	aoe.add_child(col)
	add_child(aoe)
	aoe.position = Vector2.ZERO
	var sprite = AnimatedSprite2D.new()
	var tex = preload("res://assets/enemies/skillsBoss/danoArea.png")
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("explosao")
	var frame_width = tex.get_width() / 14
	var frame_height = tex.get_height() / 9
	var linha_desejada = 1
	for x in range(14):
		var atlas = AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(x * frame_width, linha_desejada * frame_height, frame_width, frame_height)
		sprite_frames.add_frame("explosao", atlas)
	sprite.frames = sprite_frames
	sprite.animation = "explosao"
	sprite.play("explosao")
	sprite.scale = Vector2(10, 10)
	sprite.position = Vector2(0, 0)
	aoe.add_child(sprite)
	aoe.connect("body_entered", Callable(self, "_on_area_dano_boss"))
	await get_tree().create_timer(1.2).timeout
	aoe.queue_free()

func _on_area_dano_boss(body):
	if body.is_in_group("player"):
		body.take_damage(damage * 2)

func habilidade_cura():
	var cura = damage * 2.0
	health += cura
	damage_popup(cura, 1.0, true)

func knockback_update(delta):
	velocity = (player_ref.position - position).normalized() * speed
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery * delta)
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
	health -= amount * modifier
