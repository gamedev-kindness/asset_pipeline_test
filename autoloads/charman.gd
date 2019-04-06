extends Node

var pool = []
var min_chars: int = 10
var max_chars: int = 30
var initial_spawn: int = 10
var variation: int = 5

var main_scene: Node
var region: AABB = AABB()
var _can_spawn = false

onready var rnd : = RandomNumberGenerator.new()
onready var root = get_node("/root")
var data_path = "res://characters/clothes/clothes.json"
var clothes = {}


var spots = []
func _ready():
	rnd.seed = OS.get_unix_time()
	var jf : = File.new()
	jf.open(data_path, File.READ)
	var json_req = JSON.parse(jf.get_as_text())
	clothes = json_req.result
	jf.close()

func reset():
	spots.clear()
	var queue = [main_scene]
	while queue.size() > 0:
		var item = queue[0]
		queue.pop_front()
		if item.name.find("_spawn") >= 0:
			spots.push_back(item)
		elif item.is_in_group("spawn"):
			spots.push_back(item)
		if item is MeshInstance:
			region = region.merge(item.get_aabb())
		for k in item.get_children():
			queue.push_back(k)
func select_player_spawn_spot():
	if spots.size() == 0:
		return null
	var i = rnd.randi() % spots.size()
	return spots[i]

func spawn_character(spot: Node, gender: String):
	var characters = content.characters
	var selection = gender
	var c = characters[selection].obj.instance()
	c.enable_all_shapes()
	root.add_child(c)
	c.global_transform = spot.global_transform
	c.init_data()
	return c
func wear_suit(c, suit_name):
	var gender = awareness.character_data[c].gender
	var items = clothes.sets[gender]
	var selected
	for s in items:
		if s.name == suit_name:
			selected = s
			break
	var cloth_items = selected.clothes
	for cloth in cloth_items:
		var sp = cloth.split("/")
		var cloth_type = sp[0]
		var cloth_name = sp[1]
		var cloth_data = clothes[gender][cloth_type]
		for e in cloth_data:
			if e.name == cloth_name:
				var mesh_path = e.path
				var mesh : = load(mesh_path)
				var mi = MeshInstance.new()
				mi.mesh = mesh
				c.skel.add_child(mi)
				mi.skeleton = c.skel.get_path()
				break
func spawn_player(spot, state, suit):
	var c = spawn_character(spot, "male")
	c.tps_camera = load("res://camera/camera.tscn").instance()
	c.add_child(c.tps_camera)
	c.tps_camera.get_node("rotary/base/cam_control/Camera").current = true
	wear_suit(c, suit)
	while !awareness.at.has(c):
		yield(get_tree(), "idle_frame")
	while !awareness.at[c]["parameters/playback"].is_playing():
		yield(get_tree(), "idle_frame")
	awareness.at[c]["parameters/playback"].stop()
	awareness.at[c]["parameters/playback"].start(state)
	awareness.player_character = c
	c.posessed = true
	return c
func spawn_npc(spot, gender, state, suit):
	var c = spawn_character(spot, gender)
	wear_suit(c, suit)
	while !awareness.at.has(c):
		yield(get_tree(), "idle_frame")
	while !awareness.at[c]["parameters/playback"].is_playing():
		yield(get_tree(), "idle_frame")
	awareness.at[c]["parameters/playback"].stop()
	awareness.at[c]["parameters/playback"].start(state)
	return c
func initial_spawn():
	for k in range(spots.size()):
		var genders = ["male", "female", "female"]
		var gender = genders[rnd.randi() % genders.size()]
		var p1 = spots[k].global_transform.origin
		var ok = true
		for c in get_tree().get_nodes_in_group("characters"):
			var p2 = c.global_transform.origin
			if p1.distance_to(p2) < 3.0:
				ok = false
				break
		if ok:
			spawn_npc(spots[k], gender, "Standing", "hairs")
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !_can_spawn:
		if main_scene:
			reset()
			var spot = select_player_spawn_spot()
			if spot:
				_can_spawn = true
				yield(spawn_player(spot, "Standing", "hairs"), "completed")
				initial_spawn()
				print("spawned")
