extends Spatial

export var next_scene_data: PackedScene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var end_scene_time = -100.0
func bus_arrived():
	end_scene_time = 4.0
	
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

	for k in get_tree().get_nodes_in_group("spawn"):
		k.emit_signal("spawn")
	$the_bus.connect("arrived", self, "bus_arrived")

# Called every frame. 'delta' is the elapsed time since the previous frame.
var posessed = false
func _process(delta):
	if !posessed:
#		$wtf_waiting/Control/sign.transform *= Transform2D(delta * 3.0, Vector2())
		var chars = get_tree().get_nodes_in_group("characters")
		for ch in chars:
			if ch.name.begins_with("male"):
				ch.posessed = true
				posessed = true
				ch.tps_camera = load("res://camera/camera.tscn").instance()
				ch.add_child(ch.tps_camera)
				ch.tps_camera.get_node("base/cam_control/Camera").current = true
				awareness.player_character = ch
#				waiting_cooldown = 3.0
#				emit_signal("selected_player", ch)
				settings.game_input_enabled = true
				break
	if end_scene_time > 0.0:
		end_scene_time -= delta
		if end_scene_time <= 0.0:
			for h in range(100):
				print("countdown finished!!!")
			if next_scene_data != null:
				var save_data = {}
				awareness.save_all_characters(awareness.character_save_data)
				for h in range(120):
					print("saved: ", JSON.print(awareness.character_save_data, "    ", true))
				for k in get_tree().get_nodes_in_group("characters"):
#					if awareness.dialogue_mode.has(k):
#						awareness.dialogue_mode[k].remove_character(k)
					k.queue_free()
				awareness.player_character = null
				queue_free()
				get_tree().change_scene_to(next_scene_data)
