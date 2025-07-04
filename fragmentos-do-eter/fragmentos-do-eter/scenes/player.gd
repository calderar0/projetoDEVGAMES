extends CharacterBody2D

@export var default_stats: PlayerDefaultStats


var is_dead: bool = false
var health: float = 100.0:
	set(value):
		health = max(value, 0)
		%Health.value = value

var mov_speed: float = 150.0:
		set(value):
			mov_speed = value
			
		#%mov_speed.text = "R: " + str(value)

var max_health: float = 100:
		set(value):
			max_health = value
			%Health.max_value = value

var recovery: float = 0:
	set(value):
		recovery = value

var armor: float = 0:
		set(value):
			armor = value
			
var might: float = 1.0:
		set(value):
			might = value
			
			
var area: float = 0:
		set(value):
			area = value
			
var magnet: float = 0:
	set(value):
		magnet = value
		%Magnet.shape.radius = 50 + value
		
var growth: float = 1:
		set(value):
			growth = value

var luck: float = 1.0:
		set(value):
			luck = value



var nead_enemy
var nead_enemy_distancia: float= 150 + area

var gold: int = 0:
	set(value):
		gold = value
		%Gold.text = "Gold:" + str(value)

var XP: int = 0:
	set(value):
		XP = value
		%XP.value = value
		while XP >= get_xp_needed(level):
			XP -= get_xp_needed(level)
			self.level += 1
		%nnumero.text = "xp" + str(value)

var total_XP: int = 0
var level: int = 1:
	set(value):
		if value > level:
			%Options.show_option()
		level = value
		%Level.text = "Lv" + str(value)
		%XP.max_value = get_xp_needed(level)
		

func get_xp_needed(level: int) -> int:
	# Fórmula de progressão mais robusta
	var base_xp := 1  # XP necessário para ir do Nv 1 para o 2
	var factor := 1   # A cada nível, a necessidade de XP aumenta em 20%
	
	if level <= 0: return base_xp # Apenas uma segurança
	
	# A fórmula calcula a necessidade exponencialmente
	return int(base_xp * pow(factor, level - 1))
			

func ajustar_camera():
	var tela_size = get_window().size
	var zoom = max(tela_size.y / 1080.0, 1.5)  # Nunca menor que 1.0
	$Camera2D.zoom = Vector2(zoom, zoom)

func _physics_process(delta: float) -> void:
	ajustar_camera()
	if is_instance_valid(nead_enemy):
		nead_enemy_distancia = nead_enemy.separacao
	else:
		nead_enemy_distancia = 150 + area
		nead_enemy = null
	
	if is_dead:
		return
		
	velocity = Input.get_vector("left","right","up","down") * mov_speed
	#verifica se o player ta morto e para tudo q ele poderia fazer
	#basicamente só seta a speed pra 0 e impede ele de se mover
	#mas não para os tiros das armas ainda...
	if %Health.value <= 0:
		%morte.playing = true
		mov_speed = 0
		is_dead = true
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished
		get_tree().paused = true
			
		%Morreu.show()
		return
	
	#animações tlg
	if not velocity and mov_speed != 0:
		$AnimatedSprite2D.play("idle")
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walk")
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("walk")
	elif velocity.y < 0:
		$AnimatedSprite2D.play("walk_up")
	else:
		$AnimatedSprite2D.play("walk_down")
		
		
	move_and_collide(velocity * delta)
	check_XP()
	health += recovery * delta


func _on_item_upgraded(upgrade: Stats):
	max_health += upgrade.max_health
	recovery += upgrade.recovery
	armor += upgrade.armor
	mov_speed += upgrade.mov_speed
	might += upgrade.might
	area += upgrade.area
	magnet += upgrade.magnet
	growth += upgrade.growth
	luck += upgrade.luck

func _ready() -> void:
	reset_state()
	%Morreu.hide()
	%musica.playing = true
	Persistence.gain_bonus_stats(self)

func take_damage(amount):
	health -= max(amount * (amount/(amount + armor)), 1)

func _on_self_damage_body_entered(body: Node2D) -> void:
	take_damage(body.damage)


func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)
	
func gain_XP(amount):
	XP += amount * growth
	total_XP += amount * growth
	
func check_XP():
	if XP > %XP.max_value:
		XP -= %XP.max_value
		level += 1


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.has_method("follow"):
		area.follow(self)

func gain_gold(amount):
	gold += amount

func open_chest():
	$UI/Chest.open()


func reset_state():
	print("Resetando status do jogador.")
	
	if not default_stats:
		printerr("ERRO: Recurso 'default_stats' não foi atribuído ao jogador no Inspetor!")
		return
	
	# 1. RESETAR STATUS PARA OS VALORES PADRÃO DO RECURSO
	self.max_health = default_stats.max_health
	self.mov_speed = default_stats.mov_speed
	self.recovery = default_stats.recovery
	self.armor = default_stats.armor
	self.might = default_stats.might
	self.area = default_stats.area
	self.magnet = default_stats.magnet
	self.growth = default_stats.growth
	self.luck = default_stats.luck

	
	# 2. REAPLICAR BÔNUS PERMANENTES
	if Persistence:
		Persistence.gain_bonus_stats(self)
	
	# 3. RESETAR ESTADO DE JOGO (Level, XP, Vida)
	self.level = 1
	self.XP = 0
	self.health = self.max_health
	
	is_dead = false
	%Morreu.hide()
	get_tree().paused = false
