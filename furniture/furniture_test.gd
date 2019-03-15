extends Spatial

var contours = [
	[Vector2(-6, -6), Vector2(0.0, -8), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)],
	[Vector2(-16, -6),Vector2(16, -6), Vector2(16, 6), Vector2(-16, 6)],
	[Vector2(-2, -2), Vector2(0.0, -3), Vector2(2, -2), Vector2(2, 2), Vector2(-2, 2)],
]

onready var rooms = {
	"bedroom": {
		"furniture": {
			"wall": ["toilet", "shower"],
			"main": ["bed"],
			"center": []
		},
		"wall": [Vector2(-6, -6), Vector2(0.0, -8), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)]
	},
	"wc": {
		"furniture": {
			"wall": ["toilet"],
			"main": [],
			"center": []
		},
		"wall": [Vector2(-6, -6), Vector2(0.0, -8), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)]
	},
	"bathroom": {
		"furniture": {
			"wall": ["toilet", "shower"],
			"main": [],
			"center": []
		},
		"wall": [Vector2(-6, -6), Vector2(0.0, -8), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)]
	},
	"showerroom": {
		"furniture": {
			"wall": ["shower"],
			"main": [],
			"center": []
		},
		"wall": [Vector2(-6, -6), Vector2(0.0, -8), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)]
	}
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
		"rect": Rect2(-3, -3, 6, 6)
	}
}
onready var data = {
	"furniture": furniture,
	"room": null
}
func _ready():
	var room_kn = $furniture_pack.rnd.randi() % rooms.keys().size()
	var room_k = rooms.keys()[room_kn]
	data.room = rooms[room_k].duplicate()
	var contour_no = $furniture_pack.rnd.randi() % contours.size()
	data.room.wall = contours[contour_no]
	var points = $furniture_pack.pack(data)
	for k in points.points:
		print(k)
		var node = data.furniture[k.item].node
		var nodei = node.instance()
		add_child(nodei)
		nodei.translation = Vector3(k.position.x, 0.0, k.position.y)
		nodei.rotation.y = -k.angle

