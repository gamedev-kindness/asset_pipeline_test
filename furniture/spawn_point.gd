extends Spatial
signal spawn
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("beds")
	connect("spawn", self, "spawn")
func spawn():
	var root = get_node("/root")
	var characters = [load("res://characters/female_2018.tscn"), load("res://characters/female_2018.tscn"), load("res://characters/male_2018.tscn")]
	var selection = characters[randi() % characters.size()]
	var c = selection.instance()
	root.add_child(c)
	c.global_transform = global_transform
	print("SPAWN")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
