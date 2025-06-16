extends CharacterBody2D



@onready var morreu = $AudioStreamPlayer2D
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
		if XP >= get_xp_needed(level):
			XP -= get_xp_needed(level)
			level += 1
		%nnumero.text = "xp" + str(value)

var total_XP: int = 0
var level: int = 1:
	set(value):
		level = value
		%Level.text = "Lv" + str(value)
		%Options.show_option()
		%XP.max_value = get_xp_needed(level)
		

func get_xp_needed(level: int) -> int:
	# Fórmula de progressão: base * (nível ^ fator)
	var base := 1   # XP necessário no nível 1
	var fator := 1   # Crescimento exponencial (aumente para deixar mais difícil)
	return int(base * pow(level, fator))
			

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
