extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var room_rect : = Rect2()
var layout_root: Spatial
var walls = []

const data_path = "res://furniture/placement/placement.json"
const furniture_data_path = "res://furniture/data/list.json"
var json : = {}
var furniture_json : = {}
var f2path : = {}
var f2obj : = {}
var rnd
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
	print(f2path[item])
	if !layout_root:
		return
	var k = GenericItem.new(f2obj[item])
	k.set_meta("data", {"name": item})
	layout_root.add_child(k)

func vec2_to_str(v: Vector2) -> String:
	return str(v.x) + " " + str(v.y)

func str_to_vec2(s: String) -> Vector2:
	var ret : = Vector2()
	var sd = s.split(" ")
	ret.x = float(sd[0])
	ret.y = float(sd[1])
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
	print(json)
	var f : = File.new()
	f.open(data_path, f.WRITE)
	f.store_string(JSON.print(json, "\t", true))
	f.close()
	new_layout()


func _ready():
	rnd = RandomNumberGenerator.new()
	$p/v/new_layout.connect("pressed", self, "new_layout")
	$p/v/new_door.connect("pressed", self, "new_door")
	$p/v/new_window.connect("pressed", self, "new_window")
	$p/v/store_create_new.connect("pressed", self, "store_layout")
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
		if jf.file_exists(fp.replace(".escn", ".tscn")):
			fp = fp.replace(".escn", ".tscn")
		f2path[kn] = fp
		f2obj[kn] = load(fp)
		$p/v/furniture/item.add_item(kn)
	print(f2path)
	$p/v/furniture/item.connect("item_activated", self, "furniture_selected", [$p/v/furniture/item])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
