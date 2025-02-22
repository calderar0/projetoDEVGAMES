extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().paused == true and owner.health <= 0 and visible == false:
		visible = true


func _on_pressed() -> void:
	get_tree().paused = false
	Savedata.gold += owner.gold
	Savedata.set_and_save()
	get_tree().change_scene_to_file("res://Menus/menuP.tscn")
