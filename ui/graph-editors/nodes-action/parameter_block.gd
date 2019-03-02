extends GraphNode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var parent_tree
var xform: Transform
var conditions = {}
var control_node
func closed():
	if parent_tree != null:
		parent_tree.pblocks.erase(self)
	control_node.parameter_blocks.erase(self)
	queue_free()

func connect_tree(tnode):
	parent_tree = tnode
	var title_data = $g/LineEdit.text
	if title_data.length() == 0:
		title_data = parent_tree.title
	var set_title = false
	while set_title == false:
		set_title = true
		for k in parent_tree.pblocks:
			if title_data == k.title:
				title_data += "@"
				set_title = false
				break
	$g/LineEdit.text = title_data
	title = title_data
	print("tree data: ", parent_tree.get_data())
	var sep = HSeparator.new()
	add_child(sep)
	for c in parent_tree.get_data().conditions:
		var checkbox = CheckBox.new()
		checkbox.text = c
		add_child(checkbox)
		conditions[c] = checkbox
				
func disconnect_tree():
	parent_tree = null

func _ready():
	connect("close_request", self, "closed")
	xform = Transform()
	var rot = Quat(xform.basis)
	var data = rot.get_euler()
	$g/t/x.text = str(rad2deg(xform.origin.x))
	$g/t/y.text = str(rad2deg(xform.origin.y))
	$g/t/z.text = str(rad2deg(xform.origin.z))
	$g/r/x.text = str(data.x)
	$g/r/y.text = str(data.y)
	$g/r/z.text = str(data.z)
	$g/t/x.connect("text_changed", self, "translation_text_changed", ["x"])
	$g/t/y.connect("text_changed", self, "translation_text_changed", ["y"])
	$g/t/z.connect("text_changed", self, "translation_text_changed", ["z"])
	$g/r/x.connect("text_changed", self, "rotation_text_changed", ["x"])
	$g/r/y.connect("text_changed", self, "rotation_text_changed", ["y"])
	$g/r/z.connect("text_changed", self, "rotation_text_changed", ["z"])


func title_text_changed(new_text):
	title = new_text


func translation_text_changed(new_text, coord):
	match(coord):
		"x":
			xform.origin.x = float(new_text)
		"y":
			xform.origin.y = float(new_text)
		"z":
			xform.origin.z = float(new_text)
	print(xform)
	print(xform.basis)
	print(xform.basis.x)
	print(xform.basis.y)
	print(xform.basis.z)
	print(xform_to_str(xform))
func rotation_text_changed(new_text, coord):
	var rot = Quat(xform.basis)
	var data = rot.get_euler()
	match(coord):
		"x":
			data.x = deg2rad(float(new_text))
		"y":
			data.y = deg2rad(float(new_text))
		"z":
			data.z = deg2rad(float(new_text))
	rot.set_euler(data)
	var basis = Transform(rot).basis
	xform.basis = basis
	print(xform)
	print(xform_to_str(xform))
func xform_to_str(xf: Transform):
	var data = []
	for v in range(4):
		for h in range(3):
			data.push_back(str(xf[v][h]))
	return PoolStringArray(data).join(" ")
func str_to_xform(s: String) -> Transform:
	var data = s.split(" ")
	var xf = Transform()
	for v in range(4):
		for h in range(3):
			xf[v][h] = float(data[v * 3 + h])
	return xf			
	

func get_data():
	var data = {}
	data.xform = xform_to_str(xform)
	data.title = title
	data.master_moves = $g/master_moves.pressed
	var cond = {}
	for k in conditions.keys():
		cond[k] = conditions[k].pressed
	data.conditions = cond
	return data
func set_data(data: Dictionary) -> void:
	xform = str_to_xform(data.xform)
	title = data.title
	$g/LineEdit.text = data.title
	$g/master_moves.pressed = data.master_moves
	var rot = Quat(xform.basis)
	var vdata = rot.get_euler()
	$g/t/x.text = str(xform.origin.x)
	$g/t/y.text = str(xform.origin.y)
	$g/t/z.text = str(xform.origin.z)
	$g/r/x.text = str(rad2deg(vdata.x))
	$g/r/y.text = str(rad2deg(vdata.y))
	$g/r/z.text = str(rad2deg(vdata.z))
	for k in data.conditions.keys():
		if conditions.has(k):
			conditions[k].pressed = data.conditions[k]
	update()
