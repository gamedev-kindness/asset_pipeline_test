extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

var anim_param_pb

func _ready():
	anim_param_pb = AnimationParameterPlayback.new()
	rect_size.y = 80
	rect_min_size.y = 80
	var jf = File.new()
	for k in anim_param_pb.get_opportunity_list():
		print(k)
		var txr = TextureRect.new()
		txr.rect_size = Vector2(80, 80)
		txr.rect_min_size = Vector2(80, 80)
		add_child(txr)
		var icon = Image.new()
		var icon_path = anim_param_pb.get_opportunity_icon_path(k)
		if jf.file_exists(icon_path):
			icon.load(icon_path)
		print(icon)
		var tex = ImageTexture.new()
		tex.create_from_image(icon)
		print(tex)
		txr.texture = tex
		txr.name = k
		txr.expand = true
		txr.hide()
	update()
	print(rect_size)
	for k in get_children():
		print(k.name, " ", k.rect_position, " ", k.rect_size)

var cooldown = 0.0
func _process(delta):
	var current
	if cooldown > 0.5:
		cooldown -=delta
		return
	current = awareness.player_character
	if !current:
		cooldown = 0.5
		return
	for k in anim_param_pb.get_opportunity_list():
		get_node(k).hide()
	if awareness.active_items.has(current):
		for i in awareness.active_items[current]:
			if i.is_in_group("characters") && !awareness.action_mode.has(current):
				for k in anim_param_pb.get_opportunity_list():
					var other_dir = awareness.get_other_direction(current, i)
					if anim_param_pb.get_opportunity_direction(k) == "ANY":
						get_node(k).show()
					elif other_dir == anim_param_pb.get_opportunity_direction(k):
						get_node(k).show()
					elif other_dir in ["LEFT", "RIGHT"] && anim_param_pb.get_opportunity_direction(k) == "SIDES":
						get_node(k).show()
	cooldown = 0.6
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
		print("action")
		if action != "Talk":
			var other = awareness.get_actuator_body(awareness.player_character, "characters")
			anim_param_pb.play_opportunity(awareness.player_character, other, action)
		else:
			awareness.player_character.emit_signal("ui_action", action)
