extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var act2class = {
	"GrabFromBack": ActionGrabFromBack,
	"KickToBed": ActionKickToBed,
	"FrontGrab": ActionFrontGrab,
	"FrontGrabFaceSlap": ActionFrontGrabFaceSlap,
	"Missionary1": ActionMissionary1
}

func add_action(action, obj, other):
	if other == null:
		other = awareness.get_actuator_body(obj, "characters")
	if other == null:
		print("other is null")
	if action in act2class.keys():
		if other == null:
			return
		var act = act2class[action].new()
		var root = get_node("/root")
		root.add_child(act)
		act.add_character(obj)
		act.add_character(other)
		awareness.action_mode[obj] = act
		awareness.action_mode[other] = act
	elif action == "Talk":
		if other != null:
			awareness.initiate_dialogue(obj, other)
	elif action == "LeaveAction":
		if awareness.action_mode.has(obj):
			var act = awareness.action_mode[obj]
			act.remove_character(obj)
	elif action == "Class":
		var classes = get_tree().get_nodes_in_group("classroom")
		if classes.size() > 0:
			var which = classes[randi() % classes.size()]
			var to = which.global_transform.origin
			if awareness.player_character != null:
				awareness.player_character.global_transform.origin = to

	elif action == "PickUpItem":
		var item = awareness.get_actuator_body(obj, "pickup")
		if item != null:
			awareness.character_data[obj].inventory.push_back(item.item_type)
			get_node("/root").remove_child(item)
			item.queue_free()
