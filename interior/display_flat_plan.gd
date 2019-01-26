extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var color_data = {
	"corridoor": Color(0, 1, 0, 1),
	"public": Color(1, 1, 1, 1),
	"private": Color(0, 0, 0, 1),
	"flat": Color(1, 0, 1, 1),
}
var cooldown = 0.0
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
	else:
		update()
		cooldown = 1.0
#		print("rooms: ", $flat_plan.rooms.size())
#		for k in $flat_plan.rooms:
#			print("name: ", k.room, " transform: ", k.transform)
#		print("queue: ", $flat_plan.queue.size())
func _draw():
	for p in $flat_plan.rooms:
		var colors = []
		var polygon = []
		var c = Color(1, 0, 1)
		if color_data.has(p.room):
			c = color_data[p.room]
		for pt in p.polygon:
			polygon.push_back(p.transform.xform(pt))
			colors.push_back(c)
#			print(c)
#		print("drawing: ", p.room, " color: ", c, "polygon: ", polygon)
		draw_polygon(polygon, colors)
