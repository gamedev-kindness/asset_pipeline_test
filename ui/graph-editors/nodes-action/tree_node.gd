extends GraphNode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var parent_node
var children_nodes = []
var param_count = 0
var params_grid
var params = {}
var param_nodes = {}
var node_type = ""

func on_close_request():
	if parent_node != null:
		parent_node.children_nodes.erase(self)
	for k in children_nodes:
		k.parent_node = null
	queue_free()

func on_title_modify(new_title):
	title = new_title
	update()

func on_parameter_modify(new_value, param):
	if params[param].type_id == TYPE_STRING:
		params[param].value = new_value
	elif params[param].type_id == TYPE_INT:
		params[param].value = int(new_value)
	elif params[param].type_id == TYPE_REAL:
		params[param].value = float(new_value)
	update()

func _ready():
	connect("close_request", self, "on_close_request")
	$t/LineEdit.text = title
	$t/LineEdit.connect("text_changed", self, "on_title_modify")

func add_parameter(pname, pdefval, type_id):
	if type_id in [TYPE_REAL, TYPE_INT, TYPE_STRING]:
		if param_count == 0:
			var g = GridContainer.new()
			add_child(g)
			g.columns = 2
			g.size_flags_horizontal = SIZE_EXPAND
			params_grid = g
		var g = params_grid
		var l = Label.new()
		l.text = pname
		g.add_child(l)
		l.size_flags_horizontal = SIZE_EXPAND_FILL
		var v = LineEdit.new()
		v.text = str(pdefval)
		g.add_child(v)
		v.size_flags_horizontal = SIZE_EXPAND_FILL
		v.connect("text_changed", self, "on_parameter_modify", [pname])
		param_count += 1
	params[pname] = {"value": pdefval, "type_id": type_id}
func set_parameters(param_data):
	params = param_data.duplicate()
	if params_grid:
		params_grid.queue_free()
	var g = GridContainer.new()
	add_child(g)
	g.columns = 2
	g.size_flags_horizontal = SIZE_EXPAND
	params_grid = g
	param_count = 0
	for k in params.keys():
		var l = Label.new()
		l.text = k
		g.add_child(l)
		l.size_flags_horizontal = SIZE_EXPAND_FILL
		var v = LineEdit.new()
		v.text = str(params[k].value)
		g.add_child(v)
		v.size_flags_horizontal = SIZE_EXPAND_FILL
		v.connect("text_changed", self, "on_parameter_modify", [k])
		param_count += 1
