extends Control


var json = {}
const data_path = "res://characters/actions/actions.json"
var last_offset = Vector2()
onready var ge: GraphEdit = $h/ge

var opportunity_nodes = []

func display_development():
	var sc = load("res://ui/development_menu.tscn")
	get_tree().change_scene_to(sc)


func vec2_to_str(v: Vector2) -> String:
	return str(v.x) + " " + str(v.y)
func str_to_vec2(s: String) -> Vector2:
	var ret : = Vector2()
	var sd = s.split(" ")
	ret.x = float(sd[0])
	ret.y = float(sd[1])
	return ret

func add_opportunity_node():
	var an = load("res://ui/graph-editors/nodes-action/opportunity.tscn")
	var ani = an.instance()
	ani.control_node = self
	ge.add_child(ani)
	var new_offset: Vector2 = last_offset + Vector2(randf() * 250.0, randf() * 250.0)
	ani.set_offset(new_offset)
	last_offset = new_offset
	opportunity_nodes.push_back(ani)
func save_json():
	json.opportunity = {}
	for k in opportunity_nodes:
		if k.title.length() == 0:
			continue
		var opportunity_name = k.title
		json.opportunity[opportunity_name] = k.get_data()
		json.opportunity[opportunity_name].position = vec2_to_str(k.get_offset())
	var f : = File.new()
	f.open(data_path, f.WRITE)
	f.store_string(JSON.print(json, "\t", true))
	f.close()
func on_connection_request(from, from_slot, to, to_slot):
	print("connect")
	var to_node = ge.get_node(to)
	var from_node = ge.get_node(from)
	ge.connect_node(from, from_slot, to, to_slot)
	from_node.parent = to_node

func on_disconnection_request(from, from_slot, to, to_slot):
	print("disconnect")
	var to_node = ge.get_node(to)
	var from_node = ge.get_node(from)
	ge.disconnect_node(from, from_slot, to, to_slot)
	from_node.parent = ""

func _ready():
	$h/v/AddOpportunity.connect("pressed", self, "add_opportunity_node")
	$h/v/Save.connect("pressed", self, "save_json")
	$h/v/Exit.connect("pressed", self, "display_development")

	ge.connect("connection_request", self, "on_connection_request")
	ge.connect("disconnection_request", self, "on_disconnection_request")
	var jf = File.new()
	jf.open(data_path, File.READ)
	var json_req = JSON.parse(jf.get_as_text())
	json = json_req.result
	if !json.has("opportunity"):
		json.opportunity = {}
	for k in json.opportunity.keys():
		add_opportunity_node()
		var pnode = opportunity_nodes[opportunity_nodes.size() - 1]
		if json.opportunity[k].has("position"):
			pnode.set_offset(str_to_vec2(json.opportunity[k].position))
		var to
		for j in ge.get_children():
			var ok = false
			var n: GraphNode
			if !j is GraphNode:
				continue
			n = j
			if n.title == json.opportunity[k].parent:
				for m in range(n.get_connection_input_count()):
					if n.get_connection_input_type(m) == 4:
						ge.emit_signal("connection_request", pnode.name, 0, n.name, m)
						ok = true
						break
			if ok:
				break
		pnode.set_data(json.opportunity[k])
