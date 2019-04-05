extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
onready var frame_tf: Transform = Transform()
var relative = true
func _ready():
	var keymap = ConfigFile.new()
	var err = keymap.load("user://settings.cfg")
	if err:
		for act in InputMap.get_actions():
			keymap.set_value("input", act, InputMap.get_action_list(act))
		keymap.save("user://settings.cfg")
	else:
		print("loaded config")
		for action in keymap.get_section_keys("input"):
			if !action in InputMap.get_actions():
				InputMap.add_action(action)
			var events = InputMap.get_action_list(action)
			for e in events:
				InputMap.action_erase_event(action, e)
			for evts in keymap.get_value("input", action):
				InputMap.action_add_event(action, evts)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var cooldown: float = 0.0
func _physics_process(delta):
	if awareness.player_character != null:
		if awareness.action_mode.has(awareness.player_character):
			return
		if awareness.dialogue_mode.has(awareness.player_character):
			return
		else:
			if awareness.at.has(awareness.player_character):
				if !relative:
					process_player_navigation(awareness.player_character, delta)
				else:
					process_player_nav_new(awareness.player_character, delta)

# TODO: move to settings
const MOTION_INTERPOLATE_SPEED = 10.0
var motion = Vector2()
func process_player_nav_new(obj, delta):
	if awareness.at[obj]["parameters/playback"].get_current_node() != "Sleep":
		var motion_target = \
			Vector2(Input.get_action_strength("left_control") - \
			Input.get_action_strength("right_control"), \
			Input.get_action_strength("up_control") - \
			Input.get_action_strength("down_control"))
		motion = motion.linear_interpolate(motion_target, MOTION_INTERPOLATE_SPEED * delta)
		var cam = get_viewport().get_camera()
		var cam_z = cam.global_transform.basis.z
		cam_z.y = 0
		var cam_x = cam.global_transform.basis.x
		cam_x.y = 0
		var target = -cam_x * motion.x - cam_z * motion.y
		var next = "Stand"
		if target.length() > 0.001:
			var tf_turn = obj.orientation.inverse() * Transform().looking_at(target, Vector3(0, 1, 0))
#			frame_tf = obj.orientation.inverse() * Transform().interpolate_with(tf_turn, 10.0 * delta)
			frame_tf *= Transform().interpolate_with(tf_turn, 5.0 * delta)
			frame_tf = frame_tf.orthonormalized()
			next = "Navigate"
		if Input.is_action_pressed("activate") && cooldown < 0.1:
			var other = awareness.get_actuator_body(obj, "characters")
			if other != null:
				if other.is_in_group("characters"):
					emit_signal("active_action", other)
					obj.add_collision_exception_with(other)
					cooldown = 1.5
		awareness.at[obj]["parameters/playback"].travel(next)
	else:
		if settings.game_input_enabled:
			if Input.is_action_just_pressed("activate") && cooldown < 0.1:
				cooldown = 1.0
				if awareness.at[obj]["parameters/playback"].is_playing():
					awareness.at[obj]["parameters/playback"].travel("Stand")
					obj.enable_all_shapes()

	
func process_player_navigation(obj, delta):
	if awareness.at[obj]["parameters/playback"].get_current_node() != "Sleep":
		var next = "Stand"
		if settings.game_input_enabled:
			if Input.is_action_pressed("right_control"):
				next = "Navigate"
				var tf_turn = Transform(Quat(Vector3(0, 1, 0), -PI * 0.6 * delta))
	#			$AnimationTree["parameters/Navigate/turn_right/active"] = true
	#			rotate(Vector3(0, 1, 0), -PI * 0.4 * delta)
				frame_tf *= tf_turn
			elif Input.is_action_pressed("left_control"):
				next = "Navigate"
				var tf_turn = Transform(Quat(Vector3(0, 1, 0), PI * 0.6 * delta))
	#			$AnimationTree["parameters/Navigate/turn_left/active"] = true
	#			rotate(Vector3(0, 1, 0), PI * 0.4 * delta)
				frame_tf *= tf_turn
			elif Input.is_action_pressed("up_control"):
				next = "Navigate"
			elif Input.is_action_pressed("activate") && cooldown < 0.1:
				var other = awareness.get_actuator_body(obj, "characters")
				if other != null:
					if other.is_in_group("characters"):
						emit_signal("active_action", other)
						obj.add_collision_exception_with(other)
						cooldown = 1.5
		else:
			awareness.at[obj]["parameters/Navigate/turn_left/active"] = false
			awareness.at[obj]["parameters/Navigate/turn_right/active"] = false
		awareness.at[obj]["parameters/playback"].travel(next)
#		else:
#			if !sm.is_playing():
#				obj.set_action_mode(false)
#				obj.remove_collision_exception_with(other)
#				print("action stopped")
	else:
		if settings.game_input_enabled:
			if Input.is_action_just_pressed("activate") && cooldown < 0.1:
				cooldown = 1.0
				if awareness.at[obj]["parameters/playback"].is_playing():
					awareness.at[obj]["parameters/playback"].travel("Stand")
					obj.enable_all_shapes()
