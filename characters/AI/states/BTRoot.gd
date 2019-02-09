extends Node
class_name BTRoot
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _execute(obj, delta):
	if !awareness.ai_state.has(obj):
		awareness.ai_state[obj] = {"nodes": {}, "last_open": []}
	for h in get_children():
		h._execute(obj, delta)
	var open_nodes = awareness.ai_state[obj].keys()
	var last_open_nodes = awareness.ai_state[obj].last_open
	for k in last_open_nodes:
		if !k in open_nodes:
			k._close(obj)
	awareness.ai_state[obj].last_open = open_nodes
