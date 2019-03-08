extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var AI: Node
const data_path = "res://ui/graph-editors/ai-nodes.json"
const ai_path = "res://characters/AI/states/"
var json = {}
func vec2_to_str(v: Vector2) -> String:
	return str(v.x) + " " + str(v.y)

func str_to_vec2(s: String) -> Vector2:
	var ret : = Vector2()
	var sd = s.split(" ")
	ret.x = float(sd[0])
	ret.y = float(sd[1])
	return ret
func sort_children(a, b):
	var a_data = json.tree[a]
	var b_data = json.tree[b]
	var a_position : = str_to_vec2(a_data.position)
	var b_position : = str_to_vec2(b_data.position)
	if a_position.y < b_position.y:
		return true
	return false
func _ready():
	var jf = File.new()
	jf.open(data_path, File.READ)
	var json_req = JSON.parse(jf.get_as_text())
	json = json_req.result
	jf.close()
	var root
	var owner_node
	for k in json.tree.keys():
		var cur_node = json.tree[k]
		if cur_node.node_type == "BTRoot":
			root = k
	var queue = [{"name": root, "parent": self}]
	var current_node
	while queue.size() > 0:
		var item = queue[0]
		queue.pop_front()
		var e = json.tree[item.name]
		var tree_node = load(ai_path + e.node_type + ".gd").new()
		if !owner_node:
			owner_node = tree_node
		tree_node.name = item.name
		if tree_node != owner_node:
			item.parent.add_child(tree_node)
		tree_node.set_owner(owner_node)
		for k in e.params:
			var val = e.params[k]
			var type_id = int(val.type_id)
			var value
			match(type_id):
				TYPE_INT:
					value = int(val.value)
				TYPE_REAL:
					value = float(val.value)
				TYPE_STRING:
					value = str(val.value)
				_:
					print("unknown type ", type_id)
					print("fit types: ", [TYPE_INT, TYPE_REAL, TYPE_STRING])
#			print("setting param: ", k, " to: ", value)
			tree_node.set(k, value)
		var node_children: Array = e.children.duplicate()
		node_children.sort_custom(self, "sort_children")
		for k in node_children:
			queue.push_back({"name": k, "parent": tree_node})
	AI = owner_node
	add_child(AI)
func save_ai(ai_path = "res://characters/AI-tmp.tscn"):
	var packed_scene = PackedScene.new()
	packed_scene.pack(AI)
	ResourceSaver.save(ai_path, packed_scene)
	print("saved")

func run(delta, obj):
	AI._execute(obj, delta)
