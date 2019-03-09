extends Node
class_name FurniturePack
onready var rnd = RandomNumberGenerator.new()
func _ready():
	rnd.seed = OS.get_unix_time()
	print(split_x(Rect2(-10, -10, 20, 20), 3))
	print(split_y(Rect2(-10, -10, 20, 20), 3))
static func split_x(r: Rect2, amount: float) -> Array:
	var r1 = Rect2(r.position, Vector2(amount, r.size.y))
	var r2 = Rect2(r.position + Vector2(amount, 0), Vector2(r.size.x - amount, r.size.y))
	return [r1, r2]
static func split_y(r: Rect2, amount: float) -> Array:
	var r1 = Rect2(r.position, Vector2(r.size.x, amount))
	var r2 = Rect2(r.position + Vector2(0, amount), Vector2(r.size.x, r.size.y - amount))
	return [r1, r2]
func select_one(options: Array) -> String:
	return options[rnd.randi() % options.size()]

func pack(d:Dictionary) -> Dictionary:
	var wall_furniture =  d.room.furniture.wall
	var main_furniture =  d.room.furniture.main
	var center_furniture =  d.room.furniture.center
	var wall = d.room.wall
	var wall_points = []
	for seg in range(wall.size()):
		var p1 = wall[seg]
		var p2 = wall[(seg + 1) % wall.size()]
		var size = p1.distance_to(p2)
		var p = p1
		var dir = (p2 - p1).normalized()
		var n = dir.tangent().normalized()
		while size > 0:
			var selected = select_one(wall_furniture)
			var item = d.furniture[selected]
			var width = item.rect.size.x
			var depth = item.rect.size.y
			var step = dir * width
			var actual_pos = p + step * 0.5 - n * depth * 0.5
			var angle = dir.angle()
			size -= width
			if size > 0:
				wall_points.push_back({"item": selected, "position": actual_pos, "angle": angle})
			p += step	
	return {"points": wall_points}
