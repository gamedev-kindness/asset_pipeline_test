extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var cooldown = 0.0
func _process(delta):
	var current
	if cooldown > 0.1:
		cooldown -=delta
		return
	for c in get_tree().get_nodes_in_group("characters"):
		if c.posessed:
			current = c
			break
	if !current:
		cooldown = 0.5
		return
	$LeaveAction.hide()
	$Talk.hide()
	$GrabFromBack.hide()
	$KickToBed.hide()
	var awareness = current.get_node("awareness")
	for i in awareness.active_items:
		if i.is_in_group("characters") && !current.action:
			$Talk.show()
			if awareness.get_other_direction(i) == "BACK":
				$GrabFromBack.show()
				$KickToBed.show()
		elif current.action:
			$LeaveAction.show()
	cooldown = 1.0
	update()
func _input(event):
	var action
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed == false:
			if get_rect().has_point(event.position):
				for c in get_children():
					if c.is_visible():
						if c.get_rect().has_point(event.position - get_rect().position):
							action = c.name
							break
	if action != null:
		for c in get_tree().get_nodes_in_group("characters"):
			if c.posessed:
				c.emit_signal("ui_action", action)
				break
