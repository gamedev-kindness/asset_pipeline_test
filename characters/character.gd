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
func do_active_action():
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	print("active")
	sm.travel("KickToBed")
	action = true
#	print("kick ", sm.is_playing())
#	print(sm.get_current_node())
func do_passive_action():
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	print("passive")
	sm.travel("KickedToBed")
	action = true
func _ready():
	add_to_group("characters")
	connect("active_action", self, "do_active_action")
	connect("passive_action", self, "do_passive_action")
	get_children()[0].transform = Transform()
	get_children()[0].rotation.y = PI
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
			$AnimationTree["parameters/Navigate/turn_right/active"] = true
#			rotate(Vector3(0, 1, 0), -PI * 0.4 * delta)
		elif Input.is_action_pressed("ui_left"):
			next = "Navigate"
			$AnimationTree["parameters/Navigate/turn_left/active"] = true
##			rotate(Vector3(0, 1, 0), PI * 0.4 * delta)
		elif Input.is_action_pressed("ui_up"):
			next = "Navigate"
		elif Input.is_action_pressed("activate") && $RayCast.is_colliding():
			var other = $RayCast.get_collider()
			other.emit_signal("passive_action")
			emit_signal("active_action")
		else:
			$AnimationTree["parameters/Navigate/turn_left/active"] = false
			$AnimationTree["parameters/Navigate/turn_right/active"] = false
		if !action:
			sm.travel(next)
		
	var rm = $AnimationTree.get_root_motion_transform()
	orientation *= rm
	var h_velocity = orientation.origin / delta
	velocity.x = -h_velocity.x
	velocity.z = -h_velocity.z
	velocity += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	orientation.origin = Vector3()
	orientation = orientation.orthonormalized()
	global_transform.basis = orientation.basis
#	else:
#		sm.travel("Navigation")
#		move_and_slide(-transform.basis[2] * 0.5, Vector3(0, 1, 0))
			
