extends Control

onready var healthBar = get_node("HealthBar")
onready var raText = get_node("RaText")

# called when we take damage
func update_health_bar (curHp, maxHp):
	healthBar.value = (100 / maxHp) * curHp

# called when our gold changes
func update_gold_text (ra):
	raText.text = "x " + str(ra)
	$AnimationPlayer.play("drop")
	$gem_timer.start()

func _on_gem_timer_timeout():
	$AnimationPlayer.play_backwards("drop")
