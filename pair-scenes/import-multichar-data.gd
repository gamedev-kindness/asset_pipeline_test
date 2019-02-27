tool
extends EditorScenePostImport

var action_list : = {}

func add_anim_action(anim):
	var action_name = ImporterCommon.get_action_name(anim)
	if action_list.has(action_name):
		action_list[action_name].push_back(anim)
	else:
		action_list[action_name] = [anim]

func create_blend_tree(anim: String) -> AnimationNodeBlendTree:
	var blend_tree : = AnimationNodeBlendTree.new()
	var anim_node : = AnimationNodeAnimation.new()
	anim_node.animation = anim
	var anim_node_name = ImporterCommon.get_anim_node_name(anim)
	blend_tree.add_node(anim_node_name, anim_node, Vector2())
	blend_tree.connect_node("output", 0, anim_node_name)
	return blend_tree
func action_conf_add(kname: String, data: Dictionary) -> void:
	var f = File.new()
	var actions_conf_data: Dictionary
	var actions_conf_path = "res://characters/actions/actions.json"
	if f.file_exists(actions_conf_path):
		f.open(actions_conf_path, f.READ)
		var json = JSON.parse(f.get_as_text())
		actions_conf_data = json.result
		f.close()
	else:
		actions_conf_data = {}
	actions_conf_data[kname] = data
	f.open(actions_conf_path, f.WRITE)
	f.store_string(JSON.print(actions_conf_data, "\t", true))
	f.close()
func action_list_add(data: Dictionary) -> void:
	var f = File.new()
	var actions_list_data: Dictionary
	var actions_list_path = "res://characters/actions/action_tree.json"
	if f.file_exists(actions_list_path):
		f.open(actions_list_path, f.READ)
		var json = JSON.parse(f.get_as_text())
		actions_list_data = json.result
		f.close()
	else:
		actions_list_data = {}
	for k in data.keys():
		actions_list_data[k] = data[k]
	f.open(actions_list_path, f.WRITE)
	f.store_string(JSON.print(actions_list_data, "\t", true))
	f.close()
func append_state_machine(sm_name: String, sm_path:String, state_machine: AnimationNode) -> void:
	var f = File.new()
	print("Working with: ", sm_path, " ", sm_name)
	var sm: AnimationNodeStateMachine
	if f.file_exists(sm_path):
		sm = load(sm_path)
	else:
		sm = AnimationNodeStateMachine.new()
	if !ImporterCommon.sm_has_state(sm, sm_name):
		print("Creating and storing")
		sm.add_node(sm_name, state_machine, Vector2(100.0 + randf() * 30.0, 30.0))
		ResourceSaver.save(sm_path, sm)

func get_name_level(kname: String) ->int:
	if kname.find("@") < 0:
		return 0
	else:
		return kname.split("@").size() - 1

func create_state_machine(kname: String, anim_data: Dictionary) -> AnimationNodeStateMachine:
		var state_machine : = AnimationNodeStateMachine.new()
		var position = Vector2(1, 1)
		var have_start = false
		var have_loop = false
		var have_end = false
		var have_end_failure = false
		var random_anims = []
		var oneshot_anims = []
		var struggle_anims = []
		var children = []
		for anim in action_list[kname]:
			var blend_tree : = create_blend_tree(anim)
			var anim_node_name = ImporterCommon.get_anim_node_name(anim)
			state_machine.add_node(anim_node_name, blend_tree, position)
			if anim_node_name == "start":
				have_start = true
			elif anim_node_name == "loop":
				have_loop = true
			elif anim_node_name == "end":
				have_end = true
			elif anim_node_name == "end-failure":
				have_end_failure = true
			elif anim_node_name.begins_with("random"):
				random_anims.push_back(anim_node_name)
			elif anim_node_name.begins_with("oneshot"):
				oneshot_anims.push_back(anim_node_name)
			elif anim_node_name.begins_with("struggle"):
				struggle_anims.push_back(anim_node_name)
			if randf() > 0.5:
				position += Vector2(130.0, 0.0)
			else:
				position += Vector2(0.0, 130.0)
		if have_start:
			state_machine.set_start_node("start")
		if have_end:
			state_machine.set_end_node("end")
		if !have_start && have_loop:
			state_machine.set_start_node("loop")
		if !have_loop && have_start && have_end:
			var transition : = AnimationNodeStateMachineTransition.new()
			transition.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
			state_machine.add_transition("start", "end", transition)
		elif have_loop && have_start && have_end:
			var transition1 : = AnimationNodeStateMachineTransition.new()
			transition1.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
			transition1.auto_advance = true
			state_machine.add_transition("start", "loop", transition1)
			var transition2 : = AnimationNodeStateMachineTransition.new()
			transition2.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
			state_machine.add_transition("loop", "end", transition2)
		elif have_loop && have_start && !have_end:
			var transition1 : = AnimationNodeStateMachineTransition.new()
			transition1.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
			transition1.auto_advance = true
			state_machine.add_transition("start", "loop", transition1)
		elif !have_loop && have_start && !have_end:
			state_machine.set_end_node("start")
		if have_start && have_end_failure:
			var transition1 : = AnimationNodeStateMachineTransition.new()
			transition1.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
			state_machine.add_transition("start", "end-failure", transition1)
		if have_start || have_loop:
			var main_node = "loop"
			if !have_loop:
				main_node = "start"
			for k in random_anims + oneshot_anims:
				var transition1 : = AnimationNodeStateMachineTransition.new()
				transition1.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
				state_machine.add_transition(main_node, k, transition1)
				var transition2 : = AnimationNodeStateMachineTransition.new()
				transition2.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
				state_machine.add_transition(k, main_node, transition2)
		if have_end_failure || have_loop || have_end || have_start:
			var main_node = "loop"
			if !have_loop && have_start:
				main_node = "start"
			elif !have_start && have_end:
				main_node = "end"
			for k in struggle_anims:
				var transition1 : = AnimationNodeStateMachineTransition.new()
				transition1.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
				state_machine.add_transition(main_node, k, transition1)
				var transition2 : = AnimationNodeStateMachineTransition.new()
				transition2.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
				state_machine.add_transition(k, main_node, transition2)
				if have_end_failure:
					var transition_ef : = AnimationNodeStateMachineTransition.new()
					transition_ef.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
					state_machine.add_transition(k, "end-failure", transition_ef)
		var name_level = get_name_level(kname)
		var children_data = {}
		for h in action_list.keys():
			if h.begins_with(kname + "@") && get_name_level(h) == name_level + 1:
				print("Child: ", h)
				var child_data = {}
				var child = create_state_machine(h, child_data)
				state_machine.add_node(h, child, position)
				if randf() > 0.5:
					position.x += 130.0
				else:
					position.y += 130.0
				var main_node = "loop"
				if !have_loop:
					main_node = "start"
				var transition1 : = AnimationNodeStateMachineTransition.new()
				transition1.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
				state_machine.add_transition(main_node, h, transition1)
				var transition2 : = AnimationNodeStateMachineTransition.new()
				transition2.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
				state_machine.add_transition(h, main_node, transition2)
				children.push_back(h)
				children_data[h] = child_data
		anim_data.oneshot = oneshot_anims
		anim_data.random = random_anims
		anim_data.struggle = struggle_anims
		anim_data.children = children
		anim_data.children_data = children_data
		return state_machine


func create_state_machines():
	print("Creating state machines for actions")
	var sms = ["res://characters/animtree_male_generated.tres", "res://characters/animtree_female_generated.tres"]
	var f : = File.new()
	var anim_data_list = {}
	for k in action_list.keys():
		if get_name_level(k) != 0:
			continue
		var fp = "res://characters/actions/action_" + k.to_lower() + ".tres"
#		if f.file_exists(fp):
#			continue
		var anim_data = {}
		var state_machine : = create_state_machine(k, anim_data)
#		var position = Vector2(1, 1)
#		var have_start = false
#		var have_loop = false
#		var have_end = false
#		for anim in action_list[k]:
#			var blend_tree : = create_blend_tree(anim)
#			var anim_node_name = ImporterCommon.get_anim_node_name(anim)
#			state_machine.add_node(anim_node_name, blend_tree, position)
#			if anim_node_name == "start":
#				have_start = true
#			elif anim_node_name == "loop":
#				have_loop = true
#			elif anim_node_name == "end":
#				have_end = true
#			if randf() > 0.5:
#				position += Vector2(20.0, 0.0)
#			else:
#				position += Vector2(0.0, 20.0)
#		if have_start:
#			state_machine.set_start_node("start")
#		if have_end:
#			state_machine.set_end_node("end")
#		if !have_loop && have_start && have_end:
#			var transition : = AnimationNodeStateMachineTransition.new()
#			transition.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
#			state_machine.add_transition("start", "end", transition)
#		elif have_loop && have_start && have_end:
#			var transition1 : = AnimationNodeStateMachineTransition.new()
#			transition1.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
#			transition1.auto_advance = true
#			state_machine.add_transition("start", "loop", transition1)
#			var transition2 : = AnimationNodeStateMachineTransition.new()
#			transition2.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
#			state_machine.add_transition("loop", "end", transition2)
#		elif have_loop && have_start && !have_end:
#			var transition1 : = AnimationNodeStateMachineTransition.new()
#			transition1.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
#			transition1.auto_advance = true
#			state_machine.add_transition("start", "loop", transition1)
#		elif !have_loop && have_start && !have_end:
#			state_machine.set_end_node("start")
##		var actions_conf_path = "res://characters/actions/actions.json"
##		var actions_conf_data: Dictionary
##		if f.file_exists(actions_conf_path):
##			f.open(actions_conf_path, f.READ)
##			var json = JSON.parse(f.get_as_text())
##			actions_conf_data = json.result
##			f.close()
##		else:
##			actions_conf_data = {}
		var conf_data = {
			"name": k,
			"path": "res://characters/actions/action_" + k.to_lower() + ".tres"
		}
		action_conf_add(k, conf_data)
		ResourceSaver.save("res://characters/actions/action_" + k.to_lower() + ".tres", state_machine)
#		f.open(actions_conf_path, f.WRITE)
#		f.store_string(JSON.print(actions_conf_data, "\t", true))
#		f.close()
		for sm_path in sms:
			append_state_machine(k, sm_path, state_machine)
		anim_data_list[k] = anim_data
#			print("Working with: ", sm_path, " ", k)
#			var sm: AnimationNodeStateMachine
#			if f.file_exists(sm_path):
#				sm = load(sm_path)
#			else:
#				sm = AnimationNodeStateMachine.new()
#			if !ImporterCommon.sm_has_state(sm, k):
#				print("Creating and storing")
#				sm.add_node(k, state_machine, Vector2(100.0 + randf() * 30.0, 30.0))
#				if have_start:
#					var transition1 : = AnimationNodeStateMachineTransition.new()
#					transition1.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
#					sm.add_transition("Stand", k, transition1)
#					var transition2 : = AnimationNodeStateMachineTransition.new()
#					if have_loop:
#						transition2.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
#					else:
#						transition2.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
#					sm.add_transition(k, "Stand", transition2)
#				ResourceSaver.save(sm_path, sm)
	return anim_data_list
var json_conf_name = "res://pair-scenes/anim_config.json"
func post_import(scene):
	# do your stuff here
	var name_prefix = scene.name + "_"
	var queue = [scene]
	var remove = []
	var scname = scene.filename.get_basename().get_file()
	var d = Directory.new()
	if !d.dir_exists("res://multichar_scenes"):
		d.make_dir("res://multichar_scenes")
	var f = File.new()
	var anim_config = File.new()
	anim_config.open(json_conf_name, f.READ)
	var json = JSON.parse(anim_config.get_as_text())
	var anim_confdata = json.result
	anim_config.close()
	f.open("res://multichar_scenes/" + scname + ".json", f.WRITE)
	var scanims = {}
#	var female_scene = load("res://characters/female_2018.escn")
#	var female_scene_instance = female_scene.instance()
#	var female_scene_ap: AnimationPlayer = female_scene_instance.get_children()[0].get_node("AnimationPlayer")
#	var male_scene = load("res://characters/female_2018.escn")
#	var male_scene_instance = male_scene.instance()
#	var male_scene_ap: AnimationPlayer = male_scene_instance.get_children()[0].get_node("AnimationPlayer")
	while queue.size() > 0:
		var obj = queue[0]
		if obj is Skeleton:
			print("Skeleton: ", obj.name)
			var ot = ""
			if obj.name.begins_with("male"):
				ot = "male"
			elif obj.name.begins_with("female"):
				ot = "female"
			print("Type: ", ot)
			var ap = obj.get_node("AnimationPlayer")
			if ap == null:
				ap = obj.get_node("../AnimationPlayer")
			scanims[obj.name] = {"type": ot, "anims": [], "transform": obj.transform}
			if !anim_confdata.has(scname):
				anim_confdata[scname] = {}
			anim_confdata[scname][ot] = []
			if ap != null:
				print(ap.assigned_animation)
				print(ap.current_animation)
				print(ap.autoplay)
				print(ap.get_animation_list())
				var al = ap.get_animation_list()
				var kill_list = []
				for anim in al:
					var ar: Animation = ap.get_animation(anim)
					print("Anim: ", anim, " Track count: ", ar.get_track_count())
					add_anim_action(anim)
#					for t in range(ar.get_track_count()):
#						var tt = ar.track_get_type(t)
#						var tp = String(ar.track_get_path(t))
#						print("ORIGINAL track: ", t, " path: ", tp)
#						if false:
#							var tdata = ar.track_get_key_count(t)
#							kill_list.push_back(t)
#							print("will REMOVE track: ", t, " path: ", tp)
#						else:
#							tp = tp.replace(obj.name, ".")
#							ar.track_set_path(t, tp)
#							tp = String(ar.track_get_path(t))
#							print("MODIFIED track: ", t, " path: ", tp)
#					kill_list.sort()
#					kill_list.invert()
#					for id in kill_list:
#						ar.remove_track(id)
#						print("Removing track:", id)
					if !d.dir_exists("res://characters/" + ot):
						d.make_dir("res://characters/" + ot)
					ResourceSaver.save("res://characters/" + ot + "/" + anim + ".anim", ar)
#					female_scene_ap.add_animation(anim, ar)
#					male_scene_ap.add_animation(anim, ar)
					scanims[obj.name].anims.push_back("res://characters/" + ot + "/" + anim + ".anim")
					anim_confdata[scname][ot].push_back({"name": anim, "path": "res://characters/" + ot + "/" + anim + ".anim"})
					
						
			remove.push_back(obj)
		queue.pop_front()
		for k in obj.get_children():
			queue.push_back(k)
	for k in remove:
		for l in k.get_children():
			l.queue_free()
		var n = Spatial.new()
		n.name = k.name
		k.replace_by(n)
	f.store_string(var2str(scanims))
	f.close()
#	print(scname)
#	print(JSON.print(anim_confdata, "\t", true))
	var anim_configw = File.new()
	anim_configw.open(json_conf_name, f.WRITE)
	anim_configw.store_string(JSON.print(anim_confdata, "\t", true))
#	var female_data = PackedScene.new()
#	female_data.pack(female_scene_instance)
#	var male_data = PackedScene.new()
#	male_data.pack(female_scene_instance)
#	ResourceSaver.save("res://characters/female_2018_saved.tscn", female_data)
#	ResourceSaver.save("res://characters/male_2018_saved.tscn", male_data)
	var anim_data = create_state_machines()
	action_list_add(anim_data)
	d.open("res://.import")
	d.list_dir_begin()
	var fn = d.get_next()
	while fn != "":
		if fn.find("female_2018.escn") >= 0 || fn.find("male_2018.escn") >= 0:
			if fn.ends_with(".scn") || fn.ends_with(".md5"):
				d.remove(fn)
		fn = d.get_next()
	return scene # remember to return the imported scene

