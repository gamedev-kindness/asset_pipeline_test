extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var cooldown: float = 0.0
func process_player_navigation(obj, delta):
	if awareness.at[obj]["parameters/playback"].get_current_node() != "Sleep":
		var next = "Stand"
		if settings.game_input_enabled:
			if Input.is_action_pressed("right_control"):
				next = "Navigate"
				var tf_turn = Transform(Quat(Vector3(0, 1, 0), -PI * 0.6 * delta))
	#			$AnimationTree["parameters/Navigate/turn_right/active"] = true
	#			rotate(Vector3(0, 1, 0), -PI * 0.4 * delta)
				obj.orientation *= tf_turn
			elif Input.is_action_pressed("left_control"):
				next = "Navigate"
				var tf_turn = Transform(Quat(Vector3(0, 1, 0), PI * 0.6 * delta))
	#			$AnimationTree["parameters/Navigate/turn_left/active"] = true
	#			rotate(Vector3(0, 1, 0), PI * 0.4 * delta)
				obj.orientation *= tf_turn
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
		if !awareness.action_mode.has(obj):
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
