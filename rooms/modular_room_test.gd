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
#		"connections": ["corridoor_segment1_stairs"],
		"connections": ["corridoor_segment_stairs_1"],
		"attachments": [],
		"priority": 1,
		"min_floor": 1,
		"max_floor": 1
	},
	"corridoor_cross_1": {
		"module": load("res://rooms/corridoor_cross_module.tscn"),
		"connections": ["corridoor_segment_stairs_1"],
		"attachments": [],
		"max_floor": 1,
		"min_floor": 1,
		"priority": 4
	},
	"corridoor_segment_stairs_1": {
		"module": load("res://rooms/corridoor_module.tscn"),
		"connections": ["corridoor_segment_stairs_1", "corridoor_segment_stairs_1", "stair", "bathroom", "corridoor_cross_1"],
		"attachments": [],
		"priority": 1,
		"max_floor": 1,
		"min_floor": 1
	},
	"corridoor_cross": {
		"module": load("res://rooms/corridoor_cross_module.tscn"),
		"connections": ["corridoor_segment_stairs_2", "corridoor_segment_stairs_3"],
		"attachments": [],
		"min_floor": 2,
		"priority": 4
	},
	"corridoor_segment_stairs_2": {
		"module": load("res://rooms/corridoor_module.tscn"),
		"connections": ["corridoor_segment_stairs_2", "corridoor_segment_stairs_2", "bedroom2", "bedroom2", "bathroom", "corridoor_cross"],
		"attachments": [],
		"priority": 1,
		"max_floor": 2,
		"min_floor": 2
	},
	"corridoor_segment_stairs_3": {
		"module": load("res://rooms/corridoor_module.tscn"),
		"connections": ["corridoor_segment_stairs_3", "corridoor_segment_stairs_3", "classroom", "bathroom", "corridoor_cross"],
		"attachments": [],
		"priority": 1,
		"min_floor": 3
	},
	"corridoor_segment_stairs_0": {
		"module": load("res://rooms/corridoor_module.tscn"),
		"connections": ["corridoor_segment_stairs_0", "corridoor_segment_stairs_0", "bathroom", "corridoor_cross"],
		"attachments": [],
		"priority": 1,
		"max_floor": 0
	},
	"stair": {
		"module": load("res://rooms/stairs_internal_module.tscn"),
		"connections": ["corridoor_segment_stairs_1", "corridoor_segment_stairs_2", "corridoor_segment_stairs_3"],
		"attachments": [],
		"priority": 2,
		"special": ["stair"]
	},
	"bathroom": {
		"module": load("res://rooms/bathroom_module.tscn"),
		"connections": ["corridoor_segment_stairs_1", "corridoor_segment_stairs_2", "corridoor_segment_stairs_3"],
		"attachments": [],
		"priority": 3
	},
	"classroom": {
		"module": load("res://rooms/classroom_module.tscn"),
		"connections": ["corridoor_segment_stairs_3"],
		"attachments": [],
		"priority": 1,
		"min_floor": 3
	},
	"bedroom": {
		"module": load("res://rooms/bedroom_module.tscn"),
		"connections": ["corridoor_segment_stairs_2"],
		"attachments": [],
		"priority": 3,
		"max_floor": 2,
		"min_floor": 2
	},
	"bedroom2": {
		"module": load("res://rooms/bedroom_module2.tscn"),
		"connections": ["corridoor_segment_stairs_2"],
		"attachments": [],
		"priority": 1,
		"max_floor": 2,
		"min_floor": 2
	},
#	"corridoor_segment_stairs_2": {
#		"module": load("res://rooms/corridoor_module.tscn"),
#		"connections": ["corridoor_segment_stairs_2", "bedroom", "bedroom2", "bathroom"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 2,
#		"min_floor": 2
#	},
#	"stair3": {
#		"module": load("res://rooms/stairs_internal_module.tscn"),
#		"connections": ["stair2"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 3,
#		"min_floor": 3
#	},
#	"corridoor_segment_stairs_3": {
#		"module": load("res://rooms/corridoor_module.tscn"),
#		"connections": ["corridoor_segment_stairs_3", "classroom_3", "bathroom"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 3,
#		"min_floor": 3
#	},
#	"corridoor_cross_3": {
#		"module": load("res://rooms/corridoor_cross_module.tscn"),
#		"connections": ["corridoor_segment_stairs_3"],
#		"attachments": [],
#		"max_floor": 3,
#		"min_floor": 3,
#		"priority": 1
#	},
#	"classroom_3": {
#		"module": load("res://rooms/classroom_module.tscn"),
#		"connections": ["corridoor_segment_stairs_3"],
#		"attachments": [],
#		"priority": 1,
#		"min_floor": 3
#	},
#
#
#
#	"corridoor_segment_rooms": {
#		"module": load("res://rooms/corridoor_module.tscn"),
#		"connections": ["corridoor_segment_rooms", "bedroom", "bathroom", "bedroom2"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 1,
#		"min_floor": 1
#	},
#	"stairs_internal_1": {
#		"module": load("res://rooms/stairs_internal_module.tscn"),
#		"connections": ["corridoor_segment_2_rooms"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 1,
#		"min_floor": 1
#	},
#	"corridoor_segment_2_rooms": {
#		"module": load("res://rooms/corridoor_module.tscn"),
#		"connections": ["corridoor_segment_2_rooms", "bedroom", "bathroom", "bedroom2"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 2,
#		"min_floor": 2
#	},
#	"corridoor_segment_2": {
#		"module": load("res://rooms/corridoor_module.tscn"),
#		"connections": ["corridoor_segment_2", "bedroom", "bathroom", "bedroom2"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 1,
#		"min_floor": 1
#	},
#	"corridoor_segment1_stairs": {
#		"module": load("res://rooms/corridoor_module.tscn"),
#		"connections": ["corridoor_segment1_stairs", "stairs_internal1"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 1,
#		"min_floor": 1
#	},
#	"stairs_internal1": {
#		"module": load("res://rooms/stairs_internal_module.tscn"),
#		"connections": ["corridoor_segment2"],
#		"attachments": [],
#		"priority": 2,
#		"max_floor": 1,
#		"min_floor": 1
#	},
#	"corridoor_segment1": {
#		"module": load("res://rooms/corridoor_module.tscn"),
#		"connections": ["corridoor_cross1", "bathroom"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 1,
#		"min_floor": 1
#	},
#	"corridoor_cross1": {
#		"module": load("res://rooms/corridoor_cross_module.tscn"),
#		"connections": ["corridoor_segment1", "corridoor_segment1_stairs"],
#		"attachments": [],
#		"max_floor": 1,
#		"min_floor": 1,
#		"priority": 4
#	},
#	"corridoor_segment2": {
#		"module": load("res://rooms/corridoor_module.tscn"),
#		"connections": ["corridoor_segment2", "bedroom", "bathroom", "bedroom2"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 2,
#		"min_floor": 2
#	},
#	"stairs_internal2": {
#		"module": load("res://rooms/stairs_internal_module.tscn"),
#		"connections": ["stairs_internal2", "stairs_internal2", "corridoor_segment"],
#		"attachments": [],
#		"min_floor": 1,
#		"priority": 20
#	},
#	"corridoor_segment": {
#		"module": load("res://rooms/corridoor_module.tscn"),
#		"connections": ["corridoor_segment", "corridoor_segment","corridoor_segment","corridoor_segment","corridoor_segment","corridoor_segment","corridoor_cross", "passable_bedroom", "classroom", "classroom", "classroom", "classroom", "classroom", "classroom", "classroom", "classroom", "classroom", "classroom", "classroom"],
#		"attachments": [],
#		"priority": 4
#	},
#	"corridoor_cross": {
#		"module": load("res://rooms/corridoor_cross_module.tscn"),
#		"connections": ["corridoor_segment", "passable_bedroom", "bedroom"],
#		"attachments": [],
#		"priority": 20
#	},
#	"passable_bedroom": {
#		"module": load("res://rooms/bedroom_passable_module.tscn"),
#		"connections": ["corridoor_segment", "corridoor_cross"],
#		"attachments": [],
#		"max_floor": 2,
#		"min_floor": 2,
#		"priority": 1
#	},
#	"bedroom": {
#		"module": load("res://rooms/bedroom_module.tscn"),
#		"connections": ["corridoor_segment", "corridoor_cross"],
#		"attachments": [],
#		"priority": 5,
#		"max_floor": 2,
#		"min_floor": 2
#	},
#	"bedroom2": {
#		"module": load("res://rooms/bedroom_module2.tscn"),
#		"connections": ["corridoor_segment", "corridoor_cross"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 2,
#		"min_floor": 2
#	},
#	"bathroom": {
#		"module": load("res://rooms/bathroom_module.tscn"),
#		"connections": ["corridoor_segment", "corridoor_cross"],
#		"attachments": [],
#		"priority": 1
#	},
#	"classroom": {
#		"module": load("res://rooms/classroom_module.tscn"),
#		"connections": ["corridoor_segment", "corridoor_cross"],
#		"attachments": [],
#		"priority": 1,
#		"max_floor": 3,
#		"min_floor": 3
#	},
	"checks": {
		"classroom": 5,
		"bathroom": 10,
		"beds": 5,
#		"bedroom2": 0,
#		"stairs_internal": 0
	},
	"config": {
		"min_floor": -15,
		"max_floor": 20
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
var rnd

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
		if data == "config":
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
	noise.octaves = 5
	noise.period = 20.0
	rnd = RandomNumberGenerator.new()
	rnd.seed = OS.get_unix_time()
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
var preferred_dims = Vector3(500, 520, 500)
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
	if floor_num > rooms.config.max_floor:
		return false
	if floor_num < rooms.config.min_floor:
		return false
	if rooms[current.m].has("min_floor"):
		if floor_num < rooms[current.m].min_floor - 1:
			return false
	if rooms[current.m].has("max_floor"):
		if floor_num > rooms[current.m].max_floor + 1:
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
	var idf = (noise.get_noise_3dv((global_transform * item.t).origin) + (rnd.randf() * 2.0 - 1)) / 2.0
	var floor_num = floor(item.t.origin.y / floor_height) + 1
	var rs = rooms[item.m].connections
	if rs.size() == 0:
		return null
	var possible_selections = []
	for i in rs:
		if rooms[i].has("min_floor"):
			if rooms[i].min_floor > floor_num:
				continue
		if rooms[i].has("max_floor"):
			if rooms[i].max_floor < floor_num:
				continue
		possible_selections.push_back(i)
	if possible_selections.size() == 0:
		return null
	var cid = int(inverse_lerp(-1, 1, idf) * possible_selections.size())
	return possible_selections[cid]
	
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
		if rooms[cid].has("special"):
			for s in rooms[cid].special:
				match(s):
					"stair":
						var above = Transform()
						above.origin.y = floor_height
						var below = Transform()
						below.origin.y = -floor_height
						var aabb_above = (current.t * above).xform(rooms[cid].aabb)
						var aabb_below = (current.t * below).xform(rooms[cid].aabb)
						room_queue.push_back({"m": cid, "t": current.t * above, "a": rooms[cid].attachments, "aabb": aabb_above, "p": rooms[cid].priority + 2})
						room_queue.push_back({"m": cid, "t": current.t * below, "a": rooms[cid].attachments, "aabb": aabb_below, "p": rooms[cid].priority + 2})
		for a in attachments:
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
						var next_attachments = rooms[cid].attachments
						room_queue.push_back({"m": cid, "t": current.t * a  * bat.inverse(), "a": next_attachments, "aabb": aabb, "p": rooms[cid].priority})
						placed = true
#						print("last aabb:", aabb, " scene_aabbs: ", scene_aabbs)
						break
	if room_count >= max_rooms || room_queue.size() == 0:
		var good = true
		for h in rooms.checks.keys():
			if get_tree().get_nodes_in_group(h).size() < rooms.checks[h]:
				good = false
				print("failed: ", h, " = ", rooms.checks[h], " :", get_tree().get_nodes_in_group(h).size())
				break
		if !good:
			room_queue.clear()
			noise.seed = OS.get_unix_time()
			prepare_stage(rooms)
			room_count = 0
			count = 0
		else:
			var max_spawned = 20
			for k in get_tree().get_nodes_in_group("beds"):
				k.emit_signal("spawn")
				max_spawned -= 1
				if max_spawned < 0:
					break
			print("SPAWN complete")
			complete = true
