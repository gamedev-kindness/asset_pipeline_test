extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var polygon_walls = [Vector2(-4, -4), Vector2(0, -5), Vector2(4, -4), Vector2(4, 4), Vector2(-4, 4)]
func create_wall(width, depth, height, ang1, ang2):
	var cur_width = 4.0
	var cur_depth = 2.0
	var width_mul = width / cur_width
	var depth_mul = depth / cur_depth
	var wall_mesh:ArrayMesh = load("res://rooms/room_kit/solid_wall_4.mesh")
	var new_mesh = ArrayMesh.new()
	var t1 = Transform(Quat(Vector3(0, 1, 0), ang2))
	print("angle: ", rad2deg(ang2), " offset :", ang2)
	for s in range(wall_mesh.get_surface_count()):
		var mdt = MeshDataTool.new()
		mdt.create_from_surface(wall_mesh, s)
		for v in mdt.get_vertex_count():
			var vt = mdt.get_vertex(v)
			vt.x *= width_mul
			vt.z *= depth_mul
			if vt.x > width / 2.0 - 0.2 && vt.z > 0:
				if ang1 != 0:
					vt.x +=  2.0 * vt.z * ang1 / PI
#				print(vt.x)
#				vt = t1.xform(vt)
			if vt.x < -width / 2.0 + 0.3 && vt.z > 0:
				if ang2 != 0:
					vt.x -= 2.0 * vt.z * ang2 / PI
#					print(vt.x)
##				print(vt.x)
			mdt.set_vertex(v, vt)
			var uv = mdt.get_vertex_uv(v)
			uv.x *= depth_mul
			mdt.set_vertex_uv(v, uv)
		mdt.commit_to_surface(new_mesh)
	return new_mesh
func create_wall_at(tf: Transform, width, depth, height, ang1, ang2):
	var mi = MeshInstance.new()
	mi.mesh = create_wall(width, depth, height, ang1, ang2)
	add_child(mi)
	mi.transform = tf
func create_wall_segment(p1, p2, depth, height, ang1, ang2):
	var vec = p2 - p1
	var width = vec.length()
	var pos = p1.linear_interpolate(p2, 0.5)
	var angle = vec.angle()
	var tf = Transform(Quat(Vector3(0, 1, 0), PI - angle))
	tf.origin = Vector3(pos.x, 0, pos.y)
	create_wall_at(tf, width, depth, height, ang1, ang2)
#
	
func _ready():
	pass
#	var wall_mesh = load("res://rooms/room_kit/solid_wall_1.mesh")
#	
#	var poly = CSGPolygon.new()
#	var polygon = [Vector2(0, 0), Vector2(0, 3), Vector2(0.2, 3), Vector2(0.2, 0)]
#	poly.polygon = polygon
#	poly.mode = CSGPolygon.MODE_PATH
#	var pathnode = Path.new()
#	pathnode.curve = Curve3D.new()
#	for p in polygon_walls:
#		pathnode.curve.add_point(Vector3(p.x, 0, p.y))
#	add_child(pathnode)
#	poly.path_node = pathnode.get_path()
#	poly.path_rotation = CSGPolygon.PATH_ROTATION_PATH_FOLLOW
#	poly.invert_faces = true
#	poly.material = load("res://rooms/common/wall_material.tres")
#	add_child(poly)
#	var angles = []
##	var p1 = polygon_outside[0]
##	var p2 = polygon_outside[1]
##	var p3 = polygon_outside[2]
##	var p4 = polygon_outside[3]
##	create_wall_segment(p1, p2, 2.0, 3.0, (p2- p1).angle_to(p3-p2))
##	create_wall_segment(p2, p3, 2.0, 3.0, (p3 - p2).angle_to(p4-p3))
#	for p in range(polygon_walls.size()):
#		var p1 = polygon_walls[p]
#		var p2 = polygon_walls[(p + 1) % polygon_walls.size()]
#		var p3 = polygon_walls[(p + 2) % polygon_walls.size()]
#		angles.push_back((p2 - p1).angle_to(p3-p2))
#	for p in range(polygon_walls.size()):
#		if p == door_segment:
#			continue
#		var p1 = polygon_walls[p]
#		var p2 = polygon_walls[(p + 1) % polygon_walls.size()]
#		var a1 = (angles.size() + p - 1) % angles.size()
#		var a2 = (angles.size() + p) % angles.size()
#		create_wall_segment(p1, p2, 2.0, 3.0, angles[a1], angles[a2])
