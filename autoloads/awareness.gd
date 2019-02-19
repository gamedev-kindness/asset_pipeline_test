extends Node
signal daytime_update
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
var inventory = {}

# RPG data
var stats = {}
var needs = {}
var skills = {}
var skill_levels = {}
var current_level = {}
var traits = {}
var till_next_level = {}
var astar: AStar
var current_path = {}
var at = {}
var action_cooldown = {}
var targets = {}
var target_activation_time = {}
var raycasts = {}
var need_changes = {}
var gender = {}
var disposition = {}
var markov_rnd
var name_data = {}
var character_name = {}
var character_firstname = {}
var character_lastname = {}
var roster = {}
var phone_number = {}

func _ready():
	astar = AStar.new()
	markov_rnd = RandomNumberGenerator.new()
	markov_rnd.seed = OS.get_unix_time()
	var fd = File.new()
	fd.open("res://characters/name_data.json", File.READ)
	var seedings_data = fd.get_as_text()
	var seedings_json = JSON.parse(seedings_data)
	var seedings = seedings_json.result
	fd.close()
	for e in seedings.keys():
		for k in seedings[e]:
			if !name_data.has(e):
				name_data[e] = {}
				name_data[e].start = []
				name_data[e].ngrams = {}
			for n in [settings.markov_order]:
				for l in range(k.length() - n + 1):
					if !name_data[e].ngrams.has(k.substr(l, n)):
						name_data[e].ngrams[k.substr(l, n)] = [k.substr(l + n, 1)]
					else:
						name_data[e].ngrams[k.substr(l, n)].push_back(k.substr(l + n, 1))
					if l == 0:
						name_data[e].start.push_back(k.substr(l, n))


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
		inventory[c] = []
		update_active()

	if c in objects:
		objects.erase(c)
		update_active()
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
			inventory[k] = []
	for k in get_tree().get_nodes_in_group("character_holders"):
		add_chunk(chunks1, k)
		if !k in character_holders:
			character_holders.push_back(k)
			k.connect("tree_exited", self, "remove_deleted", [k])
	for k in get_tree().get_nodes_in_group("pickup"):
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
var max_active_distance = 1.2
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
					if abs(p1.angle_to(p2)) < active_angle / (1.7 + distance(a, c)):
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
	if !active_items.has(obj):
		return null
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
func build_path_to(obj: Spatial, to: Vector3) -> PoolVector3Array:
	var from_id = astar.get_closest_point(obj.global_transform.origin)
	var to_id = astar.get_closest_point(to)
	var path: PoolVector3Array = astar.get_point_path(from_id, to_id)
	return path

func build_path_to_obj(obj: Spatial, to: Spatial) -> PoolVector3Array:
	var path: PoolVector3Array = build_path_to(obj, to.global_transform.origin)
	return path

var utilities = {
	"socialize": {
		"score": 290.0,
		"need": "Socialization",
		"tag": "characters",
	},
	"class": {
		"score": 300.0,
		"need": "Study",
		"tag": "classes",
	},
	"hunger": {
		"score": 450.0,
		"need": "Hunger",
		"tag": "food",
	},
	"toilet1": {
		"score": 500.0,
		"need": "Toilet1",
		"tag": "toilet",
	},
	"toilet2": {
		"score": 600.0,
		"need": "Toilet2",
		"tag": "toilet",
	},
	"shower": {
		"score": 400.0,
		"need": "Shower",
		"tag": "shower",
	},
	"broken": {
		"score": 495,
		"trait": "broken",
		"behavior": "broken"
	},
	"slave": {
		"score": 495,
		"trait": "slave",
		"behavior": "slave"
	},
	"passive_action": {
		"score": 10000,
		"flag": "passive_action",
		"behavior": "passive_action"
	},
	"active_action": {
		"score": 10000,
		"flag": "active_action",
		"behavior": "active_action"
	},
	"dialogue": {
		"score": 500,
		"flag": "dialogue",
		"behavior": "dialogue"
	}
}

var passive_action = {}
var active_action = {}
var ai_state = {}
var dialogue_mode = {}

func get_utility(obj, un):
	if needs.has(obj) && utilities.has(un) && utilities[un].has("need"):
		return utilities[un].score * needs[obj][utilities[un].need]
	elif traits.has(obj) && utilities.has(un) && utilities[un].has("trait"):
		if traits[obj].has(un):
			return utilities[un].score
		else:
			return 0.0
	elif utilities.has(un) && utilities[un].has("flag"):
		if utilities[un].flag == "passive_action":
			if passive_action.has(obj):
				return utilities[un].score
		if utilities[un].flag == "active_action":
			if active_action.has(obj):
				return utilities[un].score
		if utilities[un].flag == "dialogue":
			if dialogue_mode.has(obj):
				return utilities[un].score
		return 0.0
	else:
		return 0.0

func get_traits(obj):
	return traits[obj]
func has_trait(obj, trait):
	return trait in traits[obj]
func add_trait(obj, trait):
	if !traits.has(obj):
		traits[obj] = []
	if ! trait in traits[obj]:
		traits[obj].push_back(trait)
func build_name(starts, ngrams):
	var start = starts[markov_rnd.randi() % starts.size()]
	var result = start
	while result.length() < 15:
#		var order = rnd.randi() %3 + 1
#		order = min(order, result.length())
		var key = result.substr(result.length() - settings.markov_order, settings.markov_order)
		if key == "":
			break
		var next = ngrams[key]
		var next_ch = next[markov_rnd.randi() % next.size()]
		if next_ch == '':
			break
		result += next_ch
	return(result)
func build_male_firstname():
	return build_name(name_data["male_firstname"].start, name_data["male_firstname"].ngrams)
func build_female_firstname():
	return build_name(name_data["female_firstname"].start, name_data["female_firstname"].ngrams)
func build_lastname():
	return build_name(name_data["lastname"].start, name_data["lastname"].ngrams)


func add_to_roster(owner, obj):
	if !roster.has(owner):
		roster[owner] = {}
	if roster[owner].has(obj):
		return
	var new_data = {
		"obj": obj,
		"disposition": {
			"acquaintance": 0,
			"friendship": 0,
			"love": 0,
			"lust": 0,
			"hate": 0,
			"jealousity": 0,
			"master": 0,
			"slave": 0
		},
		"sex_partner": false,
	}
	roster[owner][obj] = new_data
func are_acquientances(obj, other):
	if obj == other:
		return true
	if !roster.has(obj):
		return false
	if roster[obj].has(other):
		return true
	else:
		return false
func are_enemies(obj, other):
	if obj == other:
		return false
	if !roster.has(obj):
		return false
	if !roster[obj].has(other):
		return false
	else:
		var d = roster[obj][other].disposition
		return d.hate > d.love && d.hate > d.friendship
func are_friends(obj, other):
	if obj == other:
		return true
	if !roster.has(obj):
		return false
	if !roster[obj].has(other):
		return false
	else:
		if are_enemies(obj, other):
			return false
		var d = roster[obj][other].disposition
		return d.friendship > 0
func are_lovers(obj, other):
	if obj == other:
		return true
	if !roster.has(obj):
		return false
	if !roster[obj].has(other):
		return false
	else:
		var d = roster[obj][other].disposition
		return d.love > d.friendship
func is_slave(obj, other):
	if obj == other:
		return false
	if !roster.has(obj):
		return false
	if !roster[obj].has(other):
		return false
	else:
		var d = roster[obj][other].disposition
		return d["slave"] > d.friendship && d["slave"] > d.love
func is_master(obj, other):
	if obj == other:
		return false
	if !roster.has(obj):
		return false
	if !roster[obj].has(other):
		return false
	else:
		if is_slave(obj, other):
			return false
		var d = roster[obj][other].disposition
		return d["master"] > d.friendship && d["master"] > d.love
func get_master(obj):
	for k in roster[obj].keys():
		if is_master(obj, k):
			return k
	return null

func initiate_dialogue(obj, other):
		var dialogue
		if awareness.dialogue_mode.has(obj):
			dialogue = awareness.dialogue_mode[obj]
		elif awareness.dialogue_mode.has(other):
			dialogue = awareness.dialogue_mode[other]
		else:
			dialogue = DialogueScheduler.new()
			get_node("/root").add_child(dialogue)
		if !awareness.dialogue_mode.has(obj):
			awareness.dialogue_mode[obj] = dialogue
			dialogue.add_character(obj)
		if !awareness.dialogue_mode.has(other):
			awareness.dialogue_mode[other] = dialogue
			dialogue.add_character(other)
		return dialogue
func can_initiate_dialogue(obj, other):
	if is_slave(obj, other):
		return false
	if are_friends(obj, other):
		return true
	if is_slave(other, obj):
		return true
	if is_master(obj, other):
		return true
	if at.has(other):
		if at[other]["parameters/playback"].get_current_node() == "Toilet1":
			return false
		if at[other]["parameters/playback"].get_current_node() == "Toilet2":
			return false
	return true

func obj2targets(obj):
	return obj.get_node("targets").get_children()
