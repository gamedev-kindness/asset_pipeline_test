extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func display_main():
	var sc = load("res://ui/menu_root.tscn")
	get_tree().change_scene_to(sc)
func display_action_editor():
	var sc = load("res://ui/graph-editors/action_editor.tscn")
	get_tree().change_scene_to(sc)
func display_opportunity_editor():
	var sc = load("res://ui/graph-editors/opportunity-editor.tscn")
	get_tree().change_scene_to(sc)
func display_ai_editor():
	var sc = load("res://ui/graph-editors/ai_editor.tscn")
	get_tree().change_scene_to(sc)
func display_furniture_layout_editor():
	var sc = load("res://furniture/placement/layoout_editor.tscn")
	get_tree().change_scene_to(sc)
func _ready():
	$v/main_menu.connect("pressed", self, "display_main")
	$v/action_editor.connect("pressed", self, "display_action_editor")
	$v/opportunity_editor.connect("pressed", self, "display_opportunity_editor")
	$v/AI.connect("pressed", self, "display_ai_editor")
	$v/furniture_layout.connect("pressed", self, "display_furniture_layout_editor")
