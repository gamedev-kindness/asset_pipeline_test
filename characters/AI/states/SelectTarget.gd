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
func init(obj):
	print("Entering " + name)
	var sc = -1001.0
	var target
	for k in awareness.utilities.keys():
		print(k, ": ", sc)
		if awareness.get_utility(obj, k) > sc && get_closest_target(obj, awareness.utilities[k].tag) != null:
			sc = awareness.get_utility(obj, k)
			target = awareness.utilities[k].tag
			print(k, ": ", sc)
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
		# Add logic if we want to forcefully free the target
		if n.is_in_group("toilet") && n.get_parent().busy:
			continue
		if n.is_in_group("characters"):
			# Check traits here
			if n == obj:
				continue
			if awareness.gender.has(n) && awareness.gender.has(obj):
				if awareness.gender[n] == awareness.gender[obj]:
					continue
#		if n.is_in_group("shower") && n.get_parent().busy:
#			continue
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
		var target_node
		var sc = 100
		awareness.targets[obj] = null
		awareness.current_path[obj] = []
		for k in awareness.utilities.keys():
			print(k, ": ", sc)
			if awareness.get_utility(obj, k) > sc && get_closest_target(obj, awareness.utilities[k].tag) != null:
				sc = awareness.get_utility(obj, k)
				target = awareness.utilities[k].tag
				target_node = get_closest_target(obj, target)
				print(k, ": ", sc)
		if target_node != null:
			var path_t = awareness.build_path_to_obj(obj, target_node)
			var path = []
			for k in path_t:
				path.push_back(k)
			path.push_back(target_node.global_transform.origin)
			awareness.current_path[obj] = path
			awareness.targets[obj] = target_node
		else:
			return ""
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
