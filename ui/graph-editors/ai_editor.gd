extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const data_path = "res://ui/graph-editors/ai-nodes.json"
const ai_path = "res://characters/AI/states/"
# Called when the node enters the scene tree for the first time.
var json = {}
func _ready():
	var jf = File.new()
	jf.open(data_path, File.READ)
	var json_req = JSON.parse(jf.get_as_text())
	json = json_req.result
	jf.close()
	print(json)
	for k in json.modules.keys():
		var p = Label.new()
		p.text = k
		$v.add_child(p)
		for l in json.modules[k].keys():
			var b = Button.new()
			b.text = l
			$v.add_child(b)
			var load_path = ai_path + l + ".gd"
			print(load_path)
			var script:GDScript = load(load_path)
			var instance = script.new()
			for k in instance.get_property_list():
				if (k.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
					print(k.name, " ", k.type)
			instance.free()
			
