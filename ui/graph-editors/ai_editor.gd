extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const data_path = "res://ui/graph-editors/ai-nodes.json"
const ai_path = "res://characters/AI/states/"
# Called when the node enters the scene tree for the first time.
var json = {}
var nodes = {
	"BTRoot": {
		"node": load("res://ui/graph-editors/nodes-action/tree_root.tscn"),
		"inputs": 0,
		"outputs": 1
	},
	"BTSelector": {
		"node": load("res://ui/graph-editors/nodes-action/selector.tscn"),
		"inputs": 1,
		"outputs": -1,
	},
	"BTSequence": {
		"node": load("res://ui/graph-editors/nodes-action/sequence.tscn"),
		"inputs": 1,
		"outputs": -1,
	},
	"BTUtilitySelector": {
		"node": load("res://ui/graph-editors/nodes-action/utility_selector.tscn"),
		"inputs": 1,
		"outputs": -1,
	},
	"BTCondCanSpeak": {
		"node": load("res://ui/graph-editors/nodes-action/conditional.tscn"),
		"inputs": 1,
		"outputs": 1,
	},
	"BTCondHasTarget": {
		"node": load("res://ui/graph-editors/nodes-action/conditional.tscn"),
		"inputs": 1,
		"outputs": 1,
	},
	"BTTargetDistanceLessCheck": {
		"node": load("res://ui/graph-editors/nodes-action/conditional.tscn"),
		"inputs": 1,
		"outputs": 1,
	},
# Leaf nodes
	"BTActivateTarget": {
		"node": load("res://ui/graph-editors/nodes-action/leaf.tscn"),
		"inputs": 1,
		"outputs": 0,
	},
	"BTInitiateDialogue": {
		"node": load("res://ui/graph-editors/nodes-action/leaf.tscn"),
		"inputs": 1,
		"outputs": 0,
	},
	"BTWalkToTarget": {
		"node": load("res://ui/graph-editors/nodes-action/leaf.tscn"),
		"inputs": 1,
		"outputs": 0,
	},
	"BTPlayAnimationState": {
		"node": load("res://ui/graph-editors/nodes-action/leaf.tscn"),
		"inputs": 1,
		"outputs": 0,
	},
	"BTSelectTarget": {
		"node": load("res://ui/graph-editors/nodes-action/leaf.tscn"),
		"inputs": 1,
		"outputs": 0,
	},
	"BTSelectCharacterTarget": {
		"node": load("res://ui/graph-editors/nodes-action/leaf.tscn"),
		"inputs": 1,
		"outputs": 0,
	}
}
onready var ge: GraphEdit = $GraphEdit
func add_tree_node(node):
	var nodei = nodes[node].node.instance()
	nodei.title = node
	ge.add_child(nodei)
	if nodei.has_method("add_parameter"):
		for k in nodes[node].parameters.keys():
			nodei.add_parameter(k, nodes[node].parameters[k])

func on_connection_request(from, from_slot, to, to_slot):
	print("connect: ", from, " ", from_slot, " ", to, " ", to_slot)
	var from_node = ge.get_node(from)
	var to_node = ge.get_node(to)
	var can_connect = true
	if from_node.has_method("get_max_children_count"):
		nodes[from_node.title].outputs = from_node.get_max_children_count()
	if to_node.parent_node != null:
		print("already have connection to parent")
		can_connect = false
	if nodes[to_node.title].inputs == 0:
		print("can't connect parent to this node")
		can_connect = false
	if nodes[from_node.title].outputs >= 0:
		if from_node.children_nodes.size() >= nodes[from_node.title].outputs:
			print("too many children")
			can_connect = false
	if can_connect:
		if from_node.has_method("connect_child"):
			if !from_node.connect_child(from_slot, to_node):
				print("node connection was prohibited")
				can_connect = false
	if can_connect:
		ge.connect_node(from, from_slot, to, to_slot)
		to_node.parent_node = from_node
		from_node.children_nodes.push_back(to_node)
func on_disconnection_request(from, from_slot, to, to_slot):
	print("disconnect: ", from, " ", from_slot, " ", to, " ", to_slot)
	var from_node = ge.get_node(from)
	var to_node = ge.get_node(to)
	if from_node.has_method("disconnect_child"):
		from_node.disconnect_child(from_slot, to_node)
	to_node.parent_node = null
	from_node.children_nodes.erase(to_node)
	ge.disconnect_node(from, from_slot, to, to_slot)

func _ready():
	var jf = File.new()
	jf.open(data_path, File.READ)
	var json_req = JSON.parse(jf.get_as_text())
	json = json_req.result
	jf.close()
	print(json)
	for k in json.modules.keys():
		var p = Label.new()
		p.text = k
		$v.add_child(p)
		for l in json.modules[k].keys():
			var b = Button.new()
			b.text = l
			$v.add_child(b)
			b.connect("pressed", self, "add_tree_node", [l])
			var load_path = ai_path + l + ".gd"
			print(load_path)
			var script:GDScript = load(load_path)
			var instance = script.new()
			nodes[l].parameters = {}
			for k in instance.get_property_list():
				if (k.usage & PROPERTY_USAGE_EDITOR) != 0 && k.hint == 0:
#					print(k.name, " ", k.type, " ", "%04x" % (k.usage))
#					print(k)
#					print(instance.get(k.name))
					nodes[l].parameters[k.name] = instance.get(k.name)
			instance.free()
	print(nodes)
	ge.connect("connection_request", self, "on_connection_request")
	ge.connect("disconnection_request", self, "on_disconnection_request")
