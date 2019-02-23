extends Spatial
class_name SpawnPoint
signal spawn

export var player = false
export var loadable = true
export var parented = false
export var vehicle = false
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
		if parented || vehicle:
			root = get_parent()
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
		if awareness.character_save_data.empty() || loadable == false:
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
				if top_state != "Sleep" && !vehicle:
					c.enable_all_shapes()
				elif vehicle:
					c.enable_no_shapes()
					c.vehicle = true
					awareness.passenger_mode[c] = {}
				root.add_child(c)
				c.global_transform = global_transform
#				if parented:
#					c.add_collision_exception_with(root)
#					root.add_collision_exception_with(c)
				c.init_data()
				spawned = c
			spawn_enabled = false
		elif !awareness.character_save_data.empty() && loadable == true && player == false:
			var spawn_player = true
			# Do not spawn player if current point have player unset and one of them have it set.
			# Otherwise allow player random placing within spawn points
			for k in get_tree().get_nodes_in_group("spawn"):
				if k.player:
					spawn_player = false
					break
			var selection
			var names = awareness.character_save_data.keys()
			if spawn_player:
				selection = names[randi() % names.size()]
			else:
				if names.size() == 1 && awareness.character_save_data[names[0]].posessed:
					# Do not spawn anything in this case
					spawn_enabled = false
					spawned = null
					print("Can't spawn")
					queue_free()
				else:
					while true:
						selection = names[randi() % names.size()]
						if !awareness.character_save_data[selection].posessed:
							break
			if selection != null:
				var selected_data = awareness.character_save_data[selection].duplicate()
				awareness.character_save_data.erase(selection)
				var obj = content.characters[selected_data.gender].obj.instance()
				if top_state != "Sleep" && !vehicle:
					obj.enable_all_shapes()
				elif vehicle:
					obj.enable_no_shapes()
					obj.vehicle = true
				root.add_child(obj)
				obj.global_transform = global_transform
#				if parented:
#					obj.add_collision_exception_with(root)
#					root.add_collision_exception_with(obj)
				awareness.character_data[obj] = {}
				for k in selected_data.keys():
					if k == "transform":
						continue
					elif k == "posessed":
						obj.posessed = selected_data[k]
						if obj.posessed:
							awareness.player_character = obj
					else:
						awareness.character_data[obj][k] = selected_data[k]
				spawned = obj
			spawn_enabled = false
		elif !awareness.character_save_data.empty() && loadable == true && player == true:
			var selection
			var names = awareness.character_save_data.keys()
			for k in names:
				if awareness.character_save_data[k].posessed:
					selection = k
					break
			if selection != null:
				var selected_data = awareness.character_save_data[selection].duplicate()
				awareness.character_save_data.erase(selection)
				var obj = content.characters[selected_data.gender].obj.instance()
				if top_state != "Sleep" && !vehicle:
					obj.enable_all_shapes()
				elif vehicle:
					obj.enable_no_shapes()
					obj.vehicle = true
					awareness.passenger_mode[obj] = {}
				root.add_child(obj)
				obj.global_transform = global_transform
#				if parented:
#					obj.add_collision_exception_with(root)
#					root.add_collision_exception_with(obj)
				awareness.character_data[obj] = {}
				for k in selected_data.keys():
					if k == "transform":
						continue
					elif k == "posessed":
						obj.posessed = selected_data[k]
						if obj.posessed:
							awareness.player_character = obj
					else:
						awareness.character_data[obj][k] = selected_data[k]
				spawned = obj
			spawn_enabled = false

	elif spawned != null:
		if awareness.at[spawned]["parameters/playback"].is_playing():
				awareness.at[spawned]["parameters/playback"].stop()
				awareness.at[spawned]["parameters/playback"].start(top_state)
				print("SPAWN complete")
				queue_free()
	else:
		pass
