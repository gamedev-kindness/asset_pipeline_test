extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var max_characters_spawned = 20
var game_input_enabled = false
var console_enabled = false
var inventory_enabled = false
var markov_order = 3
