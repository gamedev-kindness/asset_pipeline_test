extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$random_split.outline = $outline.polygon
	$random_split.doors = [$door1, $door2, $door3]

# Called every frame. 'delta' is the elapsed time since the previous frame.
var cooldown = 0.0
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
		return
	update()
	cooldown = 1.0

func _draw():
	var colors = []
	for k in $outline.polygon:
		colors.push_back(Color(1, 0, 0, 1))
	draw_polygon($outline.polygon, colors)
	for k in $random_split.queue:
		draw_rect(k, Color(0, 1, 0, 1), false)
	for k in $random_split.rects:
		draw_rect(k, Color(0, 0, 0, 1), false)
	for k in $random_split.border_rects:
		draw_rect(k, Color(0, 0, 1, 1), false)
	for k in $random_split.grow_rects:
		draw_rect(k.rect, Color(1, 1, 0, 1), false)
	for k in $random_split.corridoor_queue:
		draw_line(k[0], k[1], Color(1, 0.6, 0.6, 1), 1.5, true)
		draw_line(k[1], k[2], Color(1, 0.6, 0.6, 1), 1.5, true)
	for k in $random_split.corridoors:
		draw_line(k[0], k[1], Color(0, 0.6, 0.6, 1), 1.2, true)
		draw_line(k[1], k[2], Color(0, 0.6, 0.6, 1), 1.2, true)
	for k in $random_split.rooms:
		for h in k.doors:
			draw_circle(k.rect.position + k.rect.size / 2.0 + Vector2(h.x * k.rect.size.x / 2.0, h.y * k.rect.size.y / 2.0), 0.1, Color(0, 1, 1, 1))
