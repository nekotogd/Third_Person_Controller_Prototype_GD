extends Area

export var raToGive : int = 1
	
# called when a body enters the coin collider
func _on_ra_body_entered(body):
	# is this the player? If so give them gold
	if body.name == "Player_Body":
		body.give_gold(raToGive)
		queue_free()

