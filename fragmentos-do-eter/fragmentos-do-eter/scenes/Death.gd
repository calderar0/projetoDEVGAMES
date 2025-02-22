extends Pickups
class_name Death

func activate():
	super.activate()
	player_ref.get_tree().call_group("Enemy","drop_item")
