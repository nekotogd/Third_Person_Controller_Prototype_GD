extends Spatial

const LOOP = preload("res://player/chain_physics/ChainLoop.tscn")
const LINK = preload("res://player/chain_physics/ChainLink.tscn")

export(int) var loops := 8
export(float) var separation : float = 0.03

func _ready():
	var parent = $Anchor
	for i in range(loops):
		var child = add_loop(parent)
		add_link(parent, child)
		parent = child

func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		var body : RigidBody = get_child(loops - 1)
		body.apply_central_impulse(Vector3.LEFT * 3.0)

func add_loop(parent : Spatial):
	var l = LOOP.instance()
	l.transform.origin = parent.transform.origin
	l.transform.origin.y -= separation
	add_child(l)
	return l

func add_link(parent : Spatial, child):
	var pin : PinJoint = LINK.instance()
	pin.set_node_a(parent.get_path())
	pin.set_node_b(child.get_path())
	parent.add_child(pin)
