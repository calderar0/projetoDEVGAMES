extends VBoxContainer

const path = "res://resources/Enemies/"

var enemies = []

func _ready():
	dir_contents()

func dir_contents():
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var enemy_resource : Enemy = load(path + file_name)
			enemies.append(enemy_resource)
 
			var button = Button.new()
			button.pressed.connect(_on_pressed.bind(button))
			button.text = enemy_resource.title
			add_child(button)
 
			file_name = dir.get_next()

func _on_pressed(button : Button):
	var index = button.get_index()
	%Name.text = "Name : " + enemies[index].title
	%Health.text = "Health : " + str(enemies[index].health)
	%Damage.text = "Damage : " + str(enemies[index].damage)
	%About.text = "About : " + str(enemies[index].about)
	%Texture.texture = enemies[index].icon
	SoundManager.play_sfx(load("res://assets/sfx/Piano_Ui (2).wav"))
