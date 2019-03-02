extends GraphNode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var state_data = {}
var slot_count = 2
var noffset = Vector2()
var child_nodes = []
var control_node
func closed():
	for k in child_nodes:
		k.queue_free()
	child_nodes.clear()
	control_node.action_nodes.erase(self)
	queue_free()
func _ready():
	connect("close_request", self, "closed")
	noffset = get_offset() + Vector2(300, 0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
var complete = false
#func _process(delta):
#	pass
func add_data_block(dname: String, dparent: String, item: Dictionary, level: int) -> void:
	var block = load("res://ui/graph-editors/nodes-action/action_tree_item.tscn")
	var blocki = block.instance()
	blocki.name = "tree_item_" + dname
	get_parent().add_child(blocki)
	blocki.set_offset(noffset)
	noffset += Vector2(0, 200)
	child_nodes.push_back(blocki)
	blocki.set_title(item.fullname.replace("@", "/"))
	blocki.set_data(item)
	if dparent.length() > 0:
		var parent_node = get_parent().get_node("tree_item_" + dparent)
		if parent_node != null:
			var con_count = parent_node.get_connection_output_count()
			print("num outputs: ", con_count)
			for c in range(con_count):
				print("output type: ", parent_node.get_connection_output_type(c), " ", parent_node.name)
				if parent_node.get_connection_output_type(c) == 3:
					print("connect from: ", c)
					print("num inputs: ", blocki.get_connection_input_count(), " ", blocki.name)
					for d in range(blocki.get_connection_input_count()):
						print("input type: ", blocki.get_connection_input_type(d))
						if blocki.get_connection_input_type(d) == 3:
							print("connect to: ", d)
							get_parent().connect_node(parent_node.name, c, blocki.name, d)
	else:
		get_parent().connect_node(name, 0, blocki.name, 0)
	
#	var sep = HSeparator.new()
#	add_child(sep)
#	child_nodes.push_back(sep)
#	slot_count += 1
#	var l2 = Label.new()
#	for m in range(level):
#		l2.text += " "
#	l2.text += "parameters"
#	add_child(l2)
#	child_nodes.push_back(l2)
#	set_slot(slot_count, true, 2, Color(1, 0, 1, 1), false, 0, Color(1.0, 1.0, 1.0, 1.0))
#	slot_count += 1
		
	
func update_view():
	if !complete:
		for k in child_nodes:
			k.queue_free()
		child_nodes.clear()
	else:
		for h in state_data.keys():
			var d = state_data[h]
			var l = Label.new()
			l.text = d.path
			add_child(l)
			child_nodes.push_back(l)
			slot_count += 1
		state_data[0].level = 0
		state_data[0].parent = ""
		var children_queue = [state_data[0]]
		while children_queue.size() > 0:
			var item = children_queue[0]
			children_queue.pop_front()
			var l = Label.new()
			if item.level == 0:
				l.text += item.name
				add_child(l)
				child_nodes.push_back(l)
				set_slot(slot_count, false, 0, Color(1, 1, 1, 1), true, 3, Color(0.0, 0.86, 1.0, 1.0))
				slot_count += 1
			add_data_block(item.name, item.parent, item, item.level)
			for c in item.children_data.keys():
				var chld = item.children_data[c]
				chld.name = c
				chld.level = item.level + 1
				chld.parent = item.name
				children_queue.push_back(chld)
			

func connect_state(from, data, to):
	data.name = from
	state_data[to] = data
	if state_data.has(0) && state_data.has(1):
		complete = true
		update_view()
	print(state_data)
	noffset = get_offset() + Vector2(400, 0)
func disconnect_state(from, to):
	state_data.erase(to)
	if !state_data.has(0) || !state_data.has(1):
		complete = false
		update_view()
	print(state_data)

func can_connect_state(from, to):
	if state_data.has(to):
		return false
	return true
