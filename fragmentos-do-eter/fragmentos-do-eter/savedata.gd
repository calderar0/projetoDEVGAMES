extends Node2D

var gold: int
var skill_tree: Array = []
var fase: int

const PATH = "user://player_data.cfg"
@onready var config = ConfigFile.new()

func _ready():
	load_data()

func save_data():
	set_data()  # Garante que os dados sejam atualizados antes de salvar
	var error = config.save(PATH)
	if error != OK:
		print("erro")

func set_data():
	config.set_value("Player", "gold", gold)
	config.set_value("Player", "skill_tree", skill_tree)
	config.set_value("Player", "fase", fase)

func set_and_save():
	set_data()
	save_data()

func load_data():
	var error = config.load(PATH)
	if error != OK:
		gold = 0  # Começa do zero se não existir save
		skill_tree = []
		fase = 1
		set_and_save()
	else:
		gold = config.get_value("Player", "gold", 0)  # Usa 0 se não existir
		skill_tree = config.get_value("Player", "skill_tree", [])
		fase = config.get_value("Player", "fase", 1)

# Função para adicionar gold e salvar automaticamente
func add_gold(amount: int):
	gold += amount
	set_and_save()


func saveFase():
	if fase < 5:
		fase += 1
		set_and_save()
	else:
		pass
	
