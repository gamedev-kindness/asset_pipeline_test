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
export var curve: Curve = Curve.new()
export var base_value = 200.0
export var min_level = 1
export var max_level = 1
var level = 1