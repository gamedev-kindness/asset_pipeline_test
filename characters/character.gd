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
func do_active_action(other):
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	print("active")
	sm.travel("KickToBed")
	action = true
	self.other = other
#	print("kick ", sm.is_playing())
#	print(sm.get_current_node())
func do_passive_action(other):
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	print("passive")
	sm.travel("KickedToBed")
	var move_fix = Transform(Basis(), Vector3(0, 0, -0.5))
	transform = other.transform * move_fix
	action = true
	self.other = other
func _ready():
	get_children()[0].rotation.y = PI
	add_to_group("characters")
	connect("active_action", self, "do_active_action")
	connect("passive_action", self, "do_passive_action")
	$AnimationTree.active = true
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	sm.start("Stand")
#	sm.travel("Stand")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var orientation = global_transform
	orientation.origin = Vector3()
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	if posessed:
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
		elif Input.is_action_pressed("activate") && $RayCast.is_colliding():
			var other = $RayCast.get_collider()
			other.emit_signal("passive_action", self)
			emit_signal("active_action", other)
			add_collision_exception_with(other)
		else:
			$AnimationTree["parameters/Navigate/turn_left/active"] = false
			$AnimationTree["parameters/Navigate/turn_right/active"] = false
		if !action:
			sm.travel(next)
		else:
			if !sm.is_playing():
				action = false
				remove_collision_exception_with(other)
				print("action stopped")
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
		print(velocity.length())
	orientation.origin = Vector3()
	orientation = orientation.orthonormalized()
	global_transform.basis = orientation.basis
	if action:
		get_children()[0].rotation.y = PI
		get_children()[0].rotation.x = 0
	velocity = velocity * 0.9
#	else:
#		sm.travel("Navigation")
#		move_and_slide(-transform.basis[2] * 0.5, Vector3(0, 1, 0))
