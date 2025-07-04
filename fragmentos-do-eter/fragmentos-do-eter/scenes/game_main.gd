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



func _on_spawner_phase_completed(next_phase_number: int):
	# PASSO 2: ATUALIZAR O LEVELMANAGER
	LevelManager.proximo_level_path = "res://scenes/mundo_%d.tscn" % next_phase_number
	LevelManager.proximo_level_numero = next_phase_number

	# PASSO 3: CARREGAR O NOVO MAPA
	if next_phase_number > 5:
		return
	carregar_level_atual()

	# PASSO 4: RESETAR O JOGADOR
	if player:
		player.reset_state()

	# PASSO 5: RESETAR O INVENTÁRIO
	if inventory_ui:
		inventory_ui.reset_inventory()

	# PASSO 6: CONFIGURAR O SPAWNER
	if spawner:
		spawner.setup_for_phase(next_phase_number)
