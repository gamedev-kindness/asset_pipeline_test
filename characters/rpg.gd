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
func _process(delta):
	if !character:
		return
	if state == INIT:
		var needs = {}
		var stats = {}
		var skills = {}
		
		for h in $needs.get_children():
			needs[h.name] = 0.0
		awareness.needs[character] = needs
		if !awareness.current_level.has(character):
			awareness.current_level[character] = 1
		if !awareness.skills.has(character):
			for h in $skills.get_children():
				awareness.skill_levels[character] = {}
				awareness.skill_levels[character][h.name] = 1
				skills[h.name] = int(float(h.base_value) * h.curve.interpolate_baked(float(awareness.skill_levels[character][h.name]) / float(h.max_level - h.min_level)))
			awareness.skills[character] = skills
		if !awareness.stats.has(character):
			for h in $stats.get_children():
				stats[h.name] = int(float(h.base_value) * h.curve.interpolate_baked(float(awareness.current_level[character]) / float(max_level - min_level)))
			awareness.stats[character] = stats
		awareness.till_next_level[character] = int(float(score_base) * leveling.interpolate_baked(float(awareness.current_level[character]) / float(max_level - min_level)))
		state = PROCEED
	elif state == PROCEED:
		if awareness.needs.has(character):
			for h in awareness.needs[character].keys():
				if h in ["Hunger", "Thirst", "Toilet1", "Toilet2"]:
					awareness.needs[character][h] += delta / (24.0 * 60.0)
