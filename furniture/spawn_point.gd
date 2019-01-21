extends Spatial
signal spawn
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var spawn_enabled = false
func _ready():
	add_to_group("beds")
	connect("spawn", self, "spawn")

var delay = 0.0
func spawn():
	spawn_enabled = true
	delay = randf() * 3.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if delay > 0.0:
		delay -=delta
		return
	if spawn_enabled:
		var root = get_node("/root")
		var female_count = 0
		var male_count = 0
		for k in get_tree().get_nodes_in_group("characters"):
			if k.name.begins_with("male"):
				male_count += 1
			if k.name.begins_with("female"):
				female_count += 1
		if awareness.player_character != null && awareness.distance(awareness.player_character, self) > 5.0:
			delay += awareness.distance(awareness.player_character, self) * 0.2
			return
			
		if male_count + female_count < settings.max_characters_spawned:
			var characters = [load("res://characters/female_2018.tscn"), load("res://characters/male_2018.tscn")]
			var selection = 0
			if male_count * 2.0 < female_count:
				selection = 1
			elif male_count  > female_count * 2.0:
				selection = 0
			else:
				selection = randi() % characters.size()
			var c = characters[selection].instance()
			root.add_child(c)
			c.global_transform = global_transform
			print("SPAWN")
		spawn_enabled = false
		queue_free()
	else:
		delay = 0.5 + randf() * 2.0

