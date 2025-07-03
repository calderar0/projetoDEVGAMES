extends Node2D

@export var player: CharacterBody2D
@export var enemy: PackedScene
@export var destructible: PackedScene
@export var area_anti_spawn: Area2D
@export var current_phase_path: String = "res://resources/Enemies/Phase1/"
@export var enemy_type: Array[Enemy]
const FINAL_BOSS_PHASE = 6 # Defina aqui qual é a fase do chefe

# --- Flags de controle do Spawner ---
var can_spawn: bool = true
var boss_spawned: bool = false
var is_miniboss_active: bool = false # <-- NOVA FLAG: Verdadeira quando o miniboss da fase está vivo.
var miniboss_index: int = 4 # O 5º inimigo da lista (índice 4).
var past_phase: int
# --- Variáveis de estado da fase ---
var actual_phase: int = 1

var distance: float = 900
var minute: int:
	set(value):
		minute = value
		%Minute.text = str(value)

var seconds: int:
	set(value):
		seconds = value
		if seconds >= 60:
			seconds -= 60
			minute += 1
		%Second.text = str(seconds).lpad(2,'0')


func _ready():
	actual_phase = 1
	# Zera o contador de chefes do script do inimigo ao iniciar uma nova partida.
	# Substitua 'EnemyScript' pelo nome real do arquivo do seu script de inimigo.
	# Ex: load("res://enemy.gd").bossCounter = 0
	load_enemies_from_phase(current_phase_path)
	

func load_enemies_from_phase(path: String) -> void:
	enemy_type.clear()
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var full_path = path + "/" + file_name
				var enemy_data = load(full_path)
				if enemy_data:
					enemy_type.append(enemy_data)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	# Garante que a lista está ordenada pelo nome do arquivo, para que o 5º seja sempre o mesmo
	enemy_type.sort_custom(func(a, b): return a.resource_path < b.resource_path)


# No seu script do Spawner (Spawner.gd)

func change_phase():
	is_miniboss_active = false
	actual_phase += 1
	past_phase = actual_phase - 1
	var nome_mundo_atual = "../MUNDO%d" % actual_phase
	var nome_mundo_anterior = "../MUNDO%d" % past_phase
	var no_do_mundo = get_node(nome_mundo_atual)
	var no_do_mundo_A = get_node(nome_mundo_anterior)
	
	no_do_mundo_A.visible = false
	no_do_mundo.visible = true
	self.seconds = 0
	self.minute = 0

	if actual_phase == FINAL_BOSS_PHASE:
		# CHEGOU A HORA DO CHEFE FINAL!
		print("A FASE FINAL COMEÇOU!")
		# Para todos os spawners normais
		set_physics_process(false) # Desativa _physics_process para parar spawns
		spawn_final_boss() # Chama uma nova função para invocar o chefe
	elif actual_phase < FINAL_BOSS_PHASE:
		# Continua para a próxima fase normal
		current_phase_path = "res://resources/Enemies/Phase%d/" % actual_phase
		load_enemies_from_phase(current_phase_path)
	else:
		# O jogo acabou, o chefe foi derrotado!
		# Aqui você pode chamar a tela de vitória, etc.
		get_tree().quit() # Exemplo: fecha o jogo

func spawn_final_boss():
	# Limpa quaisquer inimigos restantes na tela
	get_tree().call_group("Enemy", "queue_free")

	var boss_resource = load("res://resources/Enemies/Phase6/0AvreBossFinal.tres") # Exemplo de caminho
	var enemy_inst = enemy.instantiate()
	enemy_inst.type = boss_resource
	enemy_inst.player_ref = player
	enemy_inst.position = get_rand_pos()
	boss_spawned = true
	enemy_inst.tree_exited.connect(_on_boss_defeated)
	get_tree().current_scene.add_child(enemy_inst)


func _physics_process(_delta):
	if player.health <= 0:
		can_spawn = false
		return
	# A lógica de 'can_spawn' baseada na contagem de inimigos é boa
	if get_tree().get_nodes_in_group("Enemy").size() < 300:
		can_spawn = true
	else:
		can_spawn = false

# spawner() foi refatorado para ser a função central de criação
func spawner(pos: Vector2, elite: bool = false, is_main_boss: bool = false):
	# Condições de parada globais
	if player.health <= 0:
		return
	if boss_spawned or is_miniboss_active: # Se o chefe principal OU um miniboss estiver ativo, não faça nada.
		return
	if not can_spawn and not elite and not is_main_boss:
		return
	if enemy_type.is_empty():
		return
		
	# --- LÓGICA PRINCIPAL CORRIGIDA ---
	var enemy_to_spawn_data: Enemy
	var current_enemy_index = minute % enemy_type.size()

	# Checa se é hora do MINIBOSS (5º inimigo da fase)
	if enemy_type.size() > miniboss_index and current_enemy_index == miniboss_index:
		is_miniboss_active = true
		enemy_to_spawn_data = enemy_type[miniboss_index]
		print("Miniboss da Fase ", actual_phase, " apareceu!")
		
		var enemy_inst = enemy.instantiate()
		enemy_inst.type = enemy_to_spawn_data
		enemy_inst.player_ref = player
		enemy_inst.position = pos
		# Opcional: Tornar o miniboss sempre elite
		enemy_inst.elite = true
		# Conecta o sinal para avançar a fase quando ele morrer
		enemy_inst.tree_exited.connect(_on_miniboss_defeated)
		get_tree().current_scene.add_child(enemy_inst)
		
	# Se não for o miniboss, spawna um inimigo normal
	else:
		# Não deixa o spawner selecionar o índice do miniboss durante o spawn normal
		if current_enemy_index == miniboss_index:
			current_enemy_index = 0 # ou qualquer outro índice padrão
			
		enemy_to_spawn_data = enemy_type[current_enemy_index]
		
		var enemy_inst = enemy.instantiate()
		enemy_inst.type = enemy_to_spawn_data
		enemy_inst.player_ref = player
		enemy_inst.position = pos
		enemy_inst.elite = elite
		# A flag 'boss' do inimigo será definida automaticamente pelo recurso 'Enemy'
		# enemy_inst.boss = is_main_boss # Esta linha não é mais necessária com a refatoração anterior
		
		if is_main_boss:
			boss_spawned = true
			enemy_inst.tree_exited.connect(_on_boss_defeated)

		get_tree().current_scene.add_child(enemy_inst)


# --- FUNÇÃO PARA QUANDO O MINIBOSS É DERROTADO ---
func _on_miniboss_defeated():
	print("Miniboss da Fase ", actual_phase, " derrotado! Mudando de fase.")
	change_phase()
	# is_miniboss_active é resetado dentro de change_phase()


func _on_boss_defeated():
	boss_spawned = false
	# Opcional: mudar de fase ou finalizar o jogo após derrotar o chefe principal
	# change_phase() 


func get_rand_pos() -> Vector2:
	var pos: Vector2
	while true:
		pos = player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
		if is_position_valid(pos):
			break
	return pos
	
# Timers agora só precisam chamar a função 'amount' ou 'spawner'
# A lógica de "pode spawnar?" está toda centralizada na função 'spawner'.
func amount(number: int = 1):
	var actual_number = min(number, 5)
	for i in range(actual_number):
		spawner(get_rand_pos())

func _on_timer_timeout() -> void:
	seconds += 1
	amount(seconds % 10)

func _on_pattern_timeout() -> void:
	for i in range(25):
		spawner(get_rand_pos())

func _on_elite_timeout() -> void:
	spawner(get_rand_pos(), true, false)
	
func _on_boss_timeout() -> void:
	# O último parâmetro 'is_main_boss' foi removido da chamada spawner, 
	# pois a propriedade `is_boss` do recurso Enemy já cuida disso.
	# Para spawnar um chefe específico, você precisaria de uma lógica diferente.
	# Por ora, vamos manter a lógica de miniboss da fase.
	# spawner(get_rand_pos(), false, true) # <- Lógica antiga
	# Se você tem um recurso específico para o CHEFE, pode fazer assim:
	var boss_resource = load("res://resources/Enemies/Phase6/AvreBossFinal.tres") # Exemplo de caminho
	var enemy_inst = enemy.instantiate()
	enemy_inst.type = boss_resource
	enemy_inst.player_ref = player
	enemy_inst.position = get_rand_pos()
	boss_spawned = true
	enemy_inst.tree_exited.connect(_on_boss_defeated)
	get_tree().current_scene.add_child(enemy_inst)


func _on_destructible_timeout() -> void:
	spawn_destructible(get_rand_pos())
	
func spawn_destructible(pos):
	var object_instance = destructible.instantiate()
	object_instance.position = pos
	get_tree().current_scene.add_child(object_instance)

func is_position_valid(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	var result = space_state.intersect_point(query)
	for item in result:
		if item.collider == area_anti_spawn:
			return false
	return true
