extends BTTask
class_name BTSelectCharacterTarget

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
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
	print("num targets: ", target, ": ", get_tree().get_nodes_in_group(target).size())
	
	for n in get_tree().get_nodes_in_group(target):
		var ndist = awareness.distance(obj, n)
		# Add logic if we want to forcefully free the target
		if n == obj:
			continue
		if awareness.gender.has(n) && awareness.gender.has(obj):
			if awareness.gender[n] == awareness.gender[obj]:
				ndist *= 1.5
		if awareness.is_master(obj, n):
			ndist *= 0.25
		elif awareness.are_lovers(obj, n):
			ndist *= 0.4
		elif awareness.are_friends(obj, n):
			ndist *= 0.5
		elif awareness.are_acquientances(obj, n):
			ndist *= 0.9
#		if n.is_in_group("shower") && n.get_parent().busy:
#			continue
		if ndist < dist:
			dist = ndist
			target_node = awareness.obj2targets(n)[0]
	return target_node

func init(obj):
	pass
func exit(obj, status):
	pass
func run(obj, delta):
	var target_node = get_closest_target(obj, "characters")
	print(obj.name, " select target ", target_node)
	if target_node != null:
		print(obj.name, " select target ", target_node.name)
		var path_t = awareness.build_path_to_obj(obj, target_node)
		var path = []
		for k in path_t:
			path.push_back(k)
		path.push_back(target_node.global_transform.origin)
		awareness.current_path[obj] = path
		awareness.targets[obj] = target_node
#		print(obj.name, " select target path: ", path)
		print(obj.name, " select target pos: ", target_node.global_transform.origin)
		print(obj.name, " select object pos: ", obj.global_transform.origin)
		return BT_OK
	return BT_ERROR
