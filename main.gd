extends Spatial
signal selected_player

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
#var anim1:AnimationPlayer
#var anim2:AnimationPlayer
var ps = []
var camera_target
func update_time(g):
	$clock_control/datetime.text = "%02d" %(g[1]) + ":" + "%02d" %(g[0])
	$clock_control/datetime.update()
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
	$wtf_waiting.show()
	$opportunities.hide()
	awareness.connect("daytime_update", self, "update_time")
	$clock_control.hide()
	$console.hide()
	$stats.hide()
	$stats.character = self
	connect("selected_player", $opportunities, "selected_character")
	$clock_control/stats_button.connect("pressed", self, "toggle_stats")
	Engine.target_fps = 60.0
func toggle_stats():
	if $stats.visible == true:
		$stats.visible = false
	else:
		$stats.visible = true
var fps_camera = false
var cooldown = 0.0
var posessed = false
func process_keyboard(delta):
	if cooldown > 0.1:
		cooldown -= delta
		return
	if posessed:
		if Input.is_action_pressed("change_view"):
			if !fps_camera:
				awareness.player_character.tps_camera.get_node("base/cam_control/Camera").current = false
				awareness.player_character.fps_camera.current = true
				fps_camera = true
				cooldown += 0.5
			elif fps_camera:
				awareness.player_character.fps_camera.current = false
				awareness.player_character.tps_camera.get_node("base/cam_control/Camera").current = true
				cooldown += 0.5
				fps_camera = false
#	if Input.is_action_pressed("console"):
#			$console.show()
#			cooldown += 1.0
var waiting_cooldown = 5.0
func _process(delta):
	if !posessed:
		$wtf_waiting/Control/sign.transform *= Transform2D(delta * 3.0, Vector2())
		var chars = get_tree().get_nodes_in_group("characters")
		for ch in chars:
			if ch.name.begins_with("male"):
				ch.posessed = true
				posessed = true
				ch.tps_camera = load("res://camera/camera.tscn").instance()
				ch.add_child(ch.tps_camera)
				ch.tps_camera.get_node("base/cam_control/Camera").current = true
				awareness.player_character = ch
				waiting_cooldown = 3.0
				emit_signal("selected_player", ch)
				settings.game_input_enabled = true
				break
	if posessed:
		if waiting_cooldown > 0.0:
			waiting_cooldown -= delta
		else:
			if $wtf_waiting.visible:
				$wtf_waiting.hide()
				$opportunities.show()
				$clock_control.show()
	if settings.game_input_enabled:
		process_keyboard(delta)
	# Need to process console key seperately
