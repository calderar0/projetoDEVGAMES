extends Node

@export var resource: DialogueResource  
@export var sprite: Sprite2D
@onready var spawner = get_node("../Spawner")
@onready var timer1 = spawner.get_node("Timer")
@onready var timer2 = spawner.get_node("Pattern")
@onready var timer3 = spawner.get_node("Elite")
@onready var timer4 = spawner.get_node("Destructible")
@onready var timer5 = spawner.get_node("Boss")

var frame_counter: int = 0
var frames: int = 0
var maxframe: int = 8
var animation_speed: int = 10  # Controla a velocidade da animação

func _process(delta: float) -> void:
	if !sprite:  # Verificação de segurança
		return
		
	# Usando delta time para animação mais suave
	frame_counter += 1
	
	if frame_counter >= animation_speed:  # A cada 1 segundo (ajustado pela animation_speed)
		frame_counter = 0
		frames = (frames + 1) % maxframe
		sprite.frame = frames

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)  # Garantir que está conectando

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if resource:
		
		var animated_sprite = get_node("../Player/AnimatedSprite2D")
		if animated_sprite:
			animated_sprite.play("idle")
			#await animated_sprite.animation_finished
		get_tree().paused = true  # 🔴 Pausa o jogo
		var balloon = DialogueManager.show_dialogue_balloon(resource, "start")
	# Conecta ao sinal de remoção do balão
		balloon.tree_exited.connect(_on_dialogue_end)
		#DialogueManager.show_dialogue_balloon(resource, "start")

func _on_dialogue_end():
	get_tree().paused = false  # 🟢 Despausa o jogo

	queue_free()

	# Reinicia os timers normalmente
	timer1.start()
	timer2.start()
	timer3.start()
	timer4.start()
	timer5.start()
