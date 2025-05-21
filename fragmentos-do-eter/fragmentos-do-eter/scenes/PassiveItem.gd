extends Item
class_name PassiveItem

@export var upgrades: Array[Stats]
var player_ref
var passiveslot

func is_upgradable() -> bool:
	if level <= upgrades.size():
		return true
	return false

func upgrade_item():
	if not is_upgradable():
		return
	if player_ref == null:
		return
	var upgrade = upgrades[level - 1]
	player_ref.max_health += upgrade.max_health
	player_ref.recovery += upgrade.recovery
	player_ref.armor += upgrade.armor
	player_ref.mov_speed += upgrade.mov_speed
	player_ref.might += upgrade.might
	player_ref.area += upgrade.area
	player_ref.magnet += upgrade.magnet
	player_ref.growth += upgrade.growth
	player_ref.luck += upgrade.luck
	level += 1
