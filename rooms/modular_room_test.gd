extends Spatial
onready var modules = [
#		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/corridoor_module.tscn"),
		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/bedroom_module2.tscn"),
		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/bedroom_module2.tscn"),
		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/bedroom_module2.tscn"),
		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/bedroom_module2.tscn"),
		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/corridoor_module.tscn"),
		load("res://rooms/corridoor_module.tscn"),
		load("res://rooms/corridoor_module.tscn"),
		load("res://rooms/bedroom_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn"),
		load("res://rooms/corridoor_cross_module.tscn")
]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var room_queue = []
var module_aabbs = []
var module_attachments = []
var scene_aabbs = []
var noise
func _ready():
	noise = OpenSimplexNoise.new()
	noise.seed = OS.get_unix_time()
	noise.octaves = 1
	noise.period = 3.0
	for mc in modules:
		var i = mc.instance()
		module_aabbs.push_back(calc_aabb(i))
		var attachments = []
		for a in i.get_children():
			if a.is_in_group("attachment"):
				attachments.push_back(a.transform)
		module_attachments.push_back(attachments)
	room_queue.push_back({"m": modules[0], "t": Transform(), "a": module_attachments[0], "p": "corridoor"})
	scene_aabbs.push_back(module_aabbs[0])
	print("module aabbs:")
	print(module_aabbs)
	print("module aabbs end")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func calc_aabb(d):
	var queue = [{"o": d, "t": Transform()}]
	var r = null
	while queue.size() > 0:
		var cur = queue[0].o
		var cur_t = queue[0].t
		queue.pop_front()
		if cur is MeshInstance:
			if r == null:
				r = (cur_t * cur.transform).xform(cur.get_aabb())
			else:
				r = r.merge((cur_t * cur.transform).xform(cur.get_aabb()))
		for c in cur.get_children():
			queue.push_back({"o": c, "t": cur_t * cur.transform})
	if r != null:
		r = r.grow(-0.2)
	return r
		
const max_per_frame = 20
const max_rooms = 40
var preferred_dims = Vector2(40, 20)
var room_count = 0
var complete = false
func _process(delta):
	var count = 0
	if complete:
		return
	while room_queue.size() > 0 && count < max_per_frame && room_count < max_rooms:
		print("yumyum")
		count += 1
		var current = room_queue[0]
		room_queue.pop_front()
		if abs(current.t.origin.x) > preferred_dims.x:
			continue
		if abs(current.t.origin.z) > preferred_dims.y:
			continue
		var attachments = current.a
		var r = current.m.instance()
		add_child(r)
		r.transform = current.t
		var idf = noise.get_noise_3dv(r.global_transform.origin)
		var cid = int(inverse_lerp(-1, 1, idf) * modules.size())
		room_count += 1
		var module = modules[cid]
		print(cid)
		for a in attachments:
			for ba in module_attachments[cid]:
				var placed = false
				for art in [0, PI / 2.0, - PI / 2.0, PI]:
					var at = Transform(Quat(Vector3(0, 1, 0), art))
					var bat = ba * at
					var aabb = (current.t * a  * bat.inverse()).xform(module_aabbs[cid])
#					print(aabb)
					var ok = true
					for s in scene_aabbs:
						if aabb.intersects(s):
							ok = false
							break
					if ok:
						room_queue.push_back({"m": module, "t": current.t * a  * bat.inverse(), "a": module_attachments[cid]})
						scene_aabbs.push_back(aabb)
						placed = true
						break
	print("sz: ", room_queue.size())
	print("rc: ", room_count)
	if room_count >= max_rooms || room_queue.size() == 0:
		for k in get_tree().get_nodes_in_group("beds"):
			k.emit_signal("spawn")
		print("SPAWN complete")
		complete = true
#					else:
#						print(aabb)
#					if placed:
#						break
#	print("scene aabbs:")
#	print(scene_aabbs)
