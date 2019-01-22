extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

var character
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !character:
		return
	var stats = {}
	var skills = {}
	var needs = {}
	for h in $stats.get_children():
		if h.has_method("get_value"):
			stats[h.name] = h.get_value()
		else:
			stats[h.name] = 0.0
	awareness.stats[character] = stats
	for h in $skills.get_children():
		if h.has_method("get_value"):
			skills[h.name] = h.get_value()
		else:
			skills[h.name] = 0.0
	awareness.skills[character] = skills

	for h in $needs.get_children():
		if h.has_method("get_value"):
			needs[h.name] = h.get_value()
		else:
			needs[h.name] = 0.0
	awareness.needs[character] = needs
