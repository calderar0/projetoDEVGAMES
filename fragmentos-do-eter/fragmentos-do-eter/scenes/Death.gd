extends Pickups
class_name Death

func activate():
	super.activate()
	player_ref.get_tree().call_group("Enemy","die_from_screen_wipe")
