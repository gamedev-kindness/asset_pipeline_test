extends KinematicBody
signal active_action
signal passive_action
signal set_feet_ik
signal ui_action
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var posessed = false
var orientation = Transform()
var velocity = Vector3()
const GRAVITY = Vector3(0, -9.8, 0)
var action = false
var other
var cooldown = 0.0
var feet_ik_enabled = true
var tps_target

var fps_camera
var tps_camera

var track
var skel

func load_animations():
	var animations = [
		{
			"name": "front_grab",
			"animation": load("res://characters/male/front_grab.anim")
		},
		{
			"name": "front_grab_loop",
			"animation": load("res://characters/male/front_grab_loop.anim")
		},
		{
			"name": "front_grab_face_slap",
			"animation": load("res://characters/male/front_grab_face_slap.anim")
		},
		{
			"name": "grab_from_back",
			"animation": load("res://characters/male/grab_from_back.anim")
		},
		{
			"name": "kick_to_bed",
			"animation": load("res://characters/male/kick_to_bed.anim"),
		},
		{
			"name": "front_grabbed",
			"animation": load("res://characters/female/front_grabbed.anim"),
		},
		{
			"name": "front_grabbed_loop",
			"animation": load("res://characters/female/front_grabbed_loop.anim"),
		},
		{
			"name": "front_grabbed_face_slapped",
			"animation": load("res://characters/female/front_grabbed_face_slapped.anim"),
		},
		{
			"name": "grabbed_from_back",
			"animation": load("res://characters/female/grabbed_from_back.anim"),
		},
		{
			"name": "kicked_to_bed",
			"animation": load("res://characters/female/kicked_to_bed.anim")
		}
	]
	for anim in animations:
		get_children()[0].get_node("AnimationPlayer").remove_animation(anim.name)
		get_children()[0].get_node("AnimationPlayer").add_animation(anim.name, anim.animation)
		
var actions = {
	"kick_to_bed": {
			"active": "KickToBed",
			"passive": "KickedToBed",
			"ik": true,
			"direction":"BACK",
			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), 0))
	},
	"grab_from_back": {
			"active": "GrabFromBack",
			"passive": "GrabbedFromBack",
			"ik": true,
			"direction":"BACK",
			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), 0))
	},
	"front_grab": {
			"active": "FrontGrabLoop",
			"passive": "FrontGrabbedLoop",
			"ik": false,
			"direction":"FRONT",
			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI))
	},
	"front_grab_face_slap": {
			"active": "FrontGrabFaceSlap",
			"passive": "FrontGrabbedFaceSlapped",
			"ik": false,
			"direction":"FRONT",
			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI))
	}
}
var set_count = 0
func update_aabbs():
	var queue = [self]
	
	while queue.size() > 0:
		var cur = queue[0]
		queue.pop_front()
		
		if cur is MeshInstance:
			var aabb = cur.get_aabb()
			aabb = aabb.grow(1.3)
			if cur.mesh:
				cur.mesh.custom_aabb = aabb
				set_count += 1
		for c in cur.get_children():
			queue.push_back(c)


func enable_fps_camera():
	get_children()[0].get_node("head/Camera").current = true
func disable_fps_camera():
	get_children()[0].get_node("head/Camera").current = false
func set_action_mode(m):
	action = m
#	get_children()[0].rotation.y = PI
#	get_children()[0].rotation.x = 0
	if !m:
		emit_signal("set_feet_ik", false)
	if m:
		$main_shape.disabled = false
		$minimal_shape.disabled = false
#		$AnimationTree.active = false
#		track = $AnimationTree.root_motion_track
#		$AnimationTree.root_motion_track = ""
#		get_children()[0].rotation.x = 0
#		get_children()[0].rotation.y = PI
#		$AnimationTree.active = true
	else:
		$main_shape.disabled = false
		$minimal_shape.disabled = false
#		$AnimationTree.active = false
#		$AnimationTree.root_motion_track = track
#		get_children()[0].rotation.x = 0
#		get_children()[0].rotation.y = PI
#		$AnimationTree.active = true
func do_action(other, name):
	var active = actions[name].active
	var passive = actions[name].passive
	set_action_mode(true)
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	sm.travel(active)
	if actions[name].ik:
		emit_signal("set_feet_ik", true)
		feet_ik_enabled = true
	self.other = other
	other.emit_signal("passive_action", self, passive, actions[name].ik, actions[name].xform)

# Belongs to player controller
func do_ui_action(act):
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	var other = awareness.get_actuator_body(self, "characters")
	print(act)
	if act == "GrabFromBack":
		add_collision_exception_with(other)
		other.add_collision_exception_with(self)
		do_action(other, "grab_from_back")
	elif act == "KickToBed":
		add_collision_exception_with(other)
		other.add_collision_exception_with(self)
		do_action(other, "kick_to_bed")
	elif act == "FrontGrab":
		add_collision_exception_with(other)
		other.add_collision_exception_with(self)
		do_action(other, "front_grab")
	elif act == "FrontGrabFaceSlap":
		add_collision_exception_with(other)
		other.add_collision_exception_with(self)
		do_action(other, "front_grab_face_slap")
	elif act == "LeaveAction":
			set_action_mode(false)
			other.set_action_mode(false)
			remove_collision_exception_with(other)
			other.remove_collision_exception_with(self)
			if sm.is_playing():
				sm.travel("Stand")
	elif act == "Class":
		var classes = get_tree().get_nodes_in_group("classroom")
		var which = classes[randi() % classes.size()]
		var to = which.global_transform.origin
		global_transform.origin = to
	elif act == "PickUpItem":
		var item = awareness.get_actuator_body(self, "pickup")
		if item != null:
			awareness.inventory[self].push_back(item.name)
			get_node("/root").remove_child(item)
			item.queue_free()
	else:
		print("Unknown action: ", act)

func do_active_action(other):
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#	print("active")
	if $awareness.get_other_direction(other) == "BACK":
		if randf() > 0.5:
			do_action(other, "kick_to_bed")
		else:
			do_action(other, "grab_from_back")
#	var v1 = Vector2(orientation.basis[2].x, orientation.basis[2].z)
#	var v2 = Vector2(other.orientation.basis[2].x, other.orientation.basis[2].z)
#	var v_angle = abs(v1.angle_to(v2))
#	if v_angle < PI / 4.0:
#		print("BACK")
#		sm.travel("KickToBed")
#		set_action_mode(true)
#		self.other = other
#		other.emit_signal("passive_action", self)
#	elif v_angle > PI / 2.0 + PI / 4.0:
#		print("FRONT")
#	else:
#		print("SIDE")
#	print(v_angle, " ", v1, " ", v2)
#	print("kick ", sm.is_playing())
#	print(sm.get_current_node())
func do_passive_action(other, action, ik, xform):
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#	print("passive")
	sm.travel(action)
	if ik:
		emit_signal("set_feet_ik", true)
		feet_ik_enabled = true
		
	var move_fix = xform
	transform = (other.transform * move_fix).orthonormalized()
	set_action_mode(true)
	self.other = other
func _ready():
	skel = get_children()[0]
	fps_camera = get_children()[0].get_node("head/Camera")
	load_animations()
	update_aabbs()
	skel.rotation = Vector3()
	add_to_group("characters")
	connect("active_action", self, "do_active_action")
	connect("passive_action", self, "do_passive_action")
	connect("ui_action", self, "do_ui_action")
	$AnimationTree.active = true
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	sm.start("Sleep")
	$main_shape.disabled = true
	var queue = [self]
	while queue.size() > 0:
		var p = queue[0]
		queue.pop_front()
		for m in p.get_children():
			if m is BoneAttachment && m.name == "head":
				tps_target = m
				break
			queue.push_back(m)
	$AnimationTree["parameters/Navigate/walk_speed/scale"] = 1.5
#	sm.travel("Stand")

var despawn_cooldown = 0.0
var despawned = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process_player_navigation(delta, sm):
		var next = "Stand"
		if settings.game_input_enabled:
			if Input.is_action_pressed("right_control"):
				next = "Navigate"
				var tf_turn = Transform(Quat(Vector3(0, 1, 0), -PI * 0.6 * delta))
	#			$AnimationTree["parameters/Navigate/turn_right/active"] = true
	#			rotate(Vector3(0, 1, 0), -PI * 0.4 * delta)
				orientation *= tf_turn
			elif Input.is_action_pressed("left_control"):
				next = "Navigate"
				var tf_turn = Transform(Quat(Vector3(0, 1, 0), PI * 0.6 * delta))
	#			$AnimationTree["parameters/Navigate/turn_left/active"] = true
	#			rotate(Vector3(0, 1, 0), PI * 0.4 * delta)
				orientation *= tf_turn
			elif Input.is_action_pressed("up_control"):
				next = "Navigate"
			elif Input.is_action_pressed("activate") && cooldown < 0.1:
				var other = awareness.get_actuator_body(self, "characters")
				if other != null:
					if other.is_in_group("characters"):
						emit_signal("active_action", other)
						add_collision_exception_with(other)
						cooldown = 1.5
		else:
			$AnimationTree["parameters/Navigate/turn_left/active"] = false
			$AnimationTree["parameters/Navigate/turn_right/active"] = false
		if !action:
			sm.travel(next)
		else:
			if !sm.is_playing():
				set_action_mode(false)
				remove_collision_exception_with(other)
#				print("action stopped")
func _process(delta):
	orientation = global_transform
	orientation.origin = Vector3()
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	if posessed && !action && sm.get_current_node() != "Sleep":
		process_player_navigation(delta, sm)
	elif posessed && !action && sm.get_current_node() == "Sleep":
		if settings.game_input_enabled:
			if Input.is_action_just_pressed("activate") && cooldown < 0.1:
				cooldown = 1.0
				if sm.is_playing():
					sm.travel("Stand")
					$main_shape.disabled = false

	elif posessed && action:
		if settings.game_input_enabled:
			if Input.is_action_just_pressed("activate") && cooldown < 0.1:
				set_action_mode(false)
				other.set_action_mode(false)
				remove_collision_exception_with(other)
				if sm.is_playing():
					sm.travel("Stand")
#				print("action stopped")
				cooldown = 1.0
		
	else:
		if $AI.has_method("run") && !action:
			$AI.run(delta, self, $AnimationTree)
	if true:
		var rm = $AnimationTree.get_root_motion_transform()
		orientation *= rm
#		var tf_fix = Transform(Quat(Vector3(0, 1, 0), PI))
#		var h_velocity = tf_fix.xform(orientation.origin) / delta
		var h_velocity = orientation.origin / delta
		velocity.x = h_velocity.x
		velocity.z = h_velocity.z
		if !action:
			velocity += GRAVITY * delta
		if !action:
			velocity = move_and_slide(velocity, Vector3(0, 1, 0))
		else:
			if velocity.length() > 0.06:
				velocity = move_and_slide(velocity, Vector3(0, 1, 0), false, 4, PI * 0.1, false)
#		print(velocity.length())
		orientation.origin = Vector3()
		orientation = orientation.orthonormalized()
		global_transform.basis = orientation.basis
		if cooldown > 0.0:
			cooldown -= delta
	skel.rotation = Vector3()
