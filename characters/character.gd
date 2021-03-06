extends KinematicBody
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
var other
var cooldown = 0.0
var feet_ik_enabled = true
var tps_target
var vehicle = false

var fps_camera
var tps_camera

var track
var skel

var stats = {}

func create_signal_track_anim(signame) -> Animation:
	var anim = Animation.new()
	anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(0, "../AnimationTree")
	anim.track_insert_key(0, 0.0, {"method": "emit_signal", "args": [signame, self]})
	var ap: AnimationPlayer = skel.get_node("AnimationPlayer")
	ap.add_animation("signal-" + signame, anim)
	return anim

func remove_default_clothes():
	var remove_meshes : = [
	"underware",
	"crudegown",
	"male_worksuit"
	]
	var queue = [self]
	while queue.size() > 0:
		var item = queue[0]
		queue.pop_front()
		for k in item.get_children():
			queue.push_back(k)
		if item is MeshInstance:
			for f in remove_meshes:
				if item.name.find(f) >= 0:
					item.queue_free()
		
#var actions = {
#	"kick_to_bed": {
#			"active": "KickToBed",
#			"passive": "KickedToBed",
#			"ik": true,
#			"tears": true,
#			"direction":"BACK",
#			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), 0)),
#	},
#	"grab_from_back": {
#			"active": "GrabFromBack",
#			"passive":"GrabbedFromBack",
#			"ik": true,
#			"tears": true,
#			"direction":"BACK",
#			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), 0)),
#			"valid_actions": ["Navigate", "Stand"]
#	},
#	"front_grab": {
#			"active": "FrontGrab",
#			"passive": "FrontGrabbed",
#			"ik": false,
#			"tears": true,
#			"direction":"FRONT",
#			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI)),
#	},
#	"front_grab_face_slap": {
#			"active": "FrontGrabFaceSlap",
#			"passive": "FrontGrabbedFaceSlapped",
#			"tears": true,
#			"ik": false,
#			"direction":"FRONT",
#			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI))
#	},
#	"missionary1": {
#			"active": "Missionary1_1",
#			"passive": "Missionary1_2",
#			"tears": true,
#			"ik": false,
#			"direction":"FRONT",
#			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI))
#	}
#}
#
#var pair_act = {
#	"GrabFromBack": {"name": "grab_from_back", "check": "check_state_valid"},
#	"KickToBed": {"name": "kick_to_bed", "check": "check_state_valid"},
#	"FrontGrab": {"name": "front_grab", "check": "check_state_valid"},
#	"FrontGrabFaceSlap": {"name": "front_grab_face_slap"},
#	"Missionary1": {"name": "missionary1"}
#}

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

func enable_tears():
	var skel = get_children()[0]
	if skel.has_node("tears"):
		skel.get_node("tears").show()
func disable_tears():
	var skel = get_children()[0]
	if skel.has_node("tears"):
		skel.get_node("tears").hide()
func enable_fps_camera():
	get_children()[0].get_node("head/Camera").current = true
func disable_fps_camera():
	get_children()[0].get_node("head/Camera").current = false
func enable_pee_particle():
	var skel = get_children()[0]
	if skel.has_node("penis"):
		skel.get_node("penis/pee_particles").emitting = true
	elif skel.has_node("pelvis"):
		skel.get_node("pelvis/pee_particles").emitting = true
func disable_pee_particle():
	var skel = get_children()[0]
	if skel.has_node("penis"):
		skel.get_node("penis/pee_particles").emitting = false
	elif skel.has_node("pelvis"):
		skel.get_node("pelvis/pee_particles").emitting = false
	print("disable pee")
func enable_sitting_ik():
	var skel = get_children()[0]
	var left = skel.get_node("sitting_ik_left")
	var right = skel.get_node("sitting_ik_right")
	left.start()
	right.start()
func disable_sitting_ik():
	var skel = get_children()[0]
	var left = skel.get_node("sitting_ik_left")
	var right = skel.get_node("sitting_ik_right")
	left.stop()
	right.stopt()

func enable_all_shapes():
	$main_shape.disabled = false
	$minimal_shape.disabled = false

func enable_minimal_shapes():
	$main_shape.disabled = true
	$minimal_shape.disabled = false

func enable_no_shapes():
	$main_shape.disabled = true
	$minimal_shape.disabled = true

#func set_action_mode(m):
#	_action = m
##	get_children()[0].rotation.y = PI
##	get_children()[0].rotation.x = 0
#	if !m:
#		emit_signal("set_feet_ik", false)
#	if m:
#		$main_shape.disabled = false
#		$minimal_shape.disabled = false
##		$AnimationTree.active = false
##		track = $AnimationTree.root_motion_track
##		$AnimationTree.root_motion_track = ""
##		get_children()[0].rotation.x = 0
##		get_children()[0].rotation.y = PI
##		$AnimationTree.active = true
#	else:
#		$main_shape.disabled = false
#		$minimal_shape.disabled = false
#		$AnimationTree.active = false
#		$AnimationTree.root_motion_track = track
#		get_children()[0].rotation.x = 0
#		get_children()[0].rotation.y = PI
#		$AnimationTree.active = true
#func do_action(other, name):
#	var active = actions[name].active
#	var passive = actions[name].passive
#	set_action_mode(true)
#	print("Playing action: active: ", active, " passive: ", passive)
#	if active in ["FrontGrabFaceSlap", "Missionary1_1"]:
#		self.other = other
#		print("setting main to FrontGrab")
#		var parent_sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#		other.emit_signal("passive_action", self, passive, actions[name].ik, actions[name].xform, actions[name].tears)
#		while parent_sm.get_current_node() != "FrontGrab":
#			parent_sm.travel("FrontGrab")
#			yield(get_tree().create_timer(0.2), "timeout")
#		var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/FrontGrab/playback"]
#		print("setting FrontGrab to ", active)
#		sm.travel(active)
#	else:
#		var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#		sm.travel(active)
#		self.other = other
#		awareness.passive_action[other] = {"action": passive, "other": self}
##		other.emit_signal("passive_action", self, passive, actions[name].ik, actions[name].xform, actions[name].tears)
#	if actions[name].ik:
#		emit_signal("set_feet_ik", true)
#		feet_ik_enabled = true

# Belongs to player controller
var allowed_states_for_action = ["Navigate", "Stand"]
func check_state_valid(other):
	if !awareness.at.has(other):
		return false
	return 	awareness.at[other]["parameters/playback"].get_current_node() in allowed_states_for_action
func do_ui_action(act):
#	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	var other = self.other
	print(act)
	action.add_action(act, self, other)
#	if act in pair_act.keys():
#		if pair_act[act].has("check") && pair_act[act].check == "check_state_valid":
#			print("checking state:")
#			if check_state_valid(other):
#				print("valid state")
#				add_collision_exception_with(other)
#				other.add_collision_exception_with(self)
#				do_action(other, pair_act[act].name)
#			else:
#				print("invalid state")
#		elif pair_act[act].has("check") && pair_act[act].check != "check_state_valid":
#			if call(pair_act[act].check, act, other):
#				add_collision_exception_with(other)
#				other.add_collision_exception_with(self)
#				do_action(other, pair_act[act].name)
#		elif !pair_act[act].has("check"):
#			add_collision_exception_with(other)
#			other.add_collision_exception_with(self)
#			do_action(other, pair_act[act].name)
#	elif act == "Talk":
#		if other != null:
#			awareness.initiate_dialogue(self, other)
#	elif act == "LeaveAction":
#			set_action_mode(false)
#			if other != null:
##				other.set_action_mode(false)
#				remove_collision_exception_with(other)
#				other.remove_collision_exception_with(self)
#				awareness.passive_action.erase(other)
#			if sm.is_playing():
#				sm.travel("Stand")
#			self.other = null
#	elif act == "Class":
#		var classes = get_tree().get_nodes_in_group("classroom")
#		if classes.size() > 0:
#			var which = classes[randi() % classes.size()]
#			var to = which.global_transform.origin
#			global_transform.origin = to
#	elif act == "PickUpItem":
#		var item = awareness.get_actuator_body(self, "pickup")
#		if item != null:
#			awareness.inventory[self].push_back(item.item_type)
#			get_node("/root").remove_child(item)
#			item.queue_free()
#	else:
#		print("Unknown action: ", act, " other: ", other)

#func do_active_action(other):
#	pass
#	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#	print("active")
#	if awareness.get_other_direction(self, other) == "BACK":
#		if randf() > 0.5:
#			do_action(other, "kick_to_bed")
#		else:
#			do_action(other, "grab_from_back")
#func do_passive_action(other, action, ik, xform):
#	if action in ["FrontGrabbedFaceSlapped", "Missionary1_2"]:
#		var sm_parent: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#		sm_parent.travel("FrontGrabbed")
#		while sm_parent.get_current_node() != "FrontGrabbed":
#			sm_parent.travel("FrontGrabbed")
#			yield(get_tree().create_timer(0.2), "timeout")
#		var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/FrontGrabbed/playback"]
#		sm.travel(action)
#	else:
#		var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
#		sm.travel(action)
#	if ik:
#		emit_signal("set_feet_ik", true)
#		feet_ik_enabled = true
#
#	var move_fix = xform
#	transform = (other.transform * move_fix).orthonormalized()
#	set_action_mode(true)
#	enable_tears()
#	self.other = other
func init_data():
	awareness.add_character_data(self)
	var character_name = ""
	var character_firstname = ""
	var character_lastname = ""
	if name.begins_with("male"):
		awareness.character_data[self].gender = "male"
		character_firstname = awareness.build_male_firstname().capitalize()
		
	elif name.begins_with("female"):
		awareness.character_data[self].gender = "female"
		character_firstname = awareness.build_female_firstname().capitalize()
	elif name.begins_with("@male"):
		awareness.character_data[self].gender = "male"
		character_firstname = awareness.build_male_firstname().capitalize()
	elif name.begins_with("@female"):
		awareness.character_data[self].gender = "female"
		character_firstname = awareness.build_female_firstname().capitalize()
	else:
		print("wtf: ", name)
		get_tree().quit()
	character_lastname = awareness.build_lastname().capitalize()
	character_name = character_firstname + " " + character_lastname
	awareness.character_data[self].character_name = character_name
	awareness.character_data[self].firstname = character_firstname
	awareness.character_data[self].lastname = character_lastname
	print("Done character initialization")
func _ready():
	remove_default_clothes()
	awareness.at[self] = $AnimationTree
	collision_layer = 1
	collision_mask = 0x1f
	var anim_pb = AnimationParameterPlayback.new()
	anim_pb.load_animations(awareness.at[self])
	skel = get_children()[0]
	fps_camera = get_children()[0].get_node("head/Camera")
#	load_animations(skel)
	update_aabbs()
	skel.rotation = Vector3()
	add_to_group("characters")
#	connect("active_action", self, "do_active_action")
#	connect("passive_action", self, "do_passive_action")
	connect("ui_action", self, "do_ui_action")
	disable_tears()
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
	$AnimationTree["parameters/Sitting/wiggle_amount/add_amount"] = 0.15 + randf() * 0.3
	$AnimationTree["parameters/Sitting/wiggle_speed/scale"] = 0.1 + randf() * 0.3
#	sm.travel("Stand")
	$rpg.character = self
	var raycasts = {
		"front": $RayCast,
		"far": $ray_far,
		"left": $raycast_left,
		"right": $raycast_right
	}
	awareness.raycasts[self] = raycasts
	create_signal_track_anim("end")

var despawn_cooldown = 0.0
var despawned = false

func get_head_position():
	return skel.get_node("head").global_transform.origin
#func dialogue(other):
#	print(self.name, " initiated dialogue with ", other.name)
#	$dialogue.dialogue(self, other, skel.get_node("head").global_transform.origin)
#	return true
#func answer_dialogue(other):
#	print(self.name, " answers ", other.name)
#	$dialogue.dialogue_answer(self, other, skel.get_node("head").global_transform.origin)

# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func _process(delta):
	orientation = global_transform
	orientation.origin = Vector3()
	var sm: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	if posessed:
		orientation *= player.frame_tf
		player.frame_tf = Transform()
#	if posessed && !awareness.action_mode.has(self):
#		player.process_player_navigation(self, delta)

#	elif posessed && action:
#		if settings.game_input_enabled:
#			if Input.is_action_just_pressed("activate") && cooldown < 0.1:
#				set_action_mode(false)
#				other.set_action_mode(false)
#				remove_collision_exception_with(other)
#				if sm.is_playing():
#					sm.travel("Stand")
##				print("action stopped")
#				cooldown = 1.0
		
	if !posessed && !awareness.player_character == self:
		if AI.has_method("run"):
			AI.run(delta, self)
	if true:
		var rm = $AnimationTree.get_root_motion_transform()
		orientation *= rm
#		var tf_fix = Transform(Quat(Vector3(0, 1, 0), PI))
#		var h_velocity = tf_fix.xform(orientation.origin) / delta
		var h_velocity = orientation.origin / delta
		velocity.x = h_velocity.x
		velocity.z = h_velocity.z
		if !awareness.action_mode.has(self) && !is_on_floor() && !vehicle:
			velocity += GRAVITY * delta
		if !awareness.action_mode.has(self):
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
	for c in get_children():
		if c.is_in_group("stats"):
			stats[c.name] = c.get_value()
	skel.rotation = Vector3()
