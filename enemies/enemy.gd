extends KinematicBody

# stats
var curHp : int = 3
var maxHp : int = 3

# attacking
var damage : int = 1
var attackDist : float = 1.5
var attackRate : float = 1.0

# physics
var moveSpeed : float = 2.5

var velocity = Vector3.ZERO

var vertical_velocity = 0

# components
onready var timer = get_node("Timer")
onready var player = get_node("../../Player_Body")

func _ready ():
	# set the timer wait time
	timer.wait_time = attackRate
	timer.start()

# called 60 times a second
func _physics_process (delta):
	# get the distance from us to the player
	var dist = translation.distance_to(player.translation)
	
	# if we're outside of the attack distance, chase after the player
	if dist > attackDist:
		# calculate the direction between us and the player
		var dir = (player.translation - translation).normalized()
		
		velocity.x = dir.x
		velocity.y = 0
		velocity.z = dir.z
		
		# move towards the player
		velocity = move_and_slide(velocity, Vector3.UP)

# called every "attackRate" seconds
func _on_Timer_timeout():
	# if we're within the attack distance - attack the player
	if translation.distance_to(player.translation) <= attackDist:
		player.take_damage(damage)

# called when the player deals damage to us
func take_damage (damageToTake):
	curHp -= damageToTake
	
	# if our health reaches 0 - die
	if curHp <= 0:
		die()

# called when our health reaches 0
func die ():
	# destroy the node
	queue_free()
