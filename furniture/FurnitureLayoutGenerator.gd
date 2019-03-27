extends Node
class_name FurnitureLayoutGenerator
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func str_to_xform(s: String) -> Transform:
	var data = s.split(" ")
	var xf = Transform()
	for v in range(4):
		for h in range(3):
			xf[v][h] = float(data[v * 3 + h])
	return xf			

var f2aabb = {}
var type_item = {}
var f2obj = {}

func wall_constraint(r_aabb:AABB, aabb: AABB) -> bool:
	if abs(r_aabb.position.x - aabb.position.x) < 0.5:
		return true
	elif abs(r_aabb.end.x - aabb.end.x) < 0.5:
		return true
	elif abs(r_aabb.position.z - aabb.position.z) < 0.5:
		return true
	elif abs(r_aabb.end.z - aabb.end.z) < 0.5:
		return true
	return false

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

func layout_builder(layout_root: Node, r_aabb: AABB, door_clearance: Array, queue: Array, rules: Dictionary, wall_types: Array):
	var aabbs = []
	var count = 0
	var ret = []
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
			if !r_aabb.encloses(aabb):
				print(o.name, " origin: ", kxform.origin, " ", r_aabb, " ", aabb)
				continue
			if o.name in wall_types && !wall_constraint(r_aabb, aabb):
				continue
			var valid_aabb = true
			for r in door_clearance:
				if r.intersects(aabb) || aabb.intersects(r):
					valid_aabb = false
					break
				if r.encloses(aabb) || aabb.encloses(r):
					valid_aabb = false
					break
			if !valid_aabb:
				continue
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
	return count
