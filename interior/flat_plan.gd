extends Node

signal room_added
signal room_removed
signal room_updated


var out_polygon = [Vector2(-15, -25), Vector2(15, -25), Vector2(15, 25), Vector2(-15, 25)]
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rnd

var room_classes = {
	"flat": {
		"room": "flat",
		"contains": ["corridoor", "private", "public"],
		"probability": 1,
		"probability_grow": 0.3,
		"adjacent": ["flat"],
		"min_area": 20.0,
		"initial_polygon": out_polygon,
		"max_count": 1,
		"constraints": false,
	},
	"corridoor": {
		"room": "corridoor",
		"contains": [],
		"connects": [],
		"probability": 1,
		"probability_grow": 0.35,
		"adjacent": ["private", "public"],
		"min_area": 8.0,
		"initial_polygon":  [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)],
		"constraints": true,
	},
	"private": {
		"room": "private",
		"contains": [],
		"connects": [],
		"probability": 1,
		"probability_grow": 0.7,
		"adjacent": ["corridoor"],
		"min_area": 8.0,
		"initial_polygon":  [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)],
		"constraints": true
	},
	"public": {
		"room": "public",
		"contains": [],
		"connects": [],
		"probability": 1,
		"probability_grow": 0.9,
		"adjacent": ["corridoor"],
		"min_area": 8.0,
		"initial_polygon":  [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)],
		"constraints": true
	}
}
var rooms = []
func point_in_polygon(point, poly):
	var tris = Geometry.triangulate_polygon(poly)
	for p in range(0, tris.size(), 3):
		var p1 = poly[tris[p]]
		var p2 = poly[tris[p + 1]]
		var p3 = poly[tris[p + 2]]
		if Geometry.point_is_inside_triangle(point, p1, p2, p3):
			return true
	return false

func calculate_triangle_area(p1, p2, p3):
	var a = (p1 - p2).length()
	var b = (p2 - p3).length()
	var c = (p3 - p1).length()
	var s = (a + b + c) / 2.0
	
	return sqrt(s * (s - a) * (s - b) * (s - c))

func calculate_polygon_area(poly):
	var tris = Geometry.triangulate_polygon(poly)
	var area = 0.0
	for p in range(0, tris.size(), 3):
		var p1 = poly[tris[p]]
		var p2 = poly[tris[p + 1]]
		var p3 = poly[tris[p + 2]]
		area += calculate_triangle_area(p1, p2, p3)
	return area

func get_translated_polygon(poly, transform):
	var ret = []
	for p in poly:
		ret.push_back(transform.xform(p))
	return ret
		
func create_room(t, parent):
	var room = {
		"room": t.room,
		"class": t,
		"polygon": [],
		"parent": parent
	}
	for k in t.initial_polygon:
		room.polygon.push_back(k)
	room.area = calculate_polygon_area(room.polygon)
	return room

# Called when the node enters the scene tree for the first time.
var correction = 0.2
var queue = []
var rnd_seed = 3984753987
func create_initial_points(item):
	var rect = Rect2()
	for p in item.polygon:
		rect = rect.expand(p)
	var size = rect.size
	var center = rect.position + rect.size / 2.0
	var dir = Vector2()
	if size.x > size.y:
		dir.x = size.x
	else:
		dir.y = size.y
	var divider = float(item.class.contains.size())
	var pt = dir / divider
	var ret = []
	for k in item.class.contains:
		ret.push_back(pt)
		pt += dir / divider
	return ret
	
func polygon_check_fits(poly, k):
	if k.parent == null:
		return true
	var parent_poly = k.parent.polygon
	var parent_transform = k.parent.transform
	var current_transform = k.transform
	var outer_poly = []
	var inner_poly = []
	for k in parent_poly:
		outer_poly.push_back(parent_transform.xform(k))
	for k in poly:
		inner_poly.push_back(current_transform.xform(k))
	var inner_inside = true
	for k in inner_poly:
		if !point_in_polygon(k, outer_poly):
			inner_inside = false
	if !inner_inside:
		return false
	var outer_outside = true
	for k in outer_poly:
		if point_in_polygon(k, inner_poly):
			outer_outside = false
	return inner_inside && outer_outside
func polygon_check_overlaps(poly, item):
	for other in rooms:
		if other == item:
			continue
		if other.parent != item.parent:
			continue
		var current_transform = item.transform
		var other_transform = other.transform
		var current_polygon = item.polygon
		var other_polygon = other.polygon
		var poly1 = []
		var poly2 = []
		for k in current_polygon:
			poly1.push_back(current_transform.xform(k))
		for k in other_polygon:
			poly2.push_back(other_transform.xform(k))
		var check1 = true
		for k in poly1:
			if point_in_polygon(k, poly2):
				check1 = false
				break
		var check2 = true
		for k in poly2:
			if point_in_polygon(k, poly1):
				check2 = false
				break
		if !(check1 && check2):
			return false
	return true

var growth_ratio = 0.1

func grow_square(polygon):
	var ret = []
	var center = Vector2()
	for k in polygon:
		center += k
	center *= 1.0 / float(polygon.size())
	for k in polygon:
		var vec = k - center
		var move = vec.normalized() * growth_ratio
		ret.push_back(k + move)
	return ret
func grow_segment(polygon, seg):
	var ret = []
	if seg >= polygon.size():
		for k in polygon:
			ret.push_back(k)
		return ret
	var p1 = polygon[seg]
	var p2 = polygon[(seg + 1) % polygon.size()]
	var tangent = (p2 - p1).tangent().normalized()
	var move = tangent * growth_ratio
	for k in polygon:
		ret.push_back(k)
	ret[seg] += move
	ret[(seg + 1) % ret.size()] += move
	return ret
func grow_room_square(item):
	var polygon = []
	var can_grow = false

	if !check_room(item):
		return false
	for k in item.polygon:
		polygon.push_back(k)

	var new_poly = grow_square(polygon)
	if polygon_check_fits(new_poly, item) && polygon_check_overlaps(new_poly, item):
		print("polygon fits ok")
		polygon = new_poly
		can_grow = true
#	if !can_grow:
#		for seg in range(polygon.size()):
#			new_poly = grow_segment(polygon, seg)
#			if polygon_check_fits(new_poly, item) && polygon_check_overlaps(new_poly, item):
#				polygon = new_poly
#				can_grow = true
#				print("polygon grown: ", seg)
	if can_grow:
		item.polygon = polygon
	return can_grow
func grow_room_rect(item):
	var polygon = []
	var can_grow = false

	if !check_room(item):
		return false
	for k in item.polygon:
		polygon.push_back(k)
	var seg = rnd.randi() % polygon.size() 
	var new_poly = grow_segment(polygon, seg)
	if polygon_check_fits(new_poly, item) && polygon_check_overlaps(new_poly, item):
		polygon = new_poly
		can_grow = true
		print("polygon grown: ", seg)
	if can_grow:
		item.polygon = polygon
	return can_grow


func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.seed = rnd_seed
	queue.push_back(create_room(room_classes.flat, null))
var initial_points = []
func get_random_point(item):
	var ret = Transform2D()
	var rect = Rect2()
	for p in item.polygon:
		rect = rect.expand(p)
	ret.origin = Vector2(rect.size.x * rnd.randf(), rect.size.y * rnd.randf()) + rect.position
	while !point_in_polygon(ret.origin, item.polygon):
		ret.origin = Vector2(rect.size.x * rnd.randf(), rect.size.y * rnd.randf()) + rect.position
	return ret
func apply_distance_constraints(k):
	var ret = true
	for other_room in rooms:
		if k == other_room:
			continue
		if k.parent != other_room.parent:
			continue
		if other_room.room in k.class.adjacent:
			continue
		var vec = k.transform.origin - other_room.transform.origin
		var dst = vec.length()
		if dst < (sqrt(k.area) + sqrt(other_room.area)) * 2.0 && !other_room.room in k.class.adjacent:
			k.transform.origin += vec.normalized() * correction
			ret = false
	return ret
func apply_size_constraints(item):
	if check_room(item):
		return true
	if polygon_check_fits(item.polygon, item) && item.class.min_area <= item.area:
		return true
	var ret = []
	var center = Vector2()
	for k in item.polygon:
		center += k
	center *= 1.0 / float(item.polygon.size())
	for k in item.polygon:
		var vec = k - center
		var move = vec.normalized() * correction * item.area / item.parent.area * 0.5
		ret.push_back(k - move)
	item.polygon = ret
	item.area = calculate_polygon_area(item.polygon)
	return check_room(item)
func apply_fit_constraints(item):
	if polygon_check_fits(item.polygon, item):
		return true
	var vec = item.parent.transform.origin - item.transform.origin
	var move = vec.normalized() * correction * 3.0
	item.transform.origin += move
	return false
func apply_wall_distance_constraints(item):
	var ret = true
	var poly_cur = get_translated_polygon(item.polygon, item.transform)
	var parent_cur = get_translated_polygon(item.parent.polygon, item.parent.transform)
	var dst = poly_cur[0].distance_to(parent_cur[0])
	for p1 in poly_cur:
		for p2 in parent_cur:
			var ndst = p1.distance_to(p2)
			if dst > ndst:
				dst = ndst
	if dst < sqrt(item.area) * 8.0:
		var vec = item.parent.transform.origin - item.transform.origin
		item.transform.origin += vec.normalized() * correction * 4.0
		ret = false
	return ret

func apply_adjacency_constraints(item):
	var vec = Vector2()
	var ret = true
	for k in rooms:
		if k == item:
			continue
		if k.room in item.class.adjacent:
			var dst = k.transform.xform(k.polygon[0]).distance_to(item.transform.xform(item.polygon[0]))
			for p1 in item.polygon:
				for p2 in k.polygon:
					if dst > item.transform.xform(p1).distance_to(k.transform.xform(p2)):
						dst = item.transform.xform(p1).distance_to(k.transform.xform(p2))
			if dst > sqrt(item.area) * 2.0:
				var offt = k.transform.origin - item.transform.origin
				vec += offt.normalized() / (1.0 + offt.length()) * correction
				ret = false
	item.transform.origin += vec
	return ret
func apply_overlapping_constraints(item):
	var ret = true
	var poly_cur = get_translated_polygon(item.polygon, item.transform)
	for k in rooms:
		if k == item:
			continue
		var intersects = false
		var poly_other = get_translated_polygon(k.polygon, k.transform)
		for p1 in poly_cur:
			if point_in_polygon(p1, poly_other):
				intersects = true
				break
		if !intersects:
			for p2 in poly_other:
				if point_in_polygon(p2, poly_cur):
					intersects = true
					break
		if intersects:
			var vec = item.transform.origin - k.transform.origin
			item.transform.origin += vec.normalized() * correction * 3.0
			ret = false
	return ret
func apply_constraints(k):
	var ret = true
	if !apply_fit_constraints(k):
#		print("fit failed")
		ret = false
		return ret
	if !apply_distance_constraints(k):
		print("distance failed")
		ret = false
#	if !apply_size_constraints(k):
#		print("size failed")
#		ret = false
	if !apply_fit_constraints(k):
		print("fit failed")
		ret = false
	return ret

func check_room(item):
	return polygon_check_fits(item.polygon, item) && polygon_check_overlaps(item.polygon, item)
enum {STATE_SPAWN, STATE_CONSTRAINTS, STATE_GROW_SQUARE, STATE_GROW_RECT, STATE_CONSTRAINTS_FIT, STATE_PUSH_BACK, STATE_COMPLETE}
var state = STATE_SPAWN
# Called every frame. 'delta' is the elapsed time since the previous frame.
var complete = false
var grow_square = true
func _process(delta):
	if complete:
		return
	match(state):
		STATE_SPAWN:
			print("spawn")
			if queue.size() == 0:
				state = STATE_COMPLETE
			else:
				while queue.size() > 0:
					var item = queue[0]
					queue.pop_front()
					if item.parent == null:
						item.transform = Transform2D()
						item.can_grow = false
					else:
						item.transform = item.parent.transform * get_random_point(item.parent)
						item.can_grow = true
					item.can_spawn = true
					item.grow_mode = 1
					rooms.push_back(item)
				state = STATE_CONSTRAINTS_FIT
		STATE_GROW_SQUARE:
			var could_grow = false
			print("grow square ", rooms.size())
			for k in rooms:
				if k.can_grow:
					could_grow = true
					if rnd.randf() <= k.class.probability_grow:
						grow_room_square(k)
						k.area = calculate_polygon_area(k.polygon)
			if could_grow:
				state = STATE_CONSTRAINTS_FIT
			else:
				state = STATE_GROW_RECT
		STATE_GROW_RECT:
			print("grow rect")
			var could_grow = false
			for k in rooms:
				if !check_room(k):
					continue
				if k.can_grow:
					could_grow = true
					if rnd.randf() <= k.class.probability_grow:
						k.can_grow = grow_room_rect(k)
						k.area = calculate_polygon_area(k.polygon)
			if could_grow:
				state = STATE_CONSTRAINTS
			else:
				state = STATE_PUSH_BACK
		
		STATE_CONSTRAINTS:
			print("constraints")
			var success = false
			for le in range(500):
				success = true
				for k in rooms:
					if k.class.constraints:
						apply_distance_constraints(k)
						apply_adjacency_constraints(k)
						apply_wall_distance_constraints(k)
						apply_overlapping_constraints(k)
						if !apply_fit_constraints(k):
							success = false
				if success:
					break
			if success:
				print("constraints ok")
				var can_grow = false
				for k in rooms:
					if k.can_grow:
						can_grow = true
						break
				if can_grow:
					print("constraints: go to grow")
					state = STATE_GROW_SQUARE
				else:
					state = STATE_PUSH_BACK
			else:
				state = STATE_CONSTRAINTS
		STATE_CONSTRAINTS_FIT:
			print("constraints_fit")
			var success = false
			for le in range(500):
				success = true
				for k in rooms:
					if k.class.constraints:
						apply_distance_constraints(k)
						apply_adjacency_constraints(k)
						apply_wall_distance_constraints(k)
						apply_overlapping_constraints(k)
						if !apply_fit_constraints(k):
							success = false
				if success:
					break
			if grow_square:
				print("go to grow_square")
				state = STATE_GROW_SQUARE
			else:
				state = STATE_GROW_RECT
		STATE_PUSH_BACK:
			print("push")
			for k in rooms:
				if !k.can_grow && k.can_spawn:
					var area = k.area
					print("can't grow")
					for r in k.class.contains:
						var new_room = create_room(room_classes[r], k)
						queue.push_back(new_room)
						area -= new_room.area * 2.0
						if area <= 0:
							break
					k.can_spawn = false
			state = STATE_SPAWN
		STATE_COMPLETE:
			print("complete")
			complete = true
	print(state)
