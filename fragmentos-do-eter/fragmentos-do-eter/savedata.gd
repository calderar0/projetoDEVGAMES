extends Node2D

var gold: int
var skill_tree: Array = []

const PATH = "user://player_data.cfg"
@onready var config = ConfigFile.new()

func _ready():
	load_data()

func save_data():
	set_data()  # Garante que os dados sejam atualizados antes de salvar
	var error = config.save(PATH)
	if error != OK:
		print("Erro ao salvar os dados:", error)

func set_data():
	config.set_value("Player", "gold", gold)
	config.set_value("Player", "skill_tree", skill_tree)

func set_and_save():
	set_data()
	save_data()

func load_data():
	var error = config.load(PATH)
	if error != OK:
		print("Arquivo de save não encontrado ou corrompido. Criando novo.")
		gold = 0  # Começa do zero se não existir save
		skill_tree = []
		set_and_save()
	else:
		gold = config.get_value("Player", "gold", 0)  # Usa 0 se não existir
		skill_tree = config.get_value("Player", "skill_tree", [])

# Função para adicionar gold e salvar automaticamente
func add_gold(amount: int):
	gold += amount
	print("Gold atualizado:", gold)
	set_and_save()
