tool
extends EditorScenePostImport
var clothes = {}
var data_path = "res://characters/clothes/clothes.json"
func post_import(scene):
	var jf : = File.new()
	jf.open(data_path, File.READ)
	var json_req = JSON.parse(jf.get_as_text())
	clothes = json_req.result
	jf.close()
	if !clothes:
		clothes = {}
	var d : = Directory.new()
	var scname = scene.filename.get_basename().get_file()
	var gender = "any"
	if scname.begins_with("female"):
		gender = "female"
	elif scname.begins_with("male"):
		gender = "male"
	print(gender)
	var export_path = "res://characters/clothes/" + gender
	var mesh_prefixes = ["hair", "dress", "panties", "bra", "top", "bottom", "shoes"]
	var queue = [scene]
	var set = []
	while queue.size() > 0:
		var item = queue[0]
		queue.pop_front()
		if item is MeshInstance:
			var mesh = item.mesh
			for k in mesh_prefixes:
				if mesh.resource_name.begins_with(k + "_"):
					print(mesh.resource_name)
					if !d.dir_exists(export_path + "/" + k):
						d.make_dir_recursive(export_path + "/" + k)
					var save_path = export_path + "/" + k + "/" + mesh.resource_name + ".mesh"
					ResourceSaver.save(save_path, mesh)
					if !clothes.has(gender):
						clothes[gender] = {}
					if !clothes[gender].has(k):
						clothes[gender][k] = []
					clothes[gender][k].push_back({"name": mesh.resource_name, "path": save_path})
					set.push_back(k + "/" + mesh.resource_name)
					item.queue_free()
		for c in item.get_children():
			queue.push_back(c)
	if !clothes.has("sets"):
		clothes.sets = {}
	if !clothes.sets.has(gender):
		clothes.sets[gender] = []
	var set_name = "Unnamed set"
	var sname = scname.split("_")
	if sname.size() >= 3:
			set_name = sname[2].replace("-", " ")
	clothes.sets[gender].push_back({"name": set_name, "clothes": set})
	jf.open(data_path, jf.WRITE)
	jf.store_string(JSON.print(clothes, "\t", true))
	jf.close()

	return scene
