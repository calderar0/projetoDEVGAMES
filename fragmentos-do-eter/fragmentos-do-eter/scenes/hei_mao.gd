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
var maxframe: int = 3
var animation_speed: int = 10  # Controla a velocidade da animação

func _process(delta: float) -> void:
	if !sprite:  # Verificação de segurança
		return
		
	# Usando delta time para animação mais suave
	frame_counter += 1
	
	if frame_counter >= animation_speed:  # A cada 1 segundo (ajustado pela animation_speed)
		frame_counter = 0
		frames = (frames + 1) % maxframe
		print("Mudando para o frame: ", frames)  # Debug
		sprite.frame = frames

func _ready():
	print("DialogueManager: ", DialogueManager)
	print("Conectando o sinal...")  # Verificando
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)  # Garantir que está conectando
	print("Sinal conectado")  # Confirma que a conexão foi feita

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
		print("Iniciando diálogo...")  # Verificação

func _on_dialogue_end():
	print("Fim do diálogo - Despausando")  # 🛠️ Verificando se chegou aqui
	get_tree().paused = false  # 🟢 Despausa o jogo
	print("Jogo pausado? ", get_tree().paused)  # 🛠️ Debug
	queue_free()

	# Reinicia os timers normalmente
	timer1.start()
	timer2.start()
	timer3.start()
	timer4.start()
	timer5.start()
