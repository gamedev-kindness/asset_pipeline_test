extends Spatial

onready var room = {
	"furniture": {
		"wall": ["toilet", "shower"],
		"main": ["bed"],
		"center": []
	},
	"wall": [Vector2(-6, -6), Vector2(0.0, -8), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)]
}
onready var furniture = {
	"toilet": {
		"node": load("res://furniture/sets/toilet.tscn"),
		"rect": Rect2(-0.5, -0.5, 1, 1)
	},
	"shower": {
		"node": load("res://furniture/sets/shower.tscn"),
		"rect": Rect2(-0.5, -0.5, 1, 1)
	},
	"bed": {
		"node": load("res://furniture/bed.tscn"),
		"rect": Rect2(-1, -1, 2, 2)
	}
}
onready var data = {
	"furniture": furniture,
	"room": room
}
func _ready():
	var points = $furniture_pack.pack(data)
	for k in points.points:
		print(k)
		var node = data.furniture[k.item].node
		var nodei = node.instance()
		add_child(nodei)
		nodei.translation = Vector3(k.position.x, 0.0, k.position.y)
		nodei.rotation.y = -k.angle

