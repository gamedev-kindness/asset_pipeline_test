extends Control

signal key_assigned
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var state = 0
var keymap

func control_setting(control):
	if state == 0:
		print(control.name)
		state = 1
		$press_a_key.show()
		$press_a_key.set_process_input(true)
		remap_action = control.name
var finger_y = 0.0
var button_y = 0.0
var noise
var remap_action = ""
var cooldown = 0.0
func remap_key(scancode):
	$press_a_key.set_process_input(false)
	$press_a_key.hide()
	if !remap_action in InputMap.get_actions():
		InputMap.add_action(remap_action)
	var events = InputMap.get_action_list(remap_action)
	for e in events:
		InputMap.action_erase_event(remap_action, e)
	var evt = InputEventKey.new()
	evt.set_scancode(scancode)
	InputMap.action_add_event(remap_action, evt)
	print(remap_action + ": ", InputMap.get_action_list(remap_action))
	state = 2
	cooldown = 1.5
	for k in get_tree().get_nodes_in_group("controls"):
		if k.name == remap_action:
			k.text = OS.get_scancode_string(scancode)
	keymap.set_value("input", remap_action, InputMap.get_action_list(remap_action))
	print("val:", keymap.get_value("input", remap_action))
	keymap.save("user://settings.cfg")

func go_back():
	print("back pressed")
	var sc = load("res://ui/menu_root.tscn")
	get_tree().change_scene_to(sc)

func _ready():
	$"VBoxContainer/top/TextureButton".connect("pressed", self, "go_back")
	print(OS.get_user_data_dir())
	keymap = ConfigFile.new()
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
				for k in get_tree().get_nodes_in_group("controls"):
					if k.name == action:
						if evts is InputEventKey:
							k.text = OS.get_scancode_string(evts.scancode)
							k.update()
	for k in $VBoxContainer.get_children():
		k.connect("pressed", self, "control_setting", [k])
		var data = InputMap.get_action_list(k.name)
		print(data)
	$press_a_key.connect("keypress", self, "remap_key")
	$press_a_key.hide()
	finger_y = $press_a_key/indicator/finger.position.y
	button_y = $press_a_key/indicator/button.position.y
	noise = OpenSimplexNoise.new()
	noise.seed = OS.get_unix_time()
	noise.period = 30.0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
var sine_param = 0.0
func _process(delta):
	if state == 1:
		sine_param += delta * 0.1
		var sine = (button_y - finger_y) * 2.0 * noise.get_noise_2d(sine_param * 800.0, 0.0)
		print(sine)
		if sine > 0:
			$press_a_key/indicator/button.position.y = sine + button_y
		$press_a_key/indicator/finger.position.y = sine + finger_y
	if state == 2:
		if cooldown > 0.0:
			cooldown -= delta
		else:
			state = 0
