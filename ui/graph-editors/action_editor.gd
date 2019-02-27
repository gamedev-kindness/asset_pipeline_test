extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var state_deps = {}
var last_offset = Vector2()
onready var ge: GraphEdit = $HBoxContainer/GraphEdit
func add_graph_node(node_name):
	var an = load("res://ui/graph-editors/nodes-action/root.tscn")
	var ani = an.instance()
	ge.add_child(ani)
	var new_offset = last_offset + Vector2(randf() * 100.0, randf() * 100.0)
	ani.set_offset(new_offset)
	last_offset = new_offset
func on_connection_request(from, from_slot, to, to_slot):
	print("connect: ", from, " ", from_slot, " ", to, " ", to_slot)
	ge.connect_node(from, from_slot, to, to_slot)
func on_disconnection_request(from, from_slot, to, to_slot):
	print("disconnect")
	ge.disconnect_node(from, from_slot, to, to_slot)
func _ready():
	$HBoxContainer/VBoxContainer/Button.connect("pressed", self, "add_graph_node", ["action"])
	ge.connect("connection_request", self, "on_connection_request")
	ge.connect("disconnection_request", self, "on_disconnection_request")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
