extends Node
class_name BTBase

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum {BT_OK, BT_ERROR, BT_BUSY}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_state(obj):
	return awareness.ai_state[obj].nodes[self]
func _open(obj):
#	print("open on ", get_name(), "obj ", obj.get_name())
	awareness.ai_state[obj].nodes[self] = {}
	init(obj)
func _close(obj):
	exit(obj)
#	print("close on ", get_name(), "obj ", obj.get_name())
	awareness.ai_state[obj].nodes.erase(self)
func init(obj):
	pass

func run(obj, delta):
	pass

func exit(obj):
	pass

func _execute(obj, delta):
	if !awareness.ai_state[obj].nodes.has(self):
		_open(obj)
	var status = run(obj, delta)
	if status != BT_BUSY:
		_close(obj)
	return status