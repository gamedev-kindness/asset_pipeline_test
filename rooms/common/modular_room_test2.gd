extends Spatial
onready var rooms = {
	"axiom": "corridoor",
	"corridoor": {
		"module": load("res://rooms/corridoor_module.tscn"),
		"connections": ["corridoor", "corridoor_cross"],
		"attachments": [],
		"priority": 1,
	},
	"corridoor_cross": {
		"module": load("res://rooms/corridoor_cross_module.tscn"),
		"connections": ["corridoor"],
		"attachments": [],
		"priority": 4
	},
	"checks": {
		"min": {
			"corridoor": 4,
			"corridoor_cross": 2
		},
		"max": {
			"corridoor_cross": 5
		}
	},
	"config": {
		"min_floor": -2,
		"max_floor": 4
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
var added_paths = []

func build_navigation():
	var id = 0
	var start_ids = []
	var end_ids = []
	print("building navigation")
	for p in get_tree().get_nodes_in_group("nav"):
		var curve = p.curve
		start_ids.push_back(id)
		for pt in range(curve.get_point_count()):
			awareness.astar.add_point(id, p.global_transform.xform(curve.get_point_position(pt)))
			if pt > 0:
				awareness.astar.connect_points(id - 1, id)
			id += 1
		end_ids.push_back(id - 1)
	for sid in start_ids:
		var p1 = awareness.astar.get_point_position(sid)
		for pt  in range(id):
			if sid == pt:
				continue
			var p2 = awareness.astar.get_point_position(pt)
			var d = p1.distance_squared_to(p2)
			if d < 2.0:
				awareness.astar.connect_points(sid, pt)
	for eid in end_ids:
		var p1 = awareness.astar.get_point_position(eid)
		for pt  in range(id):
			if eid == pt:
				continue
			var p2 = awareness.astar.get_point_position(pt)
			var d = p1.distance_squared_to(p2)
			if d < 2.0:
				awareness.astar.connect_points(eid, pt)
	print("building navigation done ", awareness.astar.get_available_point_id())

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
			if a.is_in_group("attachment"):
				attachments.push_back(a)
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
var preferred_dims = Vector3(100, 120, 100)
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
	var used_nodes = []
	var unused_nodes = []
	while room_queue.size() > 0 && count < max_per_frame && room_count < max_rooms:
		count += 1
		var current = room_queue[0]
		room_queue.pop_front()
		if current.p > 0:
			current.p = current.p - 1
			room_queue.push_back(current)
			continue
		if rooms.checks.max.has(current.m) && rooms.checks.max[current.m] <= get_tree().get_nodes_in_group(current.m).size():
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
#		var attachment_nodes = []
#		for n in r.get_children():
#			if n.is_in_group("attachment"):
#				attachment_nodes.push_back(n)
#		if current.has("used_nodes") && current.has("attachment_nodes"):
#			for n in current.used_nodes:
#				if !current.attachment_nodes(n) in used_nodes:
#					used_nodes.push_back(current.attachment_nodes[n])
#				if current.attachment_nodes(n) in unused_nodes:
#					unused_nodes.erase(current.attachment_nodes[n])
		if cid == null:
			continue
		var module = rooms[cid].module
		for a in attachments:
			if !a in unused_nodes:
				unused_nodes.push_back(a)
			if a in used_nodes:
				continue
			for ba in rooms[cid].attachments:
				if !ba in unused_nodes:
					unused_nodes.push_back(ba)
				if ba in used_nodes:
					continue
				var placed = false
				for art in [0, PI / 2.0, - PI / 2.0, PI]:
					var at = Transform(Quat(Vector3(0, 1, 0), art))
					var bat = ba.transform * at
					var aabb = (current.t * a.transform  * bat.inverse()).xform(rooms[cid].aabb)
#					print(aabb)
					var ok = true
					for s in scene_aabbs:
						if aabb.intersects(s):
							ok = false
							break
					if ok:
						var room = {
							"m": cid,
							"t": current.t * a.transform  * bat.inverse(),
							"a": rooms[cid].attachments,
							"aabb": aabb,
							"p": rooms[cid].priority,
							"used_nodes": [attachments.find(a), attachments.find(ba)]
						}
						room_queue.push_back(room)
						placed = true
#						print("last aabb:", aabb, " scene_aabbs: ", scene_aabbs)
						break
		for k in used_nodes:
			unused_nodes.erase(k)
		print("used_nodes: ", used_nodes, " room_count: ", room_count)
		print("unused_nodes: ", unused_nodes)
	if room_count >= max_rooms || room_queue.size() == 0:
		var good = true
		for h in rooms.checks.min.keys():
			if get_tree().get_nodes_in_group(h).size() < rooms.checks.min[h]:
				good = false
				print("failed: ", h, " = ", rooms.checks.min[h], " :", get_tree().get_nodes_in_group(h).size())
				break
		for h in rooms.checks.max.keys():
			if get_tree().get_nodes_in_group(h).size() > rooms.checks.max[h]:
				good = false
				print("failed: ", h, " = ", rooms.checks.max[h], " :", get_tree().get_nodes_in_group(h).size())
				break
		if !good:
			room_queue.clear()
			noise.seed = OS.get_unix_time()
			prepare_stage(rooms)
			room_count = 0
			count = 0
		else:
			build_navigation()
			for k in get_tree().get_nodes_in_group("beds"):
				k.emit_signal("spawn")
			print("SPAWN complete")
			complete = true
