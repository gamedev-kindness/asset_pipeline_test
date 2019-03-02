extends GraphNode

var _data = {}
var pblocks = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_title(text):
	title = text
	$title.text = text

func set_data(data):
	_data = data

func get_data():
	_data.title = title
	return _data

func connect_pblock(pbnode):
	print(name, ": attached: ", pbnode.name)
	pblocks.push_back(pbnode)
func disconnect_pblock(pbnode):
	print(name, ": deattached: ", pbnode.name)
	pblocks.erase(pbnode)
