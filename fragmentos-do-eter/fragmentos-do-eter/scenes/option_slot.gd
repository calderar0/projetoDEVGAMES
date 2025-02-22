extends TextureButton


@export var item : Item:
	set(value):
		item = value
		if value.upgrades.size() > 0 and value.upgrades.size() + 1 != value.level:
			texture_normal = value.icon
			$Label.text = "Lvl " + str(item.level)
			$Description.text = value.upgrades[value.level - 1].description
		else:
			texture_normal = value.evolution.icon
			$Label.text = ""
			$Description.text = "EVOLUTION"
			

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and item:
		get_parent().check_item(item)
		item.upgrade_item()
		get_parent().close_option()
