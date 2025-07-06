extends Node2D


@onready var player = $Player
@onready var level_container = $LevelContainer
@onready var spawner = $Spawner
@onready var inventory_ui = $Player/UI/Options

func _ready() -> void:
	spawner.phase_completed.connect(_on_spawner_phase_completed)
	var fase_inicial = LevelManager.proximo_level_numero
	spawner.setup_for_phase(fase_inicial)
	carregar_level_atual()

func carregar_level_atual() -> void:
	# 1. Limpa o mapa antigo, se houver algum.
	#    Isso é útil se você for trocar de fase sem voltar para o menu.
	for child in level_container.get_children():
		child.queue_free()

	# 2. Verifica se o caminho no gerenciador é válido.
	if LevelManager.proximo_level_path.is_empty():
		return

	# 3. Carrega a cena do mapa como um recurso.
	var level_packed_scene = load(LevelManager.proximo_level_path)
	
	if level_packed_scene:
		# 4. Instancia a cena do mapa (cria os nós).
		var level_instance = level_packed_scene.instantiate()
		
		# 5. Adiciona a instância do mapa como filha do nosso contêiner.
		level_container.add_child(level_instance)



# No seu script GameMain.gd

# No seu script GameMain.gd

func _on_spawner_phase_completed(next_phase_number: int):
	# Atualiza o estado do jogo
	LevelManager.proximo_level_numero = next_phase_number

	# Condição para carregar o mapa. Só carrega se NÃO for a fase do chefe.
	if next_phase_number < spawner.FINAL_BOSS_PHASE:
		LevelManager.proximo_level_path = "res://scenes/mundo_%d.tscn" % next_phase_number
		carregar_level_atual()
	else:
		# Na fase do chefe, apenas limpa o mapa atual para criar uma arena limpa.
		for child in level_container.get_children():
			child.queue_free()

	# --- NOVA LÓGICA AQUI ---
	# Só reseta o estado do jogador e o inventário se a próxima fase NÃO for a do chefe.
	if next_phase_number < spawner.FINAL_BOSS_PHASE:
		if player:
			player.reset_state()
		if inventory_ui:
			inventory_ui.reset_inventory()
	# -------------------------

	# O setup do spawner sempre acontece, para iniciar a próxima fase/chefe.
	if spawner:
		spawner.setup_for_phase(next_phase_number)
