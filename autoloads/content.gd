extends Node

var characters = {
	"female": {
		"name": "female",
		"obj": load("res://characters/female_2018.tscn")
	},
	"male": {
		"name": "male",
		"obj": load("res://characters/male_2018.tscn")
	}
}
var items = {
	"item": {
		"name": "item",
		"obj": load("res://inventory/pickable.tscn")
	},
	"pickable": {
		"name": "pickable",
		"obj": load("res://inventory/pickable.tscn")
	},
	"pickable_cube": {
		"name": "pickable_cube",
		"obj": load("res://inventory/pickable_cube.tscn")
	},
	"ball": {
		"name": "ball",
		"obj": load("res://inventory/ball.tscn")
	}
}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
