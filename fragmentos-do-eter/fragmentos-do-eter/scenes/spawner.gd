extends Node2D

@export var player: CharacterBody2D
@export var enemy: PackedScene
@export var destructible: PackedScene
@export var area_anti_spawn: Area2D
@export var current_phase_path: String = "res://resources/Enemies/Phase1/"
var boss_spawned: bool = false


var distance: float = 900
var can_spawn: bool = true
var actual_phase: int = 1

@export var enemy_type: Array[Enemy]

func _ready():
	actual_phase = 1
	load_enemies_from_phase(current_phase_path)
	

func load_enemies_from_phase(path: String) -> void:
	print("Carregando inimigos de:", path)
	enemy_type.clear()
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var full_path = path + "/" + file_name
				var enemy_data = load(full_path)
				if enemy_data:  # Aqui é um recurso, não uma cena
					enemy_type.append(enemy_data)
					print("Carregado:", file_name)
			file_name = dir.get_next()
		dir.list_dir_end()



func change_phase():
	if actual_phase <= 4:
		actual_phase += 1
		current_phase_path = "res://resources/Enemies/Phase%d" % actual_phase
		load_enemies_from_phase(current_phase_path)


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

func _physics_process(_delta):
	if player.health <= 0:
		can_spawn = false
		return
	if get_tree().get_node_count_in_group("Enemy") < 300:
		can_spawn = true
	else:
		can_spawn = false

func  spawner(pos: Vector2, elite: bool = false, boss: bool = false):
	if player.health <= 0:
		return
	if not can_spawn and not elite and not boss:
		return
	else:
		if boss_spawned:
			return  # se o boss estiver vivo, não spawnar inimigos normais
		if not can_spawn and not elite:
			return
	if enemy_type.is_empty():
		print("enemy_type está vazio!") # DEBUG
		return
		
	var enemy_inst = enemy.instantiate()
	enemy_inst.type = enemy_type[minute % enemy_type.size()]

	enemy_inst.position = pos

	enemy_inst.player_ref = player
	enemy_inst.elite = elite
	enemy_inst.boss = boss
	
	if boss:
			boss_spawned = true
			enemy_inst.connect("tree_exited", Callable(self, "_on_boss_defeated"))
	get_tree().current_scene.add_child(enemy_inst)

func _on_boss_defeated():
	boss_spawned = false
	change_phase()



func get_rand_pos() -> Vector2:
	var pos: Vector2
	while true:
		pos = player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
		if is_position_valid(pos):
			break
	return pos

	
func amount(number: int = 1):
	var actual_number = min(number, 5) # Isso limitará o máximo a 5 inimigos por vez
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


func _on_destructible_timeout() -> void:
	spawn_destructible(get_rand_pos())
	
	
func spawn_destructible(pos):
	var object_instance = destructible.instantiate()
	object_instance.position = pos 
	get_tree().current_scene.add_child(object_instance)


func _on_boss_timeout() -> void:
	spawner(get_rand_pos(), false, true)

func is_position_valid(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true  # Importante para detectar a Area2D
	var result = space_state.intersect_point(query)
	
	for item in result:
		if item.collider == area_anti_spawn:
			return false  # A posição está dentro da área proibida
	
	return true  # A posição é válida


	
