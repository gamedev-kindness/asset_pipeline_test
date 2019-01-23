tool
extends EditorScenePostImport

var json_conf_name = "res://pair-scenes/anim_config.json"
func post_import(scene):
	var anim_config = File.new()
	anim_config.open(json_conf_name, anim_config.READ)
	var json = JSON.parse(anim_config.get_as_text())
	var anim_confdata = json.result
	anim_config.close()
	var anim_player: AnimationPlayer = scene.get_children()[0].get_node("AnimationPlayer")
	for action in anim_confdata.keys():
		print("action: ", action)
		for ot in anim_confdata[action].keys():
			for d in anim_confdata[action][ot]:
				print(d)
				if !anim_player.has_animation(d.name):
					anim_player.add_animation(d.name, load(d.path))
				else:
					anim_player.add_animation(action + "_" + ot + "_" + d.name, load(d.path))
				print("ok")
	return scene
