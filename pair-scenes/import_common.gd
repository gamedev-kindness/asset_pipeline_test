tool
extends Node
class_name ImporterCommon
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

static func get_action_name(name: String):
	if name.find("_") < 0:
		return name
	return name.split("_")[0].capitalize()

static func get_anim_node_name(name: String):
	if name.find("_") < 0:
		return name
	var data = name.split("_")
	if data[1] == "oneshot":
		return data[1] + "_" + data[2]
	return name.split("_")[1].to_lower()

static func sm_has_state(sm: AnimationNodeStateMachine, state: String) -> bool:
	var props = sm.get_property_list()
	for k in props:
		if k.name == "states/" + state + "/node":
			return true
	return false

