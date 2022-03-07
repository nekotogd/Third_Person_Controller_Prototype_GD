extends Spatial

var camrot_h = 0
var camrot_v = 0

var cam_v_max = 60
var cam_v_min = -50

var rotation_sensitivity = 0.1
var rotation_acceleration = 20

var yaw = 0
var pitch = 0

const JOY_SENSITIVITY = 4.5

func _input(event):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x * rotation_sensitivity
		camrot_v += event.relative.y * rotation_sensitivity

func _process(delta):
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)

	$camRot.rotation_degrees.y = lerp($camRot.rotation_degrees.y, camrot_h, delta * rotation_acceleration)
	$camRot.rotation_degrees.x = lerp($camRot.rotation_degrees.x, camrot_v, delta * rotation_acceleration)

