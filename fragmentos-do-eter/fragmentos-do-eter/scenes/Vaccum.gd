extends Pickups
class_name PickupMagnet

func activate():
	super.activate()
	player_ref.get_tree().call_group("Pickups","follow", player_ref,true)
