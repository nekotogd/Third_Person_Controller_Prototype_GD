extends Spatial

const LOOP = preload("res://player/chain_physics/ChainLoop.tscn")
const LINK = preload("res://player/chain_physics/ChainLink.tscn")

export(float) var separation : float = 0.045
export(int) var start_bone_idx : int = 3
export(int) var end_bone_idx : int = 11

var loops : int = 1 # Changed at runtime automatically

onready var skeleton = get_parent()

func _ready():
	loops = end_bone_idx - start_bone_idx
	
	var parent = $Anchor
	for i in range(loops):
		var child = add_loop(parent)
		add_link(parent, child)
		parent = child
	
	set_physics_process(false)
	call_deferred("set_physics_process", true)

func _physics_process(_delta):
	if not (get_child_count() >= loops + 1):
		return
	
	# Set bone transforms
	for i in range(start_bone_idx, end_bone_idx + 1):
		var node_idx : int = i - start_bone_idx
		var node_name = "ChainLoop" + str(node_idx)
		
		if node_idx == 0:
			continue
		elif node_idx == 1:
			node_name = "ChainLoop"
		
		var body : RigidBody = get_node(node_name)
		
		var global_t : Transform = body.global_transform
		var world_pos : Vector3 = global_t.origin
		var sk_local : Vector3 = skeleton.to_local(world_pos)
		var t : Transform = global_t
		t.origin = sk_local
		skeleton.set_bone_global_pose_override(i, t, 1.0)

func add_loop(parent : Spatial):
	var l = LOOP.instance()
	l.transform.origin = parent.transform.origin
	l.transform.origin.y -= separation
	add_child(l, true)
	l.visible = false
	return l

func add_link(parent : Spatial, child):
	var pin : PinJoint = LINK.instance()
	pin.set_node_a(parent.get_path())
	pin.set_node_b(child.get_path())
	parent.add_child(pin, true)
