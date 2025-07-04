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
		print("ERRO: Nenhum caminho de nível foi definido no LevelManager!")
		return

	# 3. Carrega a cena do mapa como um recurso.
	var level_packed_scene = load(LevelManager.proximo_level_path)
	
	if level_packed_scene:
		# 4. Instancia a cena do mapa (cria os nós).
		var level_instance = level_packed_scene.instantiate()
		
		# 5. Adiciona a instância do mapa como filha do nosso contêiner.
		level_container.add_child(level_instance)
		print("Level '", LevelManager.proximo_level_path, "' carregado com sucesso!")
	else:
		print("ERRO: Falha ao carregar a cena do level em '", LevelManager.proximo_level_path, "'")

func _on_spawner_phase_completed(next_phase_number: int):
	print("--- INICIANDO MUDANÇA DE FASE PARA ", next_phase_number, " ---")

	# PASSO 1: VERIFICAR SE NOSSAS REFERÊNCIAS EXISTEM
	print("1. Verificando referências...")
	if player == null:
		print(">>>>> ERRO CRÍTICO: A referência 'player' está NULA! Verifique o caminho em @onready var.")
	if inventory_ui == null:
		print(">>>>> ERRO CRÍTICO: A referência 'inventory_ui' está NULA! Verifique o caminho em @onready var.")
	if spawner == null:
		print(">>>>> ERRO CRÍTICO: A referência 'spawner' está NULA! Verifique o caminho em @onready var.")

	# PASSO 2: ATUALIZAR O LEVELMANAGER
	print("2. Atualizando LevelManager...")
	LevelManager.proximo_level_path = "res://scenes/mundo_%d.tscn" % next_phase_number
	LevelManager.proximo_level_numero = next_phase_number
	print("   LevelManager atualizado para o mundo ", next_phase_number)

	# PASSO 3: CARREGAR O NOVO MAPA
	print("3. Carregando novo mapa...")
	carregar_level_atual()
	print("   Mapa carregado com sucesso.")

	# PASSO 4: RESETAR O JOGADOR
	print("4. Enviando comando de reset para o jogador...")
	if player:
		player.reset_state()
		print("   Comando 'reset_state' ENVIADO para o jogador.")
	else:
		print("   FALHA: Não foi possível enviar comando para o jogador pois a referência é nula.")

	# PASSO 5: RESETAR O INVENTÁRIO
	print("5. Enviando comando de reset para o inventário (UI)...")
	if inventory_ui:
		inventory_ui.reset_inventory()
		print("   Comando 'reset_inventory' ENVIADO para a UI.")
	else:
		print("   FALHA: Não foi possível enviar comando para a UI pois a referência é nula.")

	# PASSO 6: CONFIGURAR O SPAWNER
	print("6. Enviando comando de setup para o spawner...")
	if spawner:
		spawner.setup_for_phase(next_phase_number)
		print("   Comando 'setup_for_phase' ENVIADO para o spawner.")
	else:
		print("   FALHA: Não foi possível enviar comando para o spawner pois a referência é nula.")

	print("--- MUDANÇA DE FASE CONCLUÍDA ---")
