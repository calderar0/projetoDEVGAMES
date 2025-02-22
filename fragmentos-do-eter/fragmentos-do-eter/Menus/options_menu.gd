extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_h_slider_3_mouse_exited() -> void:
	pass # Replace with function body.


func _on_ok_pressed() -> void:
	AudioServer.set_bus_volume_db(0,linear_to_db($AudioOptions/VBoxContainer/HSlider.value))
	AudioServer.set_bus_volume_db(1,linear_to_db($AudioOptions/VBoxContainer/HSlider2.value))
	AudioServer.set_bus_volume_db(2,linear_to_db($AudioOptions/VBoxContainer/HSlider3.value))
