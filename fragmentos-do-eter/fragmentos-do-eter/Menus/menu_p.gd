extends Control

func _ready():
	%musicaMenu.playing = true
	menu()


func _on_play_pressed() -> void:
	#%musicaMenu.playing = false
	#get_tree().change_scene_to_file("res://scenes/test_scene.tscn")
	load_phases()
	$Menu.hide()
	$Fases.show()

func load_phases():
	if Savedata.fase == 1:
		return
	elif Savedata.fase <= 2:
		$"Fases/TextureRect/Fase2/Fase 2".visible = true
		$Fases/TextureRect/Fase2.color = Color("#00000000")
	elif Savedata.fase <= 3:
		$"Fases/TextureRect/Fase2/Fase 2".visible = true
		$Fases/TextureRect/Fase2.color = Color("#00000000")
		$"Fases/TextureRect/Fase 3/Fase 3".visible = true
		$"Fases/TextureRect/Fase 3".color = Color("#00000000")
	elif Savedata.fase <= 4:
		$"Fases/TextureRect/Fase2/Fase 2".visible = true
		$Fases/TextureRect/Fase2.color = Color("#00000000")
		$"Fases/TextureRect/Fase 3/Fase 3".visible = true
		$"Fases/TextureRect/Fase 3".color = Color("#00000000")
		$"Fases/TextureRect/Fase 4/Fase 4".visible = true
		$"Fases/TextureRect/Fase 4".color = Color("#00000000")
	elif Savedata.fase <= 5:
		$"Fases/TextureRect/Fase2/Fase 2".visible = true
		$Fases/TextureRect/Fase2.color = Color("#00000000")
		$"Fases/TextureRect/Fase 3/Fase 3".visible = true
		$"Fases/TextureRect/Fase 3".color = Color("#00000000")
		$"Fases/TextureRect/Fase 4/Fase 4".visible = true
		$"Fases/TextureRect/Fase 4".color = Color("#00000000")
		$"Fases/TextureRect/Fase 5/Fase 5".visible = true
		$"Fases/TextureRect/Fase 5".color = Color("#00000000")


func _on_back_pressed() -> void:
	menu()



func _on_abilities_pressed() -> void:
	skill_tree()
	
	


func _on_album_pressed() -> void:
	bestiary()
	
	


func _on_créditos_pressed() -> void:
	$Menu.hide()
	$Close.show()
	$Config.show()
	$fundo.show()
	%OptionsMenu.hide()
	$Credits.show()
	
	$Bestiary.hide()
	$SkillTree.hide()
	
	$Back.show()
	
	var pedra = get_node("Menu/pedra") 
	for child in pedra.get_children():
		child.hide()  
	
	var meteoro = get_node("Menu/Meteoro") 
	for child in meteoro.get_children():
		child.hide()  
	
	
func menu():
	$Menu.show()
	$Close.show()
	$Config.show()
	$fundo.show()
	%OptionsMenu.hide()
	$Credits.hide()
	$Fases.hide()
	$Bestiary.hide()
	$SkillTree.hide()
	
	$Back.hide()
	
	var pedra = get_node("Menu/pedra") 
	for child in pedra.get_children():
		child.show()  
	
	var meteoro = get_node("Menu/Meteoro") 
	for child in meteoro.get_children():
		child.show()  
		
func skill_tree():
	$Menu.hide()
	$Close.show()
	$Config.show()
	$fundo.show()
	%OptionsMenu.hide()
	$Credits.hide()
	
	$Bestiary.hide()
	$SkillTree.show()
	
	$Back.show()
	
	var pedra = get_node("Menu/pedra") 
	for child in pedra.get_children():
		child.hide()  
	
	var meteoro = get_node("Menu/Meteoro") 
	for child in meteoro.get_children():
		child.hide() 
		
	tween_pop($SkillTree)
		
func bestiary():
	$Menu.hide()
	$Close.show()
	$Config.show()
	$fundo.show()
	%OptionsMenu.hide()
	$Credits.hide()
	
	$Bestiary.show()
	$SkillTree.hide()

	$Back.show()
	
	var pedra = get_node("Menu/pedra") 
	for child in pedra.get_children():
		child.hide()  
	
	var meteoro = get_node("Menu/Meteoro") 
	for child in meteoro.get_children():
		child.hide() 
	tween_pop($Bestiary)
	

func tween_pop(panel):
	SoundManager.play_sfx(load("res://assets/sfx/382232__kevinpro__book-flop.mp3"))
	panel.scale = Vector2(0.85,0.85)
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(panel, "scale",Vector2(1,1),0.5)
	

	
	
	



func _on_config_pressed() -> void:
	$Menu.hide()
	$Close.show()
	$Config.show()
	$fundo.show()
	%OptionsMenu.show()
	$Credits.hide()
	
	$Bestiary.hide()
	$SkillTree.hide()

	$Back.show()
	
	var pedra = get_node("Menu/pedra") 
	for child in pedra.get_children():
		child.hide()  
	
	var meteoro = get_node("Menu/Meteoro") 
	for child in meteoro.get_children():
		child.hide() 
	tween_pop($Bestiary)
	


func _on_fase_1_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/test_scene.tscn")
	#get_tree().get_child(testscene)
	LevelManager.proximo_level_path = "res://scenes/mundo_1.tscn"
	LevelManager.proximo_level_numero = 1
	get_tree().change_scene_to_file("res://scenes/game_main.tscn")


func _on_fase_2_pressed() -> void:
	LevelManager.proximo_level_path = "res://scenes/mundo_2.tscn"
	LevelManager.proximo_level_numero = 2
	get_tree().change_scene_to_file("res://scenes/game_main.tscn")


func _on_fase_3_pressed() -> void:
	LevelManager.proximo_level_path = "res://scenes/mundo_3.tscn"
	LevelManager.proximo_level_numero = 3
	get_tree().change_scene_to_file("res://scenes/game_main.tscn")


func _on_fase_4_pressed() -> void:
	LevelManager.proximo_level_path = "res://scenes/mundo_4.tscn"
	LevelManager.proximo_level_numero = 4
	get_tree().change_scene_to_file("res://scenes/game_main.tscn")


func _on_fase_5_pressed() -> void:
	LevelManager.proximo_level_path = "res://scenes/mundo_5.tscn"
	LevelManager.proximo_level_numero = 5
	get_tree().change_scene_to_file("res://scenes/game_main.tscn")
