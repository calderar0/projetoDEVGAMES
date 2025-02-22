extends Label

func _process(_delta):
	text = "Gold : " + str(Savedata.gold)
