extends Pickups
class_name Chi

@export var XP: float

func activate():
	super.activate()
	prints("+" + str(XP) + "XP")
	player_ref.gain_XP(XP)
