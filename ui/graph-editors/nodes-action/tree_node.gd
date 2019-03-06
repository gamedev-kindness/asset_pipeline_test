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

func on_close_request():
	if parent_node != null:
		parent_node.children_nodes.erase(self)
	for k in children_nodes:
		k.parent_node = null
	queue_free()

func _ready():
	connect("close_request", self, "on_close_request")

func add_parameter(pname, pdefval):
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
	params[pname] = pdefval
	param_count += 1
