extends Node
signal daytime_update
func _ready():
	pass # Replace with function body.

var player_character
var cooldown = 0.0
var characters = []
var character_holders = []
var objects = []

var time_count = 0.0

var day_hour = 0.0
var day_minute = 0.0
var month_day = 1
var month = 1
var day_of_week = 3
var month_sizes = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
var year = 2045
const minute_size = 0.5

const chunk_size = 32

var chunks = {}

var max_obj_sight_distance = 50.0
var max_character_sight_distance = 12.0
var max_distance_to_camera  = 20.0

var sight_map = {}
func rebuild_map():
	var camera = player_character.tps_camera
	for k in characters:
		if distance(k, camera) > max_distance_to_camera:
			continue
		for l in characters:
			if k == l:
				continue
			if distance(l, camera) > max_distance_to_camera:
				continue
			if distance(k, l) > max_character_sight_distance:
				continue
			if sight_map.has(k) && !l in sight_map[k]:
				sight_map[k].push_back(l)
			elif !sight_map.has(k):
				sight_map[k] = [l]

func world_to_chunk(v):
	return Vector3(int(v.x / chunk_size), int(v.y / chunk_size), int(v.z / chunk_size))

func add_chunk(dchunk: Dictionary, p: Spatial):
	if dchunk.has(world_to_chunk(p.global_transform.origin)):
		dchunk[world_to_chunk(p.global_transform.origin)].push_back(p)
	else:
		dchunk[world_to_chunk(p.global_transform.origin)] = [p]

func get_neighbors(p: Spatial):
	var ret = []
	var gridc = world_to_chunk(p.global_transform.origin)
	for r in range(-1, 1, 2):
		for h in range(-1, 1, 2):
			for v in range(-1, 1, 2):
				if chunks.has(gridc + Vector3(r, h, v)):
					ret += chunks[gridc + Vector3(r, h, v)]
	return ret

func get_neighbors_by_group(p:Spatial, group: String):
	var neighbors = get_neighbors(p)
	var ret = []
	for n in neighbors:
		if n.is_in_group(group):
			ret.push_back(n)
	print(group, ":", neighbors, " ", ret)
	return ret

func remove_deleted(c):
	if c in characters:
		characters.erase(c)
	if c in objects:
		objects.erase(c)
	for fc in chunks.keys():
		if c in chunks[fc]:
			chunks[fc].erase(c)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var time_paused = false
func increment_time(delta):
	time_count += delta
	if time_count > minute_size && !time_paused:
		day_minute += 1
		emit_signal("daytime_update", [day_minute, day_hour, month_day, month, year])
		if day_minute >= 60:
			day_hour += 1
			day_minute = 0
			if day_hour >= 24:
				month_day += 1
				day_hour = 0
				if month == 2 && year % 4 == 0:
					if month_day >= month_sizes[month - 1] + 1:
						month += 1
				else:
					if month_day >= month_sizes[month - 1]:
						month += 1
						if month >= 12:
							year += 1
		time_count = 0.0
func _process(delta):
	increment_time(delta)
	if cooldown > 0.0:
		cooldown -= delta
		return
	var chunks1 = {}
	for k in get_tree().get_nodes_in_group("characters"):
		add_chunk(chunks1, k)
		if !k in characters:
			characters.push_back(k)
			k.connect("tree_exited", self, "remove_deleted", [k])
	for k in get_tree().get_nodes_in_group("character_holders"):
		add_chunk(chunks1, k)
		if !k in character_holders:
			character_holders.push_back(k)
			k.connect("tree_exited", self, "remove_deleted", [k])
	for k in get_tree().get_nodes_in_group("pickups"):
		add_chunk(chunks1, k)
		if !k in objects:
			objects.push_back(k)
			k.connect("tree_exited", self, "remove_deleted", [k])
	chunks = chunks1
	cooldown = 0.5
	if player_character:
		rebuild_map()
	update_active()
#	print("sight_map:", sight_map)
#	print("active_items:", active_items)
	

static func distance(n1: Spatial, n2: Spatial) -> float:
	return n1.global_transform.origin.distance_to(n2.global_transform.origin)

var active_items = {}
var max_active_distance = 1.0
var active_angle = PI


func update_active():
	for a in characters:
		var dir1 = a.global_transform.basis[2]
		var pos1 = a.global_transform.origin
		var p1 = -Vector2(dir1.x, dir1.z)
		for c in characters + objects:
			if a == c:
				continue
			if (!active_items.has(a)) || (! c in active_items[a]):
				if distance(a, c) < max_active_distance:
					var pos2 = c.global_transform.origin - pos1
					var p2 = Vector2(pos2.x, pos2.z)
					if abs(p1.angle_to(p2)) < active_angle / (2.0 + distance(a, c)):
						if active_items.has(a):
							active_items[a].push_back(c)
						else:
							active_items[a] = [c]

	for a in characters:
		var dir1 = a.global_transform.basis[2]
		var pos1 = a.global_transform.origin
		var p1 = -Vector2(dir1.x, dir1.z)
		if active_items.has(a):
			for c in range(active_items[a].size() - 1, -1, -1):
				if distance(a, active_items[a][c]) > max_active_distance + 0.4:
					active_items[a].remove(c)
					continue
				var pos2 = active_items[a][c].global_transform.origin - pos1
				var p2 = Vector2(pos2.x, pos2.z)
				if abs(p1.angle_to(p2)) > (active_angle + 0.1) / (2.0 + distance(a, active_items[a][c])):
					active_items[a].remove(c)
					continue

func get_actuator_body(obj, group):
	var ret
	var dst = -1
	print("awareness: active_items:")
	for i in active_items[obj]:
		print(i.name)
#	if (active_items.size() == 0):
#		print("Nothing")
#		print("all characters:", characters)
#		print("all objects: ", objects)
#		for mc in characters:
#			print("me:", get_parent().name, " character: ", mc, " name: ", mc.name, " distance: ", awareness.distance(get_parent(), mc))
	for o in active_items[obj]:
		if o.is_in_group(group):
			if dst < 0 || awareness.distance(obj, o) < dst:
				dst = awareness.distance(obj, o)
				ret = o
	return ret
func get_other_direction(obj, other):
	var v1 = Vector2(obj.orientation.basis[2].x, obj.orientation.basis[2].z)
	var v2 = Vector2(other.orientation.basis[2].x, other.orientation.basis[2].z)
	var v_angle = abs(v1.angle_to(v2))
	if v_angle < PI / 4.0:
		return "BACK"
	elif v_angle > PI / 2.0 + PI / 4.0:
		return "FRONT"
	else:
		return "SIDE"
