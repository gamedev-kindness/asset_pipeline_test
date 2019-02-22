extends Spatial
signal spawn

export var player = false
export var loadable = true
export var top_state = "Stand"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("spawn", self, "spawn")
	add_to_group("spawn")

var spawn_enabled = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var delay = 0.0
var spawned
func spawn():
	spawn_enabled = true
func _process(delta):
	if spawn_enabled:
		print("spawn...")
		var root = get_node("/root")
		var female_count = 0
		var male_count = 0
		for k in get_tree().get_nodes_in_group("characters"):
			if k.name.begins_with("male"):
				male_count += 1
			if k.name.begins_with("female"):
				female_count += 1
#		if awareness.player_character != null && awareness.distance(awareness.player_character, self) > 5.0:
#			delay += awareness.distance(awareness.player_character, self) * 0.2
#			return
			
		if male_count + female_count < settings.max_characters_spawned:
			var characters = content.characters
			var selection = "female"
			if male_count * 2.0 < female_count:
				selection = "male"
			elif male_count  > female_count * 2.0:
				selection = "female"
			else:
				selection = characters.keys()[randi() % characters.keys().size()]
			var c = characters[selection].obj.instance()
			root.add_child(c)
			c.global_transform = global_transform
			spawned = c
		spawn_enabled = false
	elif spawned != null:
		if awareness.at[spawned]["parameters/playback"].is_playing():
				awareness.at[spawned]["parameters/playback"].stop()
				awareness.at[spawned]["parameters/playback"].start(top_state)
				print("SPAWN complete")
				queue_free()
	else:
		pass
