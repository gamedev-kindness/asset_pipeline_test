extends BTTask
class_name BTWalkToTarget
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var target_distance: float = 1.5

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
func update_path(obj):
	var target_node = awareness.targets[obj]
	if target_node != null:
		var current_path = awareness.current_path[obj]
		if current_path.size() == 0:
			return false
		var tgt_pos = current_path[current_path.size() - 1]
		if tgt_pos.distance_to(target_node.global_transform.origin) < 1.0:
			return true
		var path_t = awareness.build_path_to_obj(obj, target_node)
		if path_t.size() > 0:
			var path = []
			for k in path_t:
				path.push_back(k)
			awareness.current_path[obj] = path
			return true
	return false

func init(obj):
	awareness.at[obj]["parameters/playback"].travel("Navigate")
func exit(obj):
	pass
func run(obj, delta):
	if !awareness.current_path.has(obj):
		return BT_ERROR
	if awareness.current_path[obj].size() == 0 || !check_target_valid(obj):
		return BT_ERROR
	if awareness.action_cooldown.has(obj):
		if awareness.action_cooldown[obj] > 0.0:
			awareness.action_cooldown[obj] -= delta
			return BT_BUSY
	if awareness.at[obj]["parameters/playback"].get_current_node() == "Navigate":
		var point = awareness.current_path[obj][0]
		var direction = (point - obj.global_transform.origin).normalized()
		if awareness.raycasts[obj].left.is_colliding() && awareness.raycasts[obj].right.is_colliding():
			direction = -direction * 20.0
		elif awareness.raycasts[obj].left.is_colliding():
			direction += awareness.raycasts[obj].left.get_collision_normal() * (1.0 + randf()) * 10.0
		elif awareness.raycasts[obj].right.is_colliding():
			direction += awareness.raycasts[obj].right.get_collision_normal() * (1.0 + randf()) * 10.0
		if awareness.raycasts[obj].front.is_colliding():
			direction += awareness.raycasts[obj].front.get_collision_normal() * 20.0
		var actual_direction = -obj.global_transform.basis[2]
		var angle = Vector2(actual_direction.x, actual_direction.z).angle_to(Vector2(direction.x, direction.z))
		if obj.global_transform.origin.distance_squared_to(point) < 1.0:
			awareness.current_path[obj].remove(0)
			if awareness.current_path[obj].size() == 0 || awareness.distance(obj, awareness.targets[obj]) < target_distance:
				return BT_OK
		var tf_turn = Transform(Quat(Vector3(0, 1, 0), -angle * delta))
		obj.orientation *= tf_turn
#		dir = randf() * 1.2 - 0.6
#		if awareness.current_path[obj].size() == 0:
#			return BT_OK
		if awareness.targets[obj] != null && awareness.targets[obj].is_in_group("character_front_target"):
			update_path(obj)
	return BT_BUSY
