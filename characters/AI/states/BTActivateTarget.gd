extends BTTask
class_name BTActivateTarget
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var min_times = {
	"toilet": 4.0,
	"shower": 10.0,
}

var needs_decrease = {
	"UseToilet1": [
		{
			"need": "Toilet1",
			"decrease": 0.01,
			"utility": "toilet1"
		}
	],
	"UseToilet2": [
		{
			"need": "Toilet1",
			"decrease": 0.01,
			"utility": "toilet1"
		},
		{
			"need": "Toilet2",
			"decrease": 0.01,
			"utility": "toilet2"
		}
	]
}
func init(obj):
	if !awareness.targets.has(obj):
		return
	if awareness.distance(obj, awareness.targets[obj]) > 1.5:
		return
	awareness.at[obj]["parameters/playback"].travel("Stand")
#	if awareness.targets[obj].is_in_group("toilet"):
#		awareness.action_cooldown[obj] = 10.0 + randf() * 30.0
#	else:
#		awareness.action_cooldown[obj] = 1.0 + randf() * 5.0


func run(obj, delta):
	if !awareness.targets.has(obj):
		return BT_ERROR
	if awareness.distance(obj, awareness.targets[obj]) > 1.5:
		return BT_ERROR
	# Switching animation only we already standing
	var current = awareness.at[obj]["parameters/playback"].get_current_node()
	if current == "Stand":
		if awareness.distance(obj, awareness.targets[obj]) > 0.4 && awareness.distance(obj, awareness.targets[obj]) <= 1.5:
			obj.global_transform = obj.global_transform.interpolate_with(awareness.targets[obj].global_transform, delta)
			obj.global_transform.basis = awareness.targets[obj].global_transform.basis
			obj.orientation.basis = awareness.targets[obj].global_transform.basis
		elif awareness.distance(obj, awareness.targets[obj]) <= 0.4:
			obj.global_transform = awareness.targets[obj].global_transform
			obj.orientation.basis = awareness.targets[obj].global_transform.basis
			if awareness.targets[obj].is_in_group("toilet"):
				awareness.targets[obj].get_parent().busy = true
				if awareness.get_utility(obj, "toilet2") > awareness.get_utility(obj, "toilet1"):
					awareness.at[obj]["parameters/playback"].travel("UseToilet2")
				else:
					awareness.at[obj]["parameters/playback"].travel("UseToilet1")
			print(obj.name, " activate")
		elif awareness.distance(obj, awareness.targets[obj]) > 1.5:
			print(obj.name, " too far to activate")
			return BT_ERROR
	return BT_BUSY
#	else:
#		print("current = ", current)
#		return BT_BUSY

	# We might need to stand still for some time
	if awareness.action_cooldown.has(obj):
		if awareness.action_cooldown[obj] > 0.0:
			awareness.action_cooldown[obj] -= delta
			return BT_BUSY
	# If animation is already playing, decrease the need
	if current in ["UseToilet1", "UseToilet2", "UseShower"]:
		obj.global_transform = obj.global_transform.interpolate_with(awareness.targets[obj].global_transform, delta)
		var decreased = false
		if needs_decrease.has(current):
			for h in needs_decrease[current]:
				if awareness.get_utility(obj, h.utility) > 1:
					awareness.needs[obj][h.need] -= h.decrease * delta
					if awareness.needs[obj][h.need] < 0.0:
						awareness.needs[obj][h.need] = 0.0
					decreased = true
		if decreased:
			for h in needs_decrease[current]:
				print(obj.name, " ", current, ": ", "need: ", h.need, ": ", awareness.needs[obj][h.need])
		else:
			print("not decreased anything")
		if !decreased && current in ["UseToilet1", "UseToilet2", "UseShower"]:
			awareness.at[obj]["parameters/playback"].travel("Stand")
			awareness.targets[obj].get_parent().busy = false
			print("Finished activating target")
			return BT_OK
	return BT_BUSY

func exit(obj, status):
	if status == BT_OK:
		print(obj.name, " ", name, " activated")
		awareness.targets.erase(obj)
		awareness.current_path.erase(obj)
