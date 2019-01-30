extends Spatial

export var outside_wall_mesh: Mesh = Mesh.new()
export var internal_wall1: PackedScene
export var internal_wall4: PackedScene
export var internal_floor: PackedScene
export var internal_angle: PackedScene
export var internal_door: PackedScene
export var toilet: PackedScene
export var shower: PackedScene
export var bed: PackedScene

var outline = [Vector2(-10, -20), Vector2(0, -21), Vector2(10, -20), Vector2(10, 20), Vector2(-10, 20)]
var doors = [Vector2(-10, 0)]

var wall_width = 2.0

var rnd

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

func build_outline():
	for m in range(outline.size()):
		var p1 = outline[m]
		p1 = Vector2(p1.x , p1.y)
		var p2 = outline[(m + 1) % outline.size()]
		p2 = Vector2(p2.x , p2.y)
		var dir = (p2 - p1).normalized()
		var p = p1
		while p.distance_to(p2) >= wall_width:
			var pos = p + dir * (wall_width / 2.0)
			var actual_pos = Vector3(pos.x, 1.3, pos.y)
			var sp = MeshInstance.new()
			sp.mesh = outside_wall_mesh
			add_child(sp)
			sp.translation = actual_pos
			sp.rotation.y = -(p2 - p1).angle()
			p += dir * wall_width

func build_rooms():
	for r in $random_split.rects:
		var width_x = int(r.size.x + 0.5)
		var width_y = int(r.size.y + 0.5)
#		r.position.x = int(r.position.x * 0.5 - 0.5) * 2.0
#		r.position.y = int(r.position.y * 0.5 - 0.5) * 2.0
#		r.size.x = int(r.size.x * 0.5) * 2.0
#		r.size.y = int(r.size.y * 0.5) * 2.0
		
		for h in range(width_y):
			for i in range(width_x):
				var angle = 0.0
				var wall = false
				var wall_angle = false
				var door = false
				if h in [0, width_y - 1] && i in [0, width_x - 1]:
					wall_angle = true
					if h == 0 && i == 0:
						angle = PI
					elif h == width_y - 1 && i == width_x - 1:
						angle = 0
					if i == 0 && h == width_y - 1:
						angle = -PI / 2.0
					elif i == width_x - 1 && h == 0:
						angle = PI / 2.0
				elif h in [0, width_y - 1] && i in range(width_x):
					wall = true
					if h == 0:
						angle = PI
					elif h == width_y - 1:
						angle = 0
				elif i in [0, width_x - 1] && h in range(width_y):
					wall = true
					if i == 0:
						angle = -PI / 2.0
					elif i == width_x - 1:
						angle = PI / 2.0
				if wall:
					for d in $random_split.door_data:
						if (Vector2(r.position.x + i, r.position.y + h) - Vector2(-0.5, -0.5)).distance_to(d.pos) < 1.0:
							door = true
							wall = false
				if wall:
					var wall_model = internal_wall1.instance()
					add_child(wall_model)
					wall_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
					wall_model.rotation.y = angle
					if rnd.randf() > 0.98:
						var toilet_model = toilet.instance()
						add_child(toilet_model)
						var offset = Vector3(0.0, 0, -0.1)
						var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
						toilet_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h) + tf
						toilet_model.rotation.y = PI + angle
					elif rnd.randf() > 0.995:
						var shower_model = shower.instance()
						add_child(shower_model)
						var offset = Vector3(0.0, 0, -0.1)
						var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
						shower_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h) + tf
						shower_model.rotation.y = PI + angle
				elif door:
					for d in $random_split.door_data:
						if (Vector2(r.position.x + i, r.position.y + h) - Vector2(-0.5, -0.5)).distance_to(d.pos) < 1.0:
							var door_model = internal_door.instance()
							add_child(door_model)
							door_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
							door_model.rotation.y = angle
				elif wall_angle:
					var angle_model = internal_angle.instance()
					add_child(angle_model)
					angle_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
					angle_model.rotation.y = angle
					print(angle)
				else:
					var floor_model = internal_floor.instance()
					add_child(floor_model)
#					var offset = Vector3(-0.5, 0, -0.5)
#					var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
					floor_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
					floor_model.rotation.y = angle
		var bed_model = bed.instance()
		add_child(bed_model)
		bed_model.translation = Vector3(r.position.x + r.size.x / 2.0, 0.0, r.position.y + r.size.y / 2.0)
#		var p1 = r.position
#		var p2 = r.position + Vector2(r.size.x, 0)
#		var p3 = r.position + Vector2(r.size.x, r.size.y)
#		var p4 = r.position + Vector2(0, r.size.y)
#		var points = [p1, p2, p3, p4]
#		var angles = [PI, PI / 2.0, 0, -PI / 2.0]
#		for k in range(points.size()):
#			var pa1 = points[k]
#			var pa2 = points[(k + 1) % points.size()]
#			var angle = angles[k]
#			var p = pa1
#			var dir = (pa2 - pa1).normalized()
#			while p.distance_to(pa2) >= 1.0:
#				var wall = internal_wall1.instance()
#				var pos = p
#				var actual_pos = Vector3(pos.x, 0.0, pos.y)
#				add_child(wall)
#				var offset = Vector3(-1, 0, -1)
#				var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
#				wall.translation = actual_pos + tf
#				wall.rotation.y = angles[k]
#				p += dir
			
		
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func plan_complete():
	print("complete: ", $random_split.rects.size(), " ", $random_split.door_data.size())
	build_outline()
	build_rooms()
	build_navigation()
	for k in get_tree().get_nodes_in_group("beds"):
		k.emit_signal("spawn")

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.seed = OS.get_unix_time()
	$random_split.rnd = rnd
	$random_split.outline = outline
	$random_split.doors = doors
	$random_split.connect("complete", self, "plan_complete")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
