extends Control

var json = {}
const data_path = "res://characters/actions/actions.json"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
#var state_deps = {}
var last_offset = Vector2()
var state_nodes = []
var action_nodes = []
var parameter_blocks = []
onready var ge: GraphEdit = $HBoxContainer/GraphEdit
func display_development():
	var sc = load("res://ui/development_menu.tscn")
	get_tree().change_scene_to(sc)

func add_graph_node(node_name):
	pass
func vec2_to_str(v: Vector2) -> String:
	return str(v.x) + " " + str(v.y)
func str_to_vec2(s: String) -> Vector2:
	var ret : = Vector2()
	var sd = s.split(" ")
	ret.x = float(sd[0])
	ret.y = float(sd[1])
	return ret
func add_param_block_node():
	var an = load("res://ui/graph-editors/nodes-action/parameter_block.tscn")
	var ani = an.instance()
	ge.add_child(ani)
	var new_offset = last_offset + Vector2(randf() * 250.0, randf() * 250.0)
	ani.set_offset(new_offset)
	last_offset = new_offset
	parameter_blocks.push_back(ani)
	ani.control_node = self
	
func add_action2_node():
	var an = load("res://ui/graph-editors/nodes-action/action2.tscn")
	var ani = an.instance()
	ge.add_child(ani)
	var new_offset = last_offset + Vector2(randf() * 250.0, randf() * 250.0)
	ani.set_offset(new_offset)
	last_offset = new_offset
	action_nodes.push_back(ani)
	ani.control_node = self

func add_state_node(node_name, data):
	var an = load("res://ui/graph-editors/nodes-action/state.tscn")
	var ani = an.instance()
	ge.add_child(ani)
	var new_offset: Vector2 = last_offset + Vector2(randf() * 250.0, randf() * 250.0)
	if json.states[node_name].has("position"):
		new_offset = str_to_vec2(json.states[node_name].position)
	ani.set_offset(new_offset)
	last_offset = new_offset
	ani.name = node_name
	ani.set_action_name(node_name)
	ani.data = data
	state_nodes.push_back(ani)

func save_json():
	for k in state_nodes:
		json.states[k.name].position = vec2_to_str(k.get_offset())
	if !json.has("actions"):
		json.actions = {}
	for k in action_nodes:
		if !k.complete:
			continue
		var action_name = k.state_data[0].name
		json.actions[action_name] = {
			"main": k.state_data[0].name,
			"secondary": k.state_data[1].name,
			"position": vec2_to_str(k.get_offset())
		}
	if !json.has("parameters"):
		json.parameters = {}
	for k in parameter_blocks:
		if k.parent_tree == null:
			continue
		var param_name = k.title
		json.parameters[param_name] = k.get_data()
		json.parameters[param_name].tree = k.parent_tree.title
		json.parameters[param_name].position = vec2_to_str(k.get_offset())
	var f : = File.new()
	f.open(data_path, f.WRITE)
	f.store_string(JSON.print(json, "\t", true))
	f.close()

func on_connection_request(from, from_slot, to, to_slot):
	print("connect: ", from, " ", from_slot, " ", to, " ", to_slot)
	var to_node = ge.get_node(to)
	var from_node = ge.get_node(from)
	if to_node.get_connection_input_type(to_slot) == 1:
		if to_node.has_method("can_connect_state"):
			if !to_node.can_connect_state(from, to_slot):
				return
		if to_node.has_method("connect_state"):
			to_node.connect_state(from, ge.get_node(from).data, to_slot)
	elif to_node.get_connection_input_type(to_slot) == 2:
		print("attaching parameters")
		if to_node.has_method("connect_pblock"):
			to_node.connect_pblock(from_node)
		if from_node.has_method("connect_tree"):
			from_node.connect_tree(to_node)
	if to_node.get_connection_input_type(to_slot) != 3:
		ge.connect_node(from, from_slot, to, to_slot)

func on_disconnection_request(from, from_slot, to, to_slot):
	print("disconnect")
	var to_node = ge.get_node(to)
	var from_node = ge.get_node(from)
	if to_node.get_connection_input_type(to_slot) == 1:
		if to_node.has_method("disconnect_state"):
			to_node.disconnect_state(from, to_slot)
	elif to_node.get_connection_input_type(to_slot) == 2:
		print("detaching parameters")
		if to_node.has_method("disconnect_pblock"):
			to_node.disconnect_pblock(ge.get_node(from))
		if from_node.has_method("disconnect_tree"):
			from_node.disconnect_tree()
	if to_node.get_connection_input_type(to_slot) != 3:
		ge.disconnect_node(from, from_slot, to, to_slot)

func _ready():
	$HBoxContainer/VBoxContainer/AddAction2.connect("pressed", self, "add_action2_node")
	$HBoxContainer/VBoxContainer/AddParameters.connect("pressed", self, "add_param_block_node")
	$HBoxContainer/VBoxContainer/Save.connect("pressed", self, "save_json")
	$HBoxContainer/VBoxContainer/Exit.connect("pressed", self, "display_development")
	ge.connect("connection_request", self, "on_connection_request")
	ge.connect("disconnection_request", self, "on_disconnection_request")
	var jf = File.new()
	jf.open(data_path, File.READ)
	var json_req = JSON.parse(jf.get_as_text())
	json = json_req.result
	for k in json.states.keys():
		add_state_node(k, json.states[k])
	for k in json.actions.keys():
		add_action2_node()
		var anode = action_nodes[action_nodes.size() - 1]
		if json.actions[k].has("position"):
			anode.set_offset(str_to_vec2(json.actions[k].position))
		ge.emit_signal("connection_request", json.actions[k].main, 0, anode.name, 0)
		ge.emit_signal("connection_request", json.actions[k].secondary, 0, anode.name, 1)
	for k in json.parameters.keys():
		add_param_block_node()
		var pnode = parameter_blocks[parameter_blocks.size() - 1]
		if json.parameters[k].has("position"):
			pnode.set_offset(str_to_vec2(json.parameters[k].position))
		var to
		for j in ge.get_children():
			var ok = false
			var n: GraphNode
			if !j is GraphNode:
				continue
			n = j
			if n.title == json.parameters[k].tree:
				for m in range(n.get_connection_input_count()):
					if n.get_connection_input_type(m) == 2:
						ge.emit_signal("connection_request", pnode.name, 0, n.name, m)
						ok = true
						break
			if ok:
				break
		pnode.set_data(json.parameters[k])
