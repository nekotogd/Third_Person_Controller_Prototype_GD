extends KinematicBody

#base player stats
export var health = 100

#vectors sort of speak for themselves
var direction = Vector3.BACK
var velocity = Vector3.ZERO

#velocities
var vertical_velocity = 0
var gravity = 26.34
var weight_on_ground = 9

var root_motion = Transform()
var root_vel = Vector3.ZERO

#movement values
export var movement_speed = 0
export var walk_speed = 1.21
export var run_speed = 5.85
export var acceleration = 9.7
export var angular_acceleration = 13

#jump, double jump and dodge values
export var jump_magnitude = 15.63
export var jump_distance = 8
export var double_jump_magnitude = 13.13
export var double_jump_distance = 30
export var jump_num = 0

#t/f variables
export var head_checked = false
export var dodging = false

var floor_just = false
var can_move = true

var run_toggle = true
var running = false

#combat variables
onready var current_weapon = 0
var attack_anim = -1
var canPressAttack = true
var isAttacking = false

#var checks
onready var mesh = $model
onready var anim_tree = $AnimationTree
onready var anim_player = $model/AnimationPlayer
onready var headcheck = $head_check

func check_weapon_states(delta):
	if current_weapon == 1:
		anim_tree.set("parameters/idle_states/blend_amount", lerp(anim_tree.get("parameters/idle_states/blend_amount"), 1, delta * 5))
		anim_tree.set("parameters/walk_states/blend_amount", 1)
		anim_tree.set("parameters/run_states/blend_amount", 1)
	if current_weapon == 0:
		anim_tree.set("parameters/idle_states/blend_amount", lerp(anim_tree.get("parameters/idle_states/blend_amount"), 0, delta * 5))
		anim_tree.set("parameters/walk_states/blend_amount", 0)
		anim_tree.set("parameters/run_states/blend_amount", 0)

func _ready():
	if run_toggle:
		if Input.is_action_pressed("walk_toggle"):
			running = false if running else true
	else:
		running = Input.is_action_pressed("walk_toggle")
	
	init_pausable_animations()

func init_pausable_animations():
	var pausable_anims := [
		"attack_1",
		"attack_2",
		"attack_3",
		"attack_4",
		"attack_5",
		"block_1",
		"land",
		"air_attack_1",
		"air_attack_2",
		"air_attack_3",
		"air_attack_4",
	]
	for anim_name in pausable_anims:
		create_pausable_animation(anim_name)

func _physics_process(delta):

# basic movement script, speaks for itself.
	var rot = $camBase/camRot.global_transform.basis.get_euler().y

# get root_motion for character
	root_motion = anim_tree.get_root_motion_transform()

	if (Input.is_action_pressed("move_forward") ||  Input.is_action_pressed("move_backward") ||  Input.is_action_pressed("move_left") ||  Input.is_action_pressed("move_right")) and can_move:

		direction = Vector3(Input.get_action_strength("move_left") - Input.get_action_strength("move_right"), 0,
			Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))

		direction = direction.rotated(Vector3.UP, rot).normalized()

		if current_weapon == 1:
			$weapon_timer.start()

		if Input.is_action_pressed("walk_toggle"):
			movement_speed = walk_speed
			anim_tree.set("parameters/iwr_blend/blend_amount", lerp(anim_tree.get("parameters/iwr_blend/blend_amount"), 0, delta * acceleration))
		else:
			movement_speed = run_speed
			anim_tree.set("parameters/iwr_blend/blend_amount", lerp(anim_tree.get("parameters/iwr_blend/blend_amount"), 1, delta * acceleration))

	else:
		movement_speed = 0
		anim_tree.set("parameters/iwr_blend/blend_amount", lerp(anim_tree.get("parameters/iwr_blend/blend_amount"), -1, delta * 9))

	velocity = lerp(velocity, direction * movement_speed, delta * acceleration)

	move_and_slide(velocity + Vector3.UP * vertical_velocity - get_floor_normal() * weight_on_ground + root_motion_velocity(delta), Vector3.UP)

# player is in the air
	if !is_on_floor():
		anim_tree.set("parameters/agc_trans/current", 0)
		vertical_velocity -= gravity * delta
		floor_just = false

		if Input.is_action_just_pressed("attack") && attack_anim == -1:
			anim_tree.set("parameters/air_hit1/active", true)
			current_weapon = 1
			$attack1_timer.start()
			$attack_window.start()
			$model/P_EX120outao/Skeleton/BoneAttachment/kingdom_key.visible = true
			$weapon_timer.start()
				
			vertical_velocity = 9
			velocity = direction * 25
			
		if Input.is_action_just_pressed("attack") && attack_anim == 0 && $attack_window.time_left > 0 && $attack1_timer.time_left == 0:
			anim_tree.set("parameters/air_hit2/active", true)
			current_weapon = 1
			$attack2_timer.start()
			$attack_window.start()
			$weapon_timer.start()
			
			vertical_velocity = 9
			velocity = direction * 25
			
		if Input.is_action_just_pressed("attack") && attack_anim == 1 && $attack_window.time_left > 0 && $attack2_timer.time_left == 0:
			anim_tree.set("parameters/air_hit3/active", true)
			current_weapon = 1
			$attack_window.stop()
			$attack3_timer.start()
			$weapon_timer.start()
			
			vertical_velocity = 9
			velocity = direction * 25

# player is on the ground
	else:
		if vertical_velocity < -9:
			if floor_just == false:
				$AnimationTree.set("parameters/land/active",true)
				floor_just = true

		anim_tree.set("parameters/agc_trans/current", 1)
		jump_num = 1
		vertical_velocity = 0

# combat ground code
		if Input.is_action_just_pressed("attack") && attack_anim == -1:
			anim_tree.set("parameters/hit1/active", true)
			current_weapon = 1
			$attack1_timer.start()
			$attack_window.start()
			$model/P_EX120outao/Skeleton/BoneAttachment/kingdom_key.visible = true
			$weapon_timer.start()
			
		if Input.is_action_just_pressed("attack") && attack_anim == 0 && $attack_window.time_left > 0 && $attack1_timer.time_left == 0:
			anim_tree.set("parameters/hit2/active", true)
			current_weapon = 1
			$attack2_timer.start()
			$attack_window.start()
			$weapon_timer.start()
			
		if Input.is_action_just_pressed("attack") && attack_anim == 1 && $attack_window.time_left > 0 && $attack2_timer.time_left == 0:
			anim_tree.set("parameters/hit3/active", true)
			current_weapon = 1
			$attack_window.stop()
			$attack3_timer.start()
			$weapon_timer.start()

		if current_weapon == 1:
			if Input.is_action_just_pressed("block"):
				anim_tree.set("parameters/block/active", true)
				$weapon_timer.start()

# run/sprint blending
	mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)

#jumping and double jumping script
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_move:
		if jump_num == 1:
			$AnimationTree.set("parameters/jump/active", true)
			vertical_velocity = jump_magnitude
			jump_num = 1

	elif Input.is_action_just_pressed("jump") and not is_on_floor() and can_move:
		if jump_num == 1:
			$AnimationTree.set("parameters/djump/active", true)
			vertical_velocity = double_jump_magnitude
			velocity = direction * double_jump_distance
			jump_num = 2

# this is for when the player's head collides with a ceiling, that it pushes the player back down
	if headcheck.is_colliding():
		head_checked = true
		vertical_velocity = -2

# check current weapon
	check_weapon_states(delta)

func root_motion_velocity(delta):
	
	### Root Motion Rotation ###
	var position_matrix = mesh.global_transform
	position_matrix.origin = Vector3.ZERO
	
	position_matrix *= root_motion
	
	### Root Motion Translation ###
	var root_motion_displ = position_matrix.origin / delta
	
	root_vel.x = root_motion_displ.x
	root_vel.z = root_motion_displ.z
	root_vel.y = 0.0
	
	return root_vel

func resume_movement():
	can_move = true

func pause_movement():
	can_move = false

func create_pausable_animation(animation_name : String):
	var anim : Animation = anim_player.get_animation(animation_name)
	var track_idx : int = anim.add_track(anim.TYPE_METHOD)
	var track_path : NodePath = anim_player.get_parent().get_path_to(self)
	
	anim.track_set_path(track_idx, track_path)
	var start_key : Dictionary = {
		"method" : "pause_movement",
		"args" : []
	}
	var end_key : Dictionary = {
		"method" : "resume_movement",
		"args" : []
	}
	anim.track_insert_key(track_idx, 0.0, start_key)
	anim.track_insert_key(track_idx, anim.length - 0.01, end_key)

func _on_weapon_timer_timeout():
	!anim_tree.set("parameters/sheathe_kb/active", true)
	current_weapon = 0
	$model/P_EX120outao/Skeleton/BoneAttachment/kingdom_key.visible = false

func _on_attack_window_timeout():
	attack_anim = -1
	canPressAttack = true
	isAttacking = false

func _on_attack1_timer_timeout():
	attack_anim = 0
	canPressAttack = true
	
func _on_attack2_timer_timeout():
	attack_anim = 1
	canPressAttack = true

func _on_attack3_timer_timeout():
	attack_anim = -1
	canPressAttack = true
	isAttacking = false
