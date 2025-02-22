extends Pickups
class_name Gold

@export var gold : int = 5

func activate():
	super.activate()
	player_ref.gain_gold(gold)
