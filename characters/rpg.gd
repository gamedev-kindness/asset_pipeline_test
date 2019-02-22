extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

export var leveling: Curve = Curve.new()

var health = 0.0
var stamina = 0.0



var character
var min_level = 1
var max_level = 100
var score_base = 1000
enum {INIT, PROCEED}
var state = INIT
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
var traits = [
	{
		"name": "Sleeping Beauty",
		"probability": 0.2
	},
	{
		"name": "Evil",
		"probability": 0.1
	},
	{
		"name": "Always hungry",
		"probability": 0.1
	},
	{
		"name": "Horny",
		"probability": 0.1
	},
	{
		"name": "Promisceous",
		"probability": 0.1
	}
]

func _process(delta):
	if !character:
		return
	if state == INIT:
		var needs = {}
		var stats = {}
		var skills = {}
		
		for h in $needs.get_children():
			needs[h.name] = 0.0
		awareness.character_data[character].needs = needs
		if awareness.character_data[character].skills.empty():
			awareness.character_data[character].skill_levels = {}
			for h in $skills.get_children():
				awareness.character_data[character].skill_levels[h.name] = 1
				skills[h.name] = int(float(h.base_value) * h.curve.interpolate_baked(float(awareness.character_data[character].skill_levels[h.name]) / float(h.max_level - h.min_level)))
			awareness.character_data[character].skills = skills
		if awareness.character_data[character].stats.empty():
			for h in $stats.get_children():
				stats[h.name] = int(float(h.base_value) * h.curve.interpolate_baked(float(awareness.character_data[character].current_level) / float(max_level - min_level)))
			awareness.character_data[character].stats = stats
		awareness.character_data[character].till_next_level = int(float(score_base) * leveling.interpolate_baked(float(awareness.character_data[character].current_level) / float(max_level - min_level)))
		var need_changes = {
			"Toilet1": 1.0 / (8.0 * 60.0),
			"Toilet2": 1.0 / (24.0 * 60.0),
			"Hunger": 1.0 / (72.0 * 60.0),
			"Thirst": 1.0 / (24.0 * 60.0),
			"Shower": 1.0 / (24.0 * 60.0),
			"Safety": 0.0,
			"Socialization": 1.0 / (8.0 * 60.0),
			"Horniness": 1.0 / (24.0 * 60.0)
		}
		awareness.need_changes[character] = {}
		for k in need_changes.keys():
			awareness.need_changes[character][k] = randf() * 0.5 * need_changes[k] + need_changes[k] * 0.5
		if awareness.character_data[character].traits.empty():
			awareness.character_data[character].traits = []
			for k in traits:
				if randf() <= k.probability:
					awareness.character_data[character].traits.push_back(k.name)
		state = PROCEED
	elif state == PROCEED:
		if !awareness.character_data[character].needs.empty():
			for h in awareness.character_data[character].needs.keys():
				if awareness.need_changes[character].has(h):
					awareness.character_data[character].needs[h] += delta * awareness.need_changes[character][h]
				else:
					awareness.character_data[character].needs[h] += delta / (24.0 * 60.0 * 10.0)
