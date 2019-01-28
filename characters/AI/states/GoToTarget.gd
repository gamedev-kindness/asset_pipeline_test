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
	print("Entering ", name)
	awareness.at[obj].travel("Navigate")
func check_target_valid(obj):
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
func run(obj, delta):
	if awareness.action_cooldown.has(obj):
		if awareness.action_cooldown[obj] > 0.0:
			awareness.action_cooldown[obj] -= delta
			return ""
	if awareness.at[obj].get_current_node() == "Navigate":
		if awareness.current_path[obj].size() == 0 || !check_target_valid(obj):
			return "SelectTarget"
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
#		var mesh = SphereMesh.new()
#		mesh.radius = 0.5
#		var mi = MeshInstance.new()
#		mi.mesh = mesh
#		get_node("/root").add_child(mi)
#		mi.global_transform.origin = point
#		print("dist: ", obj.global_transform.origin.distance_squared_to(point))
		if obj.global_transform.origin.distance_squared_to(point) < 1.0:
			awareness.current_path[obj].remove(0)
			if awareness.current_path[obj].size() == 0 || awareness.distance(obj, awareness.targets[obj]) < 1.5:
				return "ActivateTarget"
##		var local_point = obj.global_transform.xform_inv(point)
#		if local_point.z < 0:
#			awareness.current_path[obj].remove(0)
#			if awareness.current_path[obj].size() == 0:
#				return "SelectTarget"
#			return ""
##		var angle = 0.0
##		var angle_left = 0.0
##		var angle_right = 0.0
##		var td = local_point.normalized()
##		angle = deg2rad(180) * td.x
##		if awareness.raycasts[obj].left.is_colliding():
##			angle -= deg2rad(180 + 45.0 * randf())
##		if awareness.raycasts[obj].right.is_colliding():
##			angle += deg2rad(180 + 45.0 * randf())
##		if awareness.raycasts[obj].front.is_colliding():
##			var n = awareness.raycasts[obj].front.get_collision_normal()
##			var p = awareness.raycasts[obj].front.get_collision_point()
##			if obj.global_transform.origin.distance_to(p) < 1.0:
##				var lt = obj.global_transform
##				lt.origin = Vector3()
##				var ln = lt.xform_inv(n)
##				print("raycast collision: ", ln)
##				angle += 0.5 * deg2rad(90) * sign(ln.x) + 0.5 * angle
#		angle = angle + angle_left  + angle_right
		
		var tf_turn = Transform(Quat(Vector3(0, 1, 0), -angle * delta))
			
#		var curv = obj.global_transform.basis[2]
#		var desiredv = (point - obj.global_transform.origin).normalized()
#		var angle = Vector2(curv.x, curv.z).angle_to(Vector2(desiredv.x, desiredv.z))
#		var tf_turn = Transform().looking_at(point, Vector3(0, 1, 0)).orthonormalized()
#		obj.orientation.interpolate_with(tf_turn, delta)
		obj.orientation *= tf_turn
#		dir = randf() * 1.2 - 0.6
		if awareness.current_path[obj].size() == 0:
			return "SelectTarget"
		if awareness.targets[obj] != null && awareness.targets[obj].is_in_group("characters"):
			update_path(obj)
		return ""


func exit(obj):
	print("Exiting ", name)
