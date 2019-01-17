extends Spatial
#onready var modules = [
#		load("res://rooms/bedroom_module.tscn"),
#		load("res://rooms/lobby_corridoors.tscn"),
#		load("res://rooms/bedroom_module.tscn"),
#		load("res://rooms/bedroom_module.tscn"),
#		load("res://rooms/bedroom_module2.tscn"),
#		load("res://rooms/bedroom_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/bedroom_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/bedroom_module2.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/bedroom_module.tscn"),
#		load("res://rooms/bedroom_module2.tscn"),
#		load("res://rooms/bedroom_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/bedroom_module2.tscn"),
#		load("res://rooms/bedroom_module.tscn"),
#		load("res://rooms/bathroom_module.tscn"),
#		load("res://rooms/bathroom_module.tscn"),
#		load("res://rooms/bathroom_module.tscn"),
#		load("res://rooms/bathroom_module.tscn"),
#		load("res://rooms/bedroom_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/corridoor_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/bedroom_passable_module.tscn"),
#		load("res://rooms/corridoor_cross_module.tscn")
#]

#onready var axiom = load("res://rooms/lobby.tscn")

onready var rooms = {
	"axiom": "lobby",
	"lobby": {
		"module": load("res://rooms/lobby.tscn"),
		"connections": ["lobby_corridoors"],
		"attachments": [],
		"priority": 1,
		"min_floor": 1,
		"max_floor": 1
	},
	"lobby_corridoors": {
		"module": load("res://rooms/lobby_corridoors.tscn"),
		"connections": ["lobby", "corridoor_segment2", "lobby_corridoors"],
		"attachments": [],
		"priority": 2,
		"min_floor": 1,
		"max_floor": 1
	},
	"corridoor_segment2": {
		"module": load("res://rooms/corridoor_module.tscn"),
		"connections": ["corridoor_segment2", "corridoor_segment2", "corridoor_segment2", "stairs_internal", "stairs_internal","stairs_internal","bedroom", "bedroom2", "bathroom","bedroom", "bedroom2", "bathroom"],
		"attachments": [],
		"priority": 3
	},
	"stairs_internal": {
		"module": load("res://rooms/stairs_internal_module.tscn"),
		"connections": ["stairs_internal", "stairs_internal", "corridoor_segment", "bedroom", "bedroom2", "bathroom"],
		"attachments": [],
		"max_floor": 4,
		"priority": 4
	},
	"corridoor_segment": {
		"module": load("res://rooms/corridoor_module.tscn"),
		"connections": ["corridoor_segment", "corridoor_segment","corridoor_segment","corridoor_segment","corridoor_segment","corridoor_segment","corridoor_cross", "passable_bedroom"],
		"attachments": [],
		"priority": 4
	},
	"corridoor_cross": {
		"module": load("res://rooms/corridoor_cross_module.tscn"),
		"connections": ["corridoor_segment", "passable_bedroom", "bedroom"],
		"attachments": [],
		"priority": 4
	},
	"passable_bedroom": {
		"module": load("res://rooms/bedroom_passable_module.tscn"),
		"connections": ["corridoor_segment", "corridoor_cross"],
		"attachments": [],
		"max_floor": 2,
		"min_floor": 2,
		"priority": 5
	},
	"bedroom": {
		"module": load("res://rooms/bedroom_module.tscn"),
		"connections": ["corridoor_segment", "corridoor_cross"],
		"attachments": [],
		"priority": 5,
		"max_floor": 2,
		"min_floor": 2
	},
	"bedroom2": {
		"module": load("res://rooms/bedroom_module2.tscn"),
		"connections": ["corridoor_segment", "corridoor_cross"],
		"attachments": [],
		"priority": 5,
		"max_floor": 2,
		"min_floor": 2
	},
	"bathroom": {
		"module": load("res://rooms/bathroom_module.tscn"),
		"connections": ["corridoor_segment", "corridoor_cross"],
		"attachments": [],
		"priority": 5
	},
	"checks": {
		"bedroom": 2,
		"bathroom": 2,
		"bedroom2": 1,
		"stairs_internal": 1
	}
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var room_queue = []
var scene_aabbs = []
var instances = []
var noise

func prepare_stage(rooms):
	room_queue.clear()
	scene_aabbs.clear()
	while instances.size() > 0:
		var r = instances[0]
		instances.remove(0)
		r.queue_free()
	for data in rooms.keys():
		if data == "axiom":
			continue
		if data == "checks":
			continue
		var mc = rooms[data].module
		var i = mc.instance()
		rooms[data].aabb = calc_aabb(i)
		var attachments = []
		for a in i.get_children():
			if a.is_in_group("attachment") && !a.is_in_group("next"):
				attachments.push_back(a.transform)
		rooms[data].attachments = attachments
		print(mc.resource_path)
		var axiom_name = rooms.axiom
		room_queue.push_back({"m": axiom_name, "t": Transform(), "a": rooms[axiom_name].attachments, "aabb": rooms[axiom_name].aabb, "p": rooms[axiom_name].priority})

func _ready():
	noise = OpenSimplexNoise.new()
	noise.seed = OS.get_unix_time()
	noise.octaves = 1
	noise.period = 3.0
#	print("modules: ", modules)
	prepare_stage(rooms)
#	for mc in modules:
#		var i = mc.instance()
#		module_aabbs.push_back(calc_aabb(i))
#		var attachments = []
#		for a in i.get_children():
#			if a.is_in_group("attachment"):
#				attachments.push_back(a.transform)
#		module_attachments.push_back(attachments)
#	print("axiom attachments: ", module_attachments[axiom.resource_path].size())
#	scene_aabbs.push_back(rooms[axiom_name].aabb)
#	print("module aabbs:")
#	print(module_aabbs)
#	print("module aabbs end")

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
#	print("aabb:", r, "module: ", d.name)
	return r
		
const max_per_frame = 120
const max_rooms = 300
var preferred_dims = Vector3(50, 120, 50)
var room_count = 0
var complete = false
var floor_height = 3.0
func check_constraints(item):
	var current = item
	if abs(current.t.origin.x) > preferred_dims.x:
		return false
	if abs(current.t.origin.y) > preferred_dims.y:
		return false
	if abs(current.t.origin.z) > preferred_dims.z:
		return false
	var floor_num = floor(current.t.origin.y / floor_height) + 1
	if rooms[current.m].has("min_floor"):
		if floor_num < rooms[current.m].min_floor:
			return false
	if rooms[current.m].has("max_floor"):
		if floor_num > rooms[current.m].max_floor:
			return false
	var current_aabb = current.aabb
	var ok = true
	for s in scene_aabbs:
		if current_aabb.intersects(s):
			ok = false
			break
	if !ok:
		return false
	return true
func select_module(rooms, item):
	var idf = noise.get_noise_3dv((global_transform * item.t).origin)
	var rs = rooms[item.m].connections
	if rs.size() == 0:
		return null
	var cid = int(inverse_lerp(-1, 1, idf) * rs.size())
	return rs[cid]
	
func _process(delta):
	var count = 0
	if complete:
		return
	while room_queue.size() > 0 && count < max_per_frame && room_count < max_rooms:
		count += 1
		var current = room_queue[0]
		room_queue.pop_front()
		if current.p > 0:
			current.p = current.p - 1
			room_queue.push_back(current)
			continue
		if !check_constraints(current):
			continue
		scene_aabbs.push_back(current.aabb)
		var attachments = current.a
		var r = rooms[current.m].module.instance()
#		print(current.m.resource_path, " ", room_queue.size(), " ", current.a.size())
		add_child(r)
		r.transform = current.t
		r.add_to_group(current.m)
		instances.push_back(r)
		var cid = select_module(rooms, current)
		room_count += 1
		if cid == null:
			continue
		var module = rooms[cid].module
		for a in attachments:
			print("attachment")
			for ba in rooms[cid].attachments:
				var placed = false
				for art in [0, PI / 2.0, - PI / 2.0, PI]:
					var at = Transform(Quat(Vector3(0, 1, 0), art))
					var bat = ba * at
					var aabb = (current.t * a  * bat.inverse()).xform(rooms[cid].aabb)
#					print(aabb)
					var ok = true
					for s in scene_aabbs:
						if aabb.intersects(s):
							ok = false
							break
					if ok:
						room_queue.push_back({"m": cid, "t": current.t * a  * bat.inverse(), "a": rooms[cid].attachments, "aabb": aabb, "p": rooms[cid].priority})
						placed = true
#						print("last aabb:", aabb, " scene_aabbs: ", scene_aabbs)
						break
	if room_count >= max_rooms || room_queue.size() == 0:
		var good = true
		for h in rooms.checks.keys():
			if get_tree().get_nodes_in_group(h).size() < rooms.checks[h]:
				good = false
				break
		if !good:
			room_queue.clear()
			noise.seed = OS.get_unix_time()
			prepare_stage(rooms)
			room_count = 0
			count = 0
		else:
			for k in get_tree().get_nodes_in_group("beds"):
				k.emit_signal("spawn")
			print("SPAWN complete")
			complete = true
