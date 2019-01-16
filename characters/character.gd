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

var actions = {
	"kick_to_bed": {
			"active": "KickToBed",
			"passive": "KickedToBed",
			"ik": true,
			"direction":"BACK"
	},
	"grab_from_back": {
			"active": "GrabFromBack",
			"passive": "GrabbedFromBack",
			"ik": true,
			"direction":"BACK"
	}
}
func enable_fps_camera():
	get_children()[0].get_node("head/Camera").current = true
func disable_fps_camera():
	get_children()[0].get_node("head/Camera").current = false
func set_action_mode(m):
	action = m
	get_children()[0].rotation.y = PI
	get_children()[0].rotation.x = 0
	if !m:
		emit_signal("set_feet_ik", false)
func do_action(other, name):
	var active = actions[name].active
	var passive = actions[name].passive
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	sm.travel(active)
	if actions[name].ik:
		emit_signal("set_feet_ik", true)
		feet_ik_enabled = true
	set_action_mode(true)
	self.other = other
	other.emit_signal("passive_action", self, passive, actions[name].ik)

# Belongs to player controller
func do_ui_action(act):
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	var other = $awareness.get_actuator_body("characters")
	print(act)
	if act == "GrabFromBack":
		do_action(other, "grab_from_back")
	elif act == "KickToBed":
			do_action(other, "kick_to_bed")
	elif act == "LeaveAction":
			set_action_mode(false)
			other.set_action_mode(false)
			remove_collision_exception_with(other)
			if sm.is_playing():
				sm.travel("Stand")
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
func do_passive_action(other, action, ik):
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#	print("passive")
	sm.travel(action)
	if ik:
		emit_signal("set_feet_ik", true)
		feet_ik_enabled = true
		
	var move_fix = Transform(Basis(), Vector3(0, 0, -0.5))
	transform = other.transform * move_fix
	set_action_mode(true)
	self.other = other
func _ready():
	get_children()[0].rotation.y = PI
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
#	sm.travel("Stand")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	orientation = global_transform
	orientation.origin = Vector3()
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	if posessed && !action && sm.get_current_node() != "Sleep":
		var next = "Stand"
		if Input.is_action_pressed("ui_right"):
			next = "Navigate"
			var tf_turn = Transform(Quat(Vector3(0, 1, 0), -PI * 0.6 * delta))
#			$AnimationTree["parameters/Navigate/turn_right/active"] = true
#			rotate(Vector3(0, 1, 0), -PI * 0.4 * delta)
			orientation *= tf_turn
		elif Input.is_action_pressed("ui_left"):
			next = "Navigate"
			var tf_turn = Transform(Quat(Vector3(0, 1, 0), PI * 0.6 * delta))
#			$AnimationTree["parameters/Navigate/turn_left/active"] = true
#			rotate(Vector3(0, 1, 0), PI * 0.4 * delta)
			orientation *= tf_turn
		elif Input.is_action_pressed("ui_up"):
			next = "Navigate"
		elif Input.is_action_pressed("activate") && cooldown < 0.1:
			var other = $awareness.get_actuator_body("characters")
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
	elif posessed && !action && sm.get_current_node() == "Sleep":
		if Input.is_action_just_pressed("activate") && cooldown < 0.1:
			cooldown = 1.0
			if sm.is_playing():
				sm.travel("Stand")
				$main_shape.disabled = false

	elif posessed && action:
		if Input.is_action_just_pressed("activate") && cooldown < 0.1:
			set_action_mode(false)
			other.set_action_mode(false)
			remove_collision_exception_with(other)
			if sm.is_playing():
				sm.travel("Stand")
#			print("action stopped")
			cooldown = 1.0
		
	else:
		if $AI.has_method("run") && !action:
			$AI.run(delta, self, $AnimationTree)
	var rm = $AnimationTree.get_root_motion_transform()
	orientation *= rm
	var tf_fix = Transform(Quat(Vector3(0, 1, 0), PI))
	var h_velocity = tf_fix.xform(orientation.origin) / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	if !action:
		velocity += GRAVITY * delta
	if !action:
		velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	else:
		if velocity.length() > 0.06:
			velocity = move_and_slide(velocity, Vector3(0, 1, 0), true, 4, PI * 0.1, false)
#		print(velocity.length())
	orientation.origin = Vector3()
	orientation = orientation.orthonormalized()
	global_transform.basis = orientation.basis
	if cooldown > 0.0:
		cooldown -= delta
	get_children()[0].rotation.y = PI
	get_children()[0].rotation.x = 0
#	else:
#		sm.travel("Navigation")
#		move_and_slide(-transform.basis[2] * 0.5, Vector3(0, 1, 0))
