extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var wide = 2.0
var depth = 2.0
var size = 0.4
func rebuild():
	var start = Vector3(-wide, 0.5, -depth)
	for c in get_children():
		if c.is_in_group("pickup"):
			c.queue_free()
	for k in awareness.inventory[awareness.player_character]:
		var i = content.items[k]
		var ii = i.obj.instance()
		add_child(ii)
		ii.translation = start
		start.x += size
		if start.x > wide:
			start.x = -wide
			start.z += size
			if start.z > depth:
				start.x = -wide
				start.z = -depth
				start.y += size
func cleanup():
	for c in get_children():
		if c.is_in_group("pickup"):
			c.queue_free()
