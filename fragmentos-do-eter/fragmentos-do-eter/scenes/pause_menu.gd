extends Control

func _ready():
	hide()
	$AnimationPlayer.play("RESET")

func resume():
	hide()
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("sair") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("sair") and get_tree().paused:
		resume()

func _process(_delta):
	testEsc()


func _on_home_pressed() -> void:
	get_tree().paused = false
	Savedata.add_gold(owner.gold)
	get_tree().change_scene_to_file("res://Menus/menuP.tscn")


func _on_resume_pressed() -> void:
	resume()


func _on_options_pressed() -> void:
	%PauseMenu.hide()
	%OptionsMenu.show()


func _on_return_pressed() -> void:
	%OptionsMenu.hide()
	%PauseMenu.show()
