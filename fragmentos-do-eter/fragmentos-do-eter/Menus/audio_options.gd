extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$VBoxContainer/HSlider2.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$VBoxContainer/HSlider3.value = db_to_linear(AudioServer.get_bus_volume_db(2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_h_slider_3_mouse_exited() -> void:
	release_focus()


func _on_h_slider_2_mouse_exited() -> void:
	release_focus()



func _on_h_slider_mouse_exited() -> void:
	release_focus()
