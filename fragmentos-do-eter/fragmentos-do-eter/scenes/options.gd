extends VBoxContainer

@export var weapons: HBoxContainer
@export var passive_items: HBoxContainer
var OptionSlot = preload("res://scenes/option_slot.tscn")

@export var particles: GPUParticles2D
@export var panel: NinePatchRect

const weapon_path: String = "res://resources/Weapons/"
const passive_item_path: String = "res://resources/PassiveItems/"

var every_item
var every_weapon
var every_passive


func _ready() -> void:
	hide()
	particles.hide()
	panel.hide()
	get_all_item()

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

func show_option():
	var weapons_available = get_available_resource_in(weapons)
	var passive_item_available = get_available_resource_in(passive_items)
	if weapons_available.size() == 0 and passive_item_available.size() == 0:
		return
	
	for slot in get_children():
		slot.queue_free()
		
	var available = get_equipped_item()
	if slot_available(weapons):
		available.append_array(get_upgradable(every_weapon, get_equipped_item()))
	if slot_available(passive_items):
		available.append_array(get_upgradable(every_passive, get_equipped_item()))
	available.shuffle()
	var option_size = 0
	var chance = randf()
	var modifier : int = 1 if (chance < (1.0 - (1.0/owner.luck))) else 0
	for i in range(3 + modifier):
		if available.size() > 0:
			option_size += add_option(available.pop_front())
	#for weapon in weapons_available:
		#option_size += add_option(weapon)
		#
		#if weapon.max_level_reached() and weapon.item_needed in passive_item_available:
			#var option_slot = OptionSlot.instantiate()
			#option_slot.item = weapon
			#add_child(option_slot)
			#option_size +=1
	#
	#for passive_items in passive_item_available:
		#option_size += add_option(passive_items)
	
	if option_size == 0:
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
			print("Found file: " + file_name)
			var item_resource : Item = load(path + file_name)
			item_resources.append(item_resource)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
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
