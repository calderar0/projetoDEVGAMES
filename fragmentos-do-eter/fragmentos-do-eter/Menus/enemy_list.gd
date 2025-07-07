extends VBoxContainer

var path = "res://resources/Enemies/"

var enemies = []

func _ready():
	dir_contents()

func dir_contents():
	for i in range(1,7):
		path = "res://resources/Enemies/Phase%d/" % i
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					file_name = dir.get_next()
					continue  # pula pastas

				if file_name.ends_with(".tres") or file_name.ends_with(".res"):
					var enemy_resource : Enemy = load(path + file_name)
					if enemy_resource:
						enemies.append(enemy_resource)

						var button = Button.new()
						button.pressed.connect(_on_pressed.bind(button))
						button.text = enemy_resource.title
						add_child(button)
				file_name = dir.get_next()


func _on_pressed(button : Button):
	var index = button.get_index()
	%Name.text = "Name : " + enemies[index].title
	%About.text = "About : " + str(enemies[index].about)
	%Texture.texture = enemies[index].icon
	SoundManager.play_sfx(load("res://assets/sfx/Piano_Ui (2).wav"))
