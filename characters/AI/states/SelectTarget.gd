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
var toilet_score = 1000.0
var shower_score = 10.0

var utilities = {
	"toilet1": {
		"score": 1000.0,
		"need": "Toilet1",
		"tag": "toilet"
	},
	"toilet2": {
		"score": 1000.0,
		"need": "Toilet2",
		"tag": "toilet"
	},
	"shower": {
		"score": 10.0,
		"need": "Shower",
		"tag": "shower"
	}
}

func get_utility(obj, un):
	if awareness.needs.has(obj):
		return utilities[un].score * awareness.needs[obj][utilities[un].need]
	else:
		return 0.0

func init(obj):
	print("Entering " + name)
	var sc = -1001.0
	var target
	for k in utilities.keys():
		if get_utility(obj, k) > sc:
			sc = get_utility(obj, k)
			target = utilities[k].tag
	var dist = 1000000.0
	var target_node = get_closest_target(obj, target)
	var path_t = awareness.build_path_to_obj(obj, target_node)
	if path_t.size() == 0:
		var tnodes = tree().get_nodes_in_group(target)
		target_node = tnodes[randi() % tnodes.size()]
		path_t = awareness.build_path_to_obj(obj, target_node)
	var path = []
	for k in path_t:
		path.push_back(k)
	path.push_back(target_node.global_transform.origin)
	awareness.targets[obj] = target_node
	awareness.current_path[obj] = path
	print("path: ", path)
	awareness.action_cooldown[obj] = 1.0 + randf() * 10.0
	awareness.at[obj].travel("Stand")
			

func check_target_valid(obj):
	if !awareness.targets.has(obj):
		return false
	var tgt = awareness.targets[obj]
	if tgt.is_in_group("toilet") && tgt.get_parent().busy:
		return false
	return true
func get_closest_target(obj, target):
	var dist = 1000000.0
	var target_node
	for n in tree().get_nodes_in_group(target):
		var ndist = awareness.distance(obj, n)
		if n.is_in_group("toilet") && n.get_parent().busy:
			continue
		if ndist < dist:
			dist = ndist
			target_node = n
	return target_node
func run(obj, delta):
	if awareness.action_cooldown.has(obj):
		if awareness.action_cooldown[obj] > 0.0:
			awareness.action_cooldown[obj] -= delta
			return ""
	if awareness.current_path[obj].size() == 0 || !check_target_valid(obj):
		var target
		for k in utilities.keys():
			var sc = -1001.0
			if get_utility(obj, k) > sc:
				sc = get_utility(obj, k)
				target = utilities[k].tag
		var target_node = get_closest_target(obj, target)
		var path_t = awareness.build_path_to_obj(obj, target_node)
		var path = []
		for k in path_t:
			path.push_back(k)
		path.push_back(target_node.global_transform.origin)
		awareness.current_path[obj] = path
		awareness.targets[obj] = target_node
	if awareness.at[obj].get_current_node() == "Stand":
		if awareness.day_hour > 23.0 && awareness.day_hour < 5:
			if randf() > 0.95:
				obj.get_node("main_shape").disabled = true
				return "Sleeping"
		if check_target_valid(obj):
			return "GoToTarget"
		return ""
	return ""

func exit(obj):
	print("Exiting " + name)
