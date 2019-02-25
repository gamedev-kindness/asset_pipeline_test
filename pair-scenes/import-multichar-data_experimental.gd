tool
extends EditorScenePostImport

var action_list : = {}
func get_action_name(name: String):
	if name.find("_") < 0:
		return name
	return name.split("_")[0].capitalize()
func get_anim_node_name(name: String):
	if name.find("_") < 0:
		return name
	var data = name.split("_")
	if data[1] == "oneshot":
		return data[1] + "_" + data[2]
	return name.split("_")[1].to_lower()

func add_anim_action(anim):
	var action_name = get_action_name(anim)
	if action_list.has(action_name):
		action_list[action_name].push_back(anim)
	else:
		action_list[action_name] = [anim]

func create_state_machines():
	var f : = File.new()
	for k in action_list.keys():
		var fp = "res://characters/actions/action_" + k.to_lower() + ".tres"
		if f.file_exists(fp):
			continue
		var state_machine : = AnimationNodeStateMachine.new()
		var position = Vector2(1, 1)
		var have_start = false
		var have_loop = false
		var have_end = false
		for anim in action_list[k]:
			var blend_tree : = AnimationNodeBlendTree.new()
			var anim_node : = AnimationNodeAnimation.new()
			anim_node.animation = anim
			var anim_node_name = get_anim_node_name(anim)
			blend_tree.add_node(anim_node_name, anim_node, Vector2())
			blend_tree.connect_node("output", 0, anim_node_name)
			state_machine.add_node(anim_node_name, blend_tree, position)
			if anim_node_name == "start":
				have_start = true
			elif anim_node_name == "loop":
				have_loop = true
			elif anim_node_name == "end":
				have_end = true
			if randf() > 0.5:
				position += Vector2(20.0, 0.0)
			else:
				position += Vector2(0.0, 20.0)
		if have_start:
			state_machine.set_start_node("start")
		if have_end:
			state_machine.set_end_node("end")
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
		elif !have_loop && have_start && !have_end:
			state_machine.set_end_node("start")
		
		ResourceSaver.save("res://characters/actions/action_" + k.to_lower() + ".tres", state_machine)
func process_animation(anim: String, ot: String, obj: Object, d: Directory, ar: Animation):
				var kill_list = []
				print("Anim: ", anim, " Track count: ", ar.get_track_count())
				print("Action: ", get_action_name(anim))
				add_anim_action(anim)
				for t in range(ar.get_track_count()):
					var tt = ar.track_get_type(t)
					var tp = String(ar.track_get_path(t))
					if false:
						var tdata = ar.track_get_key_count(t)
						kill_list.push_back(t)
					else:
						tp = tp.replace(obj.name, ".")
						ar.track_set_path(t, tp)
						tp = String(ar.track_get_path(t))
				kill_list.sort()
				kill_list.invert()
				for id in kill_list:
					ar.remove_track(id)
					print("Removing track:", id)
				if !d.dir_exists("res://characters/" + ot):
					d.make_dir("res://characters/" + ot)
				ResourceSaver.save("res://characters/" + ot + "/" + anim + ".anim", ar)
func post_import(scene):
	var name_prefix = scene.name + "_"
	var queue = [scene]
	var remove = []
	var scname = scene.filename.get_basename().get_file()
	var d = Directory.new()
	if !d.dir_exists("res://multichar_scenes"):
		d.make_dir("res://multichar_scenes")
	var scanims = {}
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
			if ap != null:
				print(ap.assigned_animation)
				print(ap.current_animation)
				print(ap.autoplay)
				print(ap.get_animation_list())
				var al = ap.get_animation_list()
				for anim in al:
					var ar: Animation = ap.get_animation(anim)
					process_animation(anim, ot, obj, d, ar)
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
	print(action_list)
	create_state_machines()
	return scene # remember to return the imported scene
