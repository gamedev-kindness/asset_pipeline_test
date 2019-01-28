extends AIState

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
	awareness.at[obj].travel("Stand")
	if awareness.targets[obj].is_in_group("toilet"):
		awareness.targets[obj].get_parent().busy = true
		awareness.action_cooldown[obj] = 10.0 + randf() * 30.0
	else:
		awareness.action_cooldown[obj] = 1.0 + randf() * 5.0


func run(obj, delta):
	if awareness.at[obj].get_current_node() == "Stand":
		if awareness.distance(obj, awareness.targets[obj]) > 0.4:
			obj.global_transform = obj.global_transform.interpolate_with(awareness.targets[obj].global_transform, delta)
			obj.global_transform.basis = awareness.targets[obj].global_transform.basis
			obj.orientation.basis = awareness.targets[obj].global_transform.basis
		else:
			obj.global_transform = awareness.targets[obj].global_transform
			if awareness.targets[obj].is_in_group("toilet"):
				if awareness.get_utility(obj, "toilet2") > awareness.get_utility(obj, "toilet1"):
					awareness.at[obj].travel("UseToilet2")
				else:
					awareness.at[obj].travel("UseToilet1")

	if awareness.action_cooldown.has(obj):
		if awareness.action_cooldown[obj] > 0.0:
			awareness.action_cooldown[obj] -= delta
			return ""

	if awareness.at[obj].get_current_node() in ["UseToilet1", "UseToilet2", "UseShower"]:
		obj.global_transform = obj.global_transform.interpolate_with(awareness.targets[obj].global_transform, delta)
		var decreased = false
		if needs_decrease.has(awareness.at[obj].get_current_node()):
			for h in needs_decrease[awareness.at[obj].get_current_node()]:
				if awareness.get_utility(obj, h.utility) > 1:
					awareness.needs[obj][h.need] -= h.decrease * delta
					if awareness.needs[obj][h.need] < 0.0:
						awareness.needs[obj][h.need] = 0.0
					decreased = true
		if decreased:
			for h in needs_decrease[awareness.at[obj].get_current_node()]:
				print("need: ", h.need, ": ", awareness.needs[obj][h.need])
		if !decreased && awareness.at[obj].get_current_node() in ["UseToilet1", "UseToilet2", "UseShower"]:
			awareness.at[obj].travel("Stand")
			awareness.targets[obj].get_parent().busy = false
			return "SelectTarget"
	return ""

func exit(obj):
	pass
