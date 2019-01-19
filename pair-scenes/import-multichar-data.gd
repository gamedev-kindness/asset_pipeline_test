tool
extends EditorScenePostImport

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
	f.open("res://multichar_scenes/" + scname + ".json", f.WRITE)
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
				var kill_list = []
				for anim in al:
					var ar: Animation = ap.get_animation(anim)
					print("Anim: ", anim, " Track count: ", ar.get_track_count())
					for t in range(ar.get_track_count()):
						var tt = ar.track_get_type(t)
						var tp = String(ar.track_get_path(t))
						print("ORIGINAL track: ", t, " path: ", tp)
						if false:
							var tdata = ar.track_get_key_count(t)
							kill_list.push_back(t)
							print("will REMOVE track: ", t, " path: ", tp)
						else:
							tp = tp.replace(obj.name, ".")
							ar.track_set_path(t, tp)
							tp = String(ar.track_get_path(t))
							print("MODIFIED track: ", t, " path: ", tp)
					kill_list.sort()
					kill_list.invert()
					for id in kill_list:
						ar.remove_track(id)
						print("Removing track:", id)
					if !d.dir_exists("res://characters/" + ot):
						d.make_dir("res://characters/" + ot)
					ResourceSaver.save("res://characters/" + ot + "/" + anim + ".anim", ar)
					scanims[obj.name].anims.push_back("res://characters/" + ot + "/" + anim + ".anim")
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
	print(scname)
	return scene # remember to return the imported scene

