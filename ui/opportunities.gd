extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var cooldown = 0.0
var front_grab_mode = false
func _process(delta):
	var current
	if cooldown > 0.5:
		cooldown -=delta
		return
	current = awareness.player_character
	if !current:
		cooldown = 0.5
		return
	$LeaveAction.hide()
	$Talk.hide()
	$GrabFromBack.hide()
	$KickToBed.hide()
	$FrontGrab.hide()
	$FrontGrabFaceSlap.hide()
	$PickUpItem.hide()
	$Missionary1.hide()
	$WakeUp.hide()
	if awareness.active_items.has(current):
		for i in awareness.active_items[current]:
			if i.is_in_group("characters") && !current.action:
				$Talk.show()
				if awareness.at[i].get_current_node() == "Sleeping":
					$WakeUp.show()
				if awareness.get_other_direction(current, i) == "BACK":
					$GrabFromBack.show()
					$KickToBed.show()
				elif awareness.get_other_direction(current, i) == "FRONT":
					$FrontGrab.show()
			elif current.action:
				$LeaveAction.show()
				if front_grab_mode:
					$FrontGrabFaceSlap.show()
					$Missionary1.show()
			if i.is_in_group("pickup") || i.is_in_group("pickables") || i.is_in_group("pickups"):
				$PickUpItem.show()
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
		if action == "FrontGrab" && front_grab_mode == false:
			front_grab_mode = true
		elif action == "LeaveAction" && front_grab_mode == true:
			front_grab_mode = false
		if awareness.player_character:
			awareness.player_character.emit_signal("ui_action", action)
