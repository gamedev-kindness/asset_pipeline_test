extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
onready var startpos: Vector3 = $the_bus.global_transform.origin

func add_spawner(node):
	var p1 = node.global_transform.origin
	for k in get_tree().get_nodes_in_group("spawn"):
		var p2 = k.global_transform.origin
		if p1.distance_to(p2) < 0.5:
			return
	var pos = $the_bus.global_transform.xform_inv(p1)
	var pos_left = pos + Vector3(-0.17, -0.20, -0.28)
	var pos_right = pos + Vector3(0.23, -0.20, -0.28)
	var spawn1 : = SpawnPoint.new()
	spawn1.loadable = true
	spawn1.player = false
	spawn1.parented = true
	spawn1.vehicle = true
	spawn1.top_state = "Sitting"
	$the_bus.add_child(spawn1)
	spawn1.translation = pos_left
	var spawn2 : = SpawnPoint.new()
	spawn2.loadable = true
	spawn2.player = false
	spawn2.parented = true
	spawn2.vehicle = true
	spawn2.top_state = "Sitting"
	$the_bus.add_child(spawn2)
	spawn2.translation = pos_right
	
		
func recursive_seats():
	var queue = [self]
	while queue.size() > 0:
		var item = queue[0]
		queue.pop_front()
		if item.name.find("passenger_seat") >= 0:
			add_spawner(item)
		for c in item.get_children():
			queue.push_back(c)
func _ready():
	recursive_seats()
	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
	print("Initial state: ", awareness.at.keys().size())
#	for k in get_tree().get_nodes_in_group("spawn"):
#		k.emit_signal("spawn")
	charman.main_scene = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var v = $the_bus.linear_velocity
	if $the_bus.global_transform.origin.length() > 100:
		$the_bus.global_transform.origin = startpos
		$the_bus.linear_velocity = v
#	print("vel: ", v)
#	print("pos: ", $the_bus.global_transform.origin)
		
