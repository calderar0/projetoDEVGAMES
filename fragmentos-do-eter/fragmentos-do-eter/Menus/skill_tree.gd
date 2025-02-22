extends Panel

var skill_tree = []
var total_stat  : Stats

func _ready():
	load_skill_tree()  # 🔹 Certifica-se de carregar as habilidades ao iniciar

func set_skill_tree():
	skill_tree.clear()  # 🔹 Limpa a árvore antes de recriar
	for each_branch in get_children():
		var branch = []
		for upgrade in each_branch.get_children():
			branch.append(upgrade.enabled)
		skill_tree.append(branch)
	
	Savedata.skill_tree = skill_tree
	Savedata.set_and_save()

func load_skill_tree():
	if Savedata.skill_tree.is_empty():  # 🔹 Usa is_empty() para verificar se está vazia
		set_skill_tree()  # 🔹 Se não existir, cria uma nova skill tree
	
	skill_tree = Savedata.skill_tree
	for branch in get_children():
		var branch_index = branch.get_index()
		if branch_index >= skill_tree.size():
			continue  # 🔹 Evita erro se o índice for maior que o tamanho da lista
		
		for upgrade in branch.get_children():
			var upgrade_index = upgrade.get_index()
			if upgrade_index < skill_tree[branch_index].size():
				upgrade.enabled = skill_tree[branch_index][upgrade_index]
		get_total_stats() 

func add_stats(stat):
	total_stat.max_health += stat.max_health
	total_stat.recovery += stat.recovery
	total_stat.armor += stat.armor
	total_stat.mov_speed += stat.mov_speed
	total_stat.might += stat.might
	total_stat.area += stat.area
	total_stat.magnet += stat.magnet
	total_stat.growth += stat.growth


func get_total_stats():
	total_stat = Stats.new()
	for branch in get_children():
		for upgrade in branch.get_children():
			if upgrade.enabled:
				add_stats(upgrade.skill.stats)
	Persistence.bonus_stats = total_stat
	
	
