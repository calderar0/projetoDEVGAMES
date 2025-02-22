extends Weapon
class_name SingleShot

func shoot(source, target, scene_tree):
	if target == null or scene_tree.paused == true:
		return
	
	SoundManager.play_sfx(sound)
	var projectile = projeto_node.instantiate()
	projectile.position = source.position
	projectile.damage = damage
	projectile.speed = speed
	projectile.source = source
	projectile.direcao = (target.position - source.position).normalized()
	projectile.rotation = projectile.direcao.angle()
	projectile.find_child("Sprite2D").texture = texture
	projectile.find_child("Sprite2D").scale.x = escala
	projectile.find_child("Sprite2D").scale.y = escala
	projectile.find_child("Sprite2D").hframes = horframe
	projectile.find_child("Sprite2D").vframes = verframe
	
	scene_tree.current_scene.add_child(projectile)
	
	
func activate(source, target, scene_tree):
	shoot(source,target,scene_tree)
	
func upgrade_item():
	if max_level_reached():
		slot.item = evolution
		return
	if not is_upgradable():
		return
	
	var upgrade = upgrades[level - 1]
	
	damage += upgrade.damage
	cooldown += upgrade.cooldown
	speed += upgrade.speed
	
	level += 1
