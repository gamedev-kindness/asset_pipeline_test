extends GraphNode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var icon: Image
var icon_path : = ""
var file_dialog
var control_node
var parent: Node
var param_block = "None"
var direction = "ANY"
func closed():
	control_node.opportunity_nodes.erase(self)
	queue_free()

func open_image(path):
	icon_path = path
	icon = Image.new()
	icon.load(path)
	file_dialog.queue_free()
	var tex = ImageTexture.new()
	tex.create_from_image(icon)
	$TextureRect.texture = tex
func update_title(new_text):
	title = new_text

func open_file_dialog():
	var fd = load("res://ui/graph-editors/nodes-action/select_icon.tscn")
	var fdi = fd.instance()
	get_node("/root").add_child(fdi)
	file_dialog = fdi
	fdi.connect("file_selected", self, "open_image")
	fdi.popup()

func update_items():
	$ItemList.clear()
	$ItemList.add_item("None")
	for k in control_node.json.parameters.keys():
		$ItemList.add_item(k, null, true)
	for k in range($ItemList.get_item_count()):
		if param_block == $ItemList.get_item_text(k):
			$ItemList.select(k, true)
	for k in range($GridContainer/directions.get_item_count()):
		if direction == $GridContainer/directions.get_item_text(k):
			$GridContainer/directions.select(k, true)
func select_pblock(id):
	param_block = $ItemList.get_item_text(id)

func select_direction(id):
	direction = $GridContainer/directions.get_item_text(id)

func _ready():
	$file_button.connect("pressed", self, "open_file_dialog")
	connect("close_request", self, "closed")
	connect("raise_request", self, "update_items")
	$GridContainer/LineEdit.connect("text_changed", self, "update_title")
	update_items()
	$ItemList.connect("item_selected", self, "select_pblock")
	$GridContainer/directions.connect("item_selected", self, "select_direction")

func get_data():
	var data = {}
	data.title = title
	data.icon_path = icon_path
	data.param_block = param_block
	data.direction = direction
	if parent != null:
		data.parent = parent.title
	else:
		data.parent = ""
	return data
func set_data(data):
	title = data.title
	$GridContainer/LineEdit.text = data.title
	icon_path = data.icon_path
	icon = Image.new()
	icon.load(data.icon_path)
	var tex = ImageTexture.new()
	tex.create_from_image(icon)
	$TextureRect.texture = tex
	param_block = data.param_block
	direction = data.direction
	update_items()
