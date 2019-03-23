extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var room_rect : = Rect2()
var room_aabb : = AABB()
var layout_root: Spatial
var walls = []

const data_path = "res://furniture/placement/placement.json"
const furniture_data_path = "res://furniture/data/list.json"
var json : = {}
var furniture_json : = {}
var f2path : = {}
var f2obj : = {}
var rnd
var type_item = {}
var f2aabb = {}
class wall extends Reference:
	var _p1: Vector2
	var _p2: Vector2
	var _angle: float
	var _dir: Vector2
	var _tangent: Vector2
	var _angle_code: int
	var _width: float
	var _height: float
	enum {WALL_RIGHT, WALL_BACK, WALL_LEFT, WALL_FRONT}
	func _init(p1: Vector2, p2: Vector2, width: float, height: float):
		_p1 = p1
		_p2 = p2
		_dir = (p2 - p1).normalized()
		_tangent = _dir.tangent().normalized()
		_angle = _dir.angle()
		_width = width
		_height = height
	func get_mid():
		return _p1.linear_interpolate(_p2, 0.5)
	func get_height():
		return _height
	func get_length():
		return (_p2 - _p1).length()
	func get_width():
		return _width
func new_layout():
	var size = Vector2(3.0, 3.0) + Vector2(rnd.randf() * 15.0, rnd.randf() * 15.0)
	room_rect.size = size
	room_rect.position = -size / 2.0
	print(room_rect)
	if layout_root != null:
		layout_root.queue_free()
	layout_root = Spatial.new()
	add_child(layout_root)
	walls.clear()
	walls.push_back(wall.new(room_rect.position, room_rect.position + Vector2(0, room_rect.size.y), 0.1, 2.6))
	walls.push_back(wall.new(room_rect.position + Vector2(room_rect.size.x, 0), room_rect.position + room_rect.size, 0.1, 2.6))
	walls.push_back(wall.new(room_rect.position, room_rect.position + Vector2(room_rect.size.x, 0), 0.1, 2.6))
	walls.push_back(wall.new(room_rect.position + Vector2(0, room_rect.size.y), room_rect.position + room_rect.size, 0.1, 2.6))
	for k in walls:
		var w = MeshInstance.new()
		layout_root.add_child(w)
		var pos2 = k.get_mid()
		var h = k.get_height()
		w.translation = Vector3(pos2.x, h / 2.0, pos2.y)
		w.rotation.y = -k._angle + PI / 2.0
		var mesh : = CubeMesh.new()
		mesh.size.x = k.get_width()
		mesh.size.y = h
		mesh.size.z = k.get_length()
		w.mesh = mesh
		w.set_meta("data", {"name": "wall"})

class FurnitureItem extends KinematicBody:
	var _dragging = false
	var _move_data = Vector3()
	func _ready():
		input_capture_on_drag = true
	func _input_event(camera, event, click_position, click_normal, shape_idx):
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_RIGHT && event.pressed:
				rotate_y(PI / 2.0)
			if event.button_index == BUTTON_LEFT && event.pressed:
				if Input.is_action_pressed("activate"):
					queue_free()
				_dragging = true
			elif event.button_index == BUTTON_LEFT && !event.pressed:
				_dragging = false
		if event is InputEventMouseMotion:
			if _dragging:
				if abs(event.relative.x) > abs(event.relative.y):
					if abs(event.relative.x) > 0.3:
						_move_data += Vector3(sign(event.relative.x) * 0.1, 0, 0)
				else:
					if abs(event.relative.y) > 0.3:
						_move_data += Vector3(0, 0, sign(event.relative.y) * 0.1)
	func _physics_process(delta):
		translation += _move_data
		_move_data = Vector3()
class DoorItem extends FurnitureItem:
	func _ready():
		var w = MeshInstance.new()
		var mesh : = CubeMesh.new()
		mesh.size.x = 1.0
		mesh.size.y = 2.0
		mesh.size.z = 0.2
		w.mesh = mesh
		add_child(w)
		w.translation.y = 1.0
		var c : = CollisionShape.new()
		var shape : = BoxShape.new()
		shape.extents.x = 0.5
		shape.extents.y = 1.0
		shape.extents.z = 0.1
		c.shape = shape
		c.translation.y = 1.0
		add_child(c)
class WindowItem extends FurnitureItem:
	func _ready():
		var w = MeshInstance.new()
		var mesh : = CubeMesh.new()
		mesh.size.x = 1.2
		mesh.size.y = 1.2
		mesh.size.z = 0.2
		w.mesh = mesh
		add_child(w)
		w.translation.y = 1.4
		var c : = CollisionShape.new()
		var shape : = BoxShape.new()
		shape.extents.x = 0.6
		shape.extents.y = 0.6
		shape.extents.z = 0.1
		c.shape = shape
		c.translation.y = 1.4
		add_child(c)
class GenericItem extends FurnitureItem:
	var item_obj
	func _ready():
		var w = item_obj.instance()
		add_child(w)
		w.translation.y = 0.0
		var c : = CollisionShape.new()
		var shape : = BoxShape.new()
		shape.extents.x = 0.6
		shape.extents.y = 0.6
		shape.extents.z = 0.1
		c.shape = shape
		c.translation.y = 1.4
		add_child(c)
	func _init(obj):
		item_obj = obj
func new_door():
	if !layout_root:
		return
	print("d")
	var k = DoorItem.new()
	k.set_meta("data", {"name": "door"})
	layout_root.add_child(k)
func new_window():
	if !layout_root:
		return
	print("w")
	var k = WindowItem.new()
	k.set_meta("data", {"name": "window"})
	layout_root.add_child(k)
func furniture_selected(item_id: int, obj: ItemList):
	var item = obj.get_item_text(item_id)
	if !layout_root:
		return
	var t = type_item[item][0]
	var k = GenericItem.new(f2obj[t])
	k.set_meta("data", {"name": item})
	layout_root.add_child(k)

func vec2_to_str(v: Vector2) -> String:
	return str(v.x) + " " + str(v.y)
func vec3_to_str(v: Vector3) -> String:
	return str(v.x) + " " + str(v.y) + " " + str(v.z)

func str_to_vec2(s: String) -> Vector2:
	var ret : = Vector2()
	var sd = s.split(" ")
	ret.x = float(sd[0])
	ret.y = float(sd[1])
	return ret
func str_to_vec3(s: String) -> Vector3:
	var ret : = Vector3()
	var sd = s.split(" ")
	ret.x = float(sd[0])
	ret.y = float(sd[1])
	ret.z = float(sd[2])
	return ret
func rect_to_str(r: Rect2) -> String:
	var ret = vec2_to_str(r.position) + " " + vec2_to_str(r.size)
	return ret
func str_to_rect(s: String) -> Rect2:
	var sdata = s.split(" ")
	var pos = str_to_vec2(sdata[0] + " " + sdata[1])
	var sz = str_to_vec2(sdata[2] + " " + sdata[3])
	return Rect2(pos, sz)
	
func xform_to_str(xf: Transform):
	var data = []
	for v in range(4):
		for h in range(3):
			data.push_back(str(xf[v][h]))
	return PoolStringArray(data).join(" ")
func str_to_xform(s: String) -> Transform:
	var data = s.split(" ")
	var xf = Transform()
	for v in range(4):
		for h in range(3):
			xf[v][h] = float(data[v * 3 + h])
	return xf			
func store_layout():
	if $p/v/h/type.get_selected_items().size() == 0:
		return
	var current_id = $p/v/h/type.get_selected_items()[0]
	var item = $p/v/h/type.get_item_text(current_id)
	var layout = {}
	layout.rect = rect_to_str(room_rect)
	layout.objects = []
	for k in layout_root.get_children():
		var data = k.get_meta("data")
		if data == null:
			data = {}
		data.xform = xform_to_str(k.transform)
		layout.objects.push_back(data)
	json.layouts[item].push_back(layout)
	json.seed = rnd.seed
	build_rules()
	var f : = File.new()
	f.open(data_path, f.WRITE)
	f.store_string(JSON.print(json, "\t", true))
	f.close()
	new_layout()
func load_layout():
	var no = int($p/v/sp.value)
	if $p/v/h/type.get_selected_items().size() == 0:
		return
	var current_id = $p/v/h/type.get_selected_items()[0]
	var item = $p/v/h/type.get_item_text(current_id)
	if !json.layouts.has(item):
		return
	if json.layouts[item].size() == 0:
		return
	if no >= json.layouts[item].size():
		return
	var layout = json.layouts[item][no]
	print(layout)
	room_rect = str_to_rect(layout.rect)
	print(room_rect)
	if layout_root != null:
		layout_root.queue_free()
	layout_root = Spatial.new()
	add_child(layout_root)
	walls.clear()
	walls.push_back(wall.new(room_rect.position, room_rect.position + Vector2(0, room_rect.size.y), 0.1, 2.6))
	walls.push_back(wall.new(room_rect.position + Vector2(room_rect.size.x, 0), room_rect.position + room_rect.size, 0.1, 2.6))
	walls.push_back(wall.new(room_rect.position, room_rect.position + Vector2(room_rect.size.x, 0), 0.1, 2.6))
	walls.push_back(wall.new(room_rect.position + Vector2(0, room_rect.size.y), room_rect.position + room_rect.size, 0.1, 2.6))
	for k in walls:
		var w = MeshInstance.new()
		layout_root.add_child(w)
		var pos2 = k.get_mid()
		var h = k.get_height()
		w.translation = Vector3(pos2.x, h / 2.0, pos2.y)
		w.rotation.y = -k._angle + PI / 2.0
		var mesh : = CubeMesh.new()
		mesh.size.x = k.get_width()
		mesh.size.y = h
		mesh.size.z = k.get_length()
		w.mesh = mesh
		w.set_meta("data", {"name": "wall"})
	for o in layout.objects:
		var xform = str_to_xform(o.xform)
		if o.name == "wall":
			continue
		elif o.name == "door":
			var door = DoorItem.new()
			door.set_meta("data", {"name": "door"})
			layout_root.add_child(door)
			door.transform = xform
		elif o.name == "window":
			var window = WindowItem.new()
			window.set_meta("data", {"name": "window"})
			layout_root.add_child(window)
			window.transform = xform
		else:
			var t = type_item[o.name][0]
			var k = GenericItem.new(f2obj[t])
			k.set_meta("data", {"name": o.name})
			layout_root.add_child(k)
			k.transform = xform

func distance_sort_helper(a, b):
	var tf_a = str_to_xform(a.xform)
	var tf_b = str_to_xform(b.xform)
	if tf_a.origin.length() < tf_b.origin.length():
		return true
	else:
		return false
func build_rules():
	print("rebuilding rules")
	json.rules = {}
	for k in json.layouts.keys():
		json.rules[k] = {}
		for l in json.layouts[k]:
			for o in l.objects:
				print(o.name)
				json.rules[k][o.name] = []
				for ov in l.objects:
					if o == ov:
						continue
					var tf = str_to_xform(o.xform)
					var tf_s = str_to_xform(ov.xform)
					if o.name in ["wall", "door"]:
						tf.origin.y = 0.0
					if tf.origin == tf_s.origin:
						continue
					tf_s = (tf.inverse() * tf_s).orthonormalized()
					var rule = {
						"name": ov.name,
						"xform": xform_to_str(tf_s),
						"origin": vec3_to_str(tf_s.origin),
					}
					json.rules[k][o.name].push_back(rule)
				json.rules[k][o.name].sort_custom(self, "distance_sort_helper")
				if json.rules[k][o.name].size() > 8:
					json.rules[k][o.name].resize(8)
func build_aabbs():
	print("build_aabbs")
	for kn in f2obj.keys():
		var queue = []
		print(kn)
		var aabb = AABB()
		var sc = f2obj[kn].instance()
		queue.push_back(sc)
		while queue.size() > 0:
			var m = queue[0]
			queue.pop_front()
			for h in m.get_children():
				queue.push_back(h)
				if h is MeshInstance:
					aabb = aabb.merge(h.get_aabb())
					aabb.position.y = 0.0
					f2aabb[kn] = aabb
		print(sc)
#		sc.queue_free()
func generate_layout():
	room_aabb.position = Vector3(room_rect.position.x, 0, room_rect.position.y)
	room_aabb.size = Vector3(room_rect.size.x, 2.7, room_rect.size.y)
	var aabbs = []
	if $p/v/h/type.get_selected_items().size() == 0:
		return
	var current_id = $p/v/h/type.get_selected_items()[0]
	var item = $p/v/h/type.get_item_text(current_id)
	var queue = []
	var count = 0
	var flip_door = false
	while count == 0:
		for c in layout_root.get_children():
			var meta = c.get_meta("data")
			if meta == null:
				continue
			if meta.name == "door":
				queue.push_back(c)
				if flip_door:
					c.rotate_y(PI)
		var rules = json.rules[item]
		while queue.size() > 0:
			var d = queue[0]
			queue.pop_front()
			var meta = d.get_meta("data")
			var rule = rules[meta.name].duplicate()
			rule.shuffle()
			print(rule)
			for o in rule:
				var xform = str_to_xform(o.xform)
				var kxform = (d.transform * xform).orthonormalized()
				if o.name in ["door", "wall"]:
					continue
				var aabb = kxform.xform(f2aabb[type_item[o.name][0]])
				if !room_aabb.encloses(aabb):
					print(o.name, " origin: ", kxform.origin, " ", room_aabb, " ", aabb)
					continue
				var valid_aabb = true
				for r in aabbs:
					if r.intersects(aabb) || aabb.intersects(r):
						valid_aabb = false
						break
					if r.encloses(aabb) || aabb.encloses(r):
						valid_aabb = false
						break
				if !valid_aabb:
					continue
				var t = type_item[o.name][0]
				var k = GenericItem.new(f2obj[t])
				k.set_meta("data", {"name": o.name})
				layout_root.add_child(k)
				k.transform = kxform
				aabbs.push_back(aabb)
				queue.push_back(k)
				count += 1
		if count == 0:
			flip_door = true

func build_rules_and_save():
	build_rules()
	var f : = File.new()
	f.open(data_path, f.WRITE)
	f.store_string(JSON.print(json, "\t", true))
	f.close()
func _ready():
	rnd = RandomNumberGenerator.new()
	$p/v/new_layout.connect("pressed", self, "new_layout")
	$p/v/new_door.connect("pressed", self, "new_door")
	$p/v/new_window.connect("pressed", self, "new_window")
	$p/v/store_create_new.connect("pressed", self, "store_layout")
	$p/v/build_rules.connect("pressed", self, "build_rules_and_save")
	var jf : = File.new()
	jf.open(data_path, File.READ)
	var json_req = JSON.parse(jf.get_as_text())
	json = json_req.result
	jf.close()
	if json.has("seed"):
		rnd.seed = int(json.seed)
	else:
		rnd.seed = OS.get_unix_time()
	jf.open(furniture_data_path, File.READ)
	json_req = JSON.parse(jf.get_as_text())
	furniture_json = json_req.result
	jf.close()
	$p/v/h/type.clear()
	for k in json.layouts.keys():
		$p/v/h/type.add_item(k)
		$p/v.update()
	$p/v/furniture/item.clear()
	for k in furniture_json.keys():
		var kn = furniture_json[k].name
		var fp = furniture_json[k].path
		var ft = furniture_json[k].type
		if jf.file_exists(fp.replace(".escn", ".tscn")):
			fp = fp.replace(".escn", ".tscn")
		f2path[kn] = fp
		f2obj[kn] = load(fp)
		if type_item.has(ft):
			type_item[ft].push_back(kn)
		else:
			type_item[ft] = [kn]
	for ew in type_item.keys():
		$p/v/furniture/item.add_item(ew)
	build_aabbs()
	print(f2path)
	$p/v/furniture/item.connect("item_activated", self, "furniture_selected", [$p/v/furniture/item])
	$p/v/load.connect("pressed", self, "load_layout")
	$p/v/generate_layout.connect("pressed", self, "generate_layout")
