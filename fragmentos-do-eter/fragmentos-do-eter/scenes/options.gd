extends VBoxContainer

@export var weapons: HBoxContainer
@export var passive_items: HBoxContainer
var OptionSlot = preload("res://scenes/option_slot.tscn")

@export var particles: GPUParticles2D
@export var panel: NinePatchRect

const weapon_path: String = "res://resources/Weapons/"
const passive_item_path: String = "res://resources/PassiveItems/"

const SPEAR_RESOURCE_PATH = "res://resources/Weapons/spear.tres"


var every_item
var every_weapon
var every_passive


func _ready() -> void:
	hide()
	particles.hide()
	panel.hide()
	get_all_item()
	reset_inventory()

func close_option():
	hide()
	particles.hide()
	panel.hide()
	get_tree().paused = false

func get_available_resource_in(items) -> Array[Item]:
	var resources: Array[Item] = []
	for item in items.get_children():
		if item.item != null:
			resources.append(item.item)
	return resources

func add_option(item) -> int:
	if item.is_upgradable():
		var option_slot = OptionSlot.instantiate()
		option_slot.item = item
		add_child(option_slot)
		return 1
	return 0

#func get_available_weapons():
	#var weapon_resource = []
	#for weapon in weapons.get_children():
		#if weapon.weapon != null:
			#weapon_resource.append(weapon.weapon)
	#return weapon_resource

# Cole esta versão corrigida da função show_option no seu script.
# O resto do seu código não precisa mudar.

func show_option():
	# --- INÍCIO DAS MUDANÇAS ---

	# 1. Primeiro, pegamos TODOS os itens que o jogador possui. Esta será nossa lista de "itens a ignorar".
	var owned_items = get_available_resource_in(weapons)
	owned_items.append_array(get_available_resource_in(passive_items))

	# Se o jogador não tem nenhum item, não há o que mostrar. (Mantido do seu código original)
	if owned_items.size() == 0:
		return
	
	for slot in get_children():
		slot.queue_free()
		
	# 2. A lista 'available' agora começa com os upgrades dos itens que já temos.
	#    Sua função get_equipped_item() já faz isso corretamente.
	var available = get_equipped_item()

	# 3. Agora, usamos a lista 'owned_items' para filtrar e adicionar APENAS itens novos.
	if slot_available(weapons):
		# Em vez de get_equipped_item(), passamos a lista completa 'owned_items' como flag.
		available.append_array(get_upgradable(every_weapon, owned_items))
	if slot_available(passive_items):
		# O mesmo aqui.
		available.append_array(get_upgradable(every_passive, owned_items))
	
	# --- FIM DAS MUDANÇAS ---

	# O resto da função continua exatamente como você escreveu.
	available.shuffle()
	var option_size = 0
	var chance = randf()
	var modifier : int = 1 if (chance < (1.0 - (1.0/owner.luck))) else 0
	
	# Um pequeno ajuste para evitar erro se 'available' tiver menos itens que o solicitado.
	var options_to_show_count = min(3 + modifier, available.size())

	for i in range(options_to_show_count):
		if available.size() > 0:
			option_size += add_option(available.pop_front())
	
	if option_size == 0:
		close_option() # Apenas fecha a tela se nenhuma opção foi realmente adicionada
		return
	
	show()
	particles.show()
	panel.show()
	get_tree().paused = true

func dir_contents(path):
	var dir = DirAccess.open(path)
	var item_resources = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var item_resource : Item = load(path + file_name)
			item_resources.append(item_resource)
			file_name = dir.get_next()
	else:
		return null
	return item_resources

func get_all_item():
	var item_resources = dir_contents(weapon_path)
	every_weapon = item_resources
 
	item_resources = dir_contents(passive_item_path)
	every_passive = item_resources
 
	every_item = every_weapon.duplicate()
	every_item.append_array(every_passive)

func slot_available(items):
	for item in items.get_children():
		if item.item == null:
			return true
	return false


func get_upgradable(items, flag = []):
	var array = []
	for item in items:
		if item.is_upgradable() and item not in flag:
			array.append(item)
	return array

func get_equipped_item():
	var equipped_items = get_available_resource_in(weapons)
	equipped_items.append_array(get_available_resource_in(passive_items))
 
	return get_upgradable(equipped_items)

func add_weapon(item):
	for slot in weapons.get_children():
		if slot.item == null:
			slot.item = item
			return

func add_passive(item):
	for slot in passive_items.get_children():
		if slot.item == null:
			slot.item = item
			slot.item.player_ref = get_parent().get_parent()

			return


func check_item(item):
	if item in get_available_resource_in(weapons) or item in get_available_resource_in(passive_items):
		return
	else:
		if item is Weapon:
			add_weapon(item)
		elif item is PassiveItem:
			add_passive(item)

func get_available_upgrades()-> Array[Item]:
	var upgrades : Array[Item] = []
	for weapon : Weapon in get_available_resource_in(weapons):
		if weapon.is_upgradable():
			upgrades.append(weapon)
 
		if weapon.max_level_reached() and weapon.item_needed in get_available_resource_in(passive_items):
			upgrades.append(weapon)
 
	for passive_item : PassiveItem in get_available_resource_in(passive_items):
		if passive_item.is_upgradable():
			upgrades.append(passive_item)
 
	return upgrades



func reset_inventory():
	# 1. Limpa todos os slots de armas.
	#    Iteramos por cada slot no HBoxContainer e definimos seu item como nulo.
	for slot in weapons.get_children():
		slot.item = null # O seu sistema parece usar essa propriedade para gerenciar o slot.

	# 2. Limpa todos os slots de itens passivos.
	for slot in passive_items.get_children():
		slot.item = null
	
	# 3. Adiciona a lança básica de volta ao inventário.
	#    Vamos reutilizar sua função `add_weapon` para isso.
	var spear_resource = load(SPEAR_RESOURCE_PATH)
	
	if spear_resource:
		# A sua função 'check_item' ou 'add_weapon' já deve cuidar do resto.
		# Vamos usar check_item, que parece ser a mais completa.
		check_item(spear_resource)
