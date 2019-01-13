extends KinematicBody
signal active_action
signal passive_action
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
func enable_fps_camera():
	get_children()[0].get_node("head/Camera").current = true
func disable_fps_camera():
	get_children()[0].get_node("head/Camera").current = false
func set_action_mode(m):
	action = m
	get_children()[0].rotation.y = PI
	get_children()[0].rotation.x = 0
#	print(name, " ", m)
func do_active_action(other):
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#	print("active")
	var v1 = Vector2(orientation.basis[2].x, orientation.basis[2].z)
	var v2 = Vector2(other.orientation.basis[2].x, other.orientation.basis[2].z)
	var v_angle = abs(v1.angle_to(v2))
	if v_angle < PI / 4.0:
		print("BACK")
		sm.travel("KickToBed")
		set_action_mode(true)
		self.other = other
		other.emit_signal("passive_action", self)
	elif v_angle > PI / 2.0 + PI / 4.0:
		print("FRONT")
	else:
		print("SIDE")
	print(v_angle, " ", v1, " ", v2)
#	print("kick ", sm.is_playing())
#	print(sm.get_current_node())
func do_passive_action(other):
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#	print("passive")
	sm.travel("KickedToBed")
	var move_fix = Transform(Basis(), Vector3(0, 0, -0.5))
	transform = other.transform * move_fix
	set_action_mode(true)
	self.other = other
func _ready():
	get_children()[0].rotation.y = PI
	add_to_group("characters")
	connect("active_action", self, "do_active_action")
	connect("passive_action", self, "do_passive_action")
	$AnimationTree.active = true
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	sm.start("Sleep")
	$main_shape.disabled = true
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
		elif Input.is_action_pressed("activate") && $RayCast.is_colliding() && cooldown < 0.1:
			var other = $RayCast.get_collider()
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
