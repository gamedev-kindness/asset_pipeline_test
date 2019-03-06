extends GraphNode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var parent_node
var children_nodes = []
var slots = {}
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func on_close_request():
	if parent_node != null:
		parent_node.children_nodes.erase(self)
	for k in children_nodes:
		k.parent_node = null
	queue_free()

var slot = 2
var con = 0
var max_children_count = 0
func _ready():
	connect("close_request", self, "on_close_request")
	for k in awareness.utilities.keys():
		if awareness.utilities[k].has("behavior"):
			var l = Label.new()
			l.text = k
			add_child(l)
			set_slot(slot, false, 0, Color(1, 1, 1, 1), true, 0, Color(1, 1, 1, 1))
			slots[con] = {"name": k, "node": null}
			slot += 1
			con += 1
			max_children_count += 1
func get_max_children_count():
	return max_children_count
func connect_child(slot_, ch):
	if slots[slot_].node == null:
		slots[slot_].node = ch
		return true
	else:
		return false
func disconnect_child(slot, ch):
	if slots[slot].node == ch:
		slots[slot].node = null
		return true
	else:
		return false
