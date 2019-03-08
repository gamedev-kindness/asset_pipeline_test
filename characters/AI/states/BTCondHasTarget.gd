extends BTConditional
class_name BTCondHasTarget

func run(obj, delta):
	if awareness.targets.has(obj):
		return BT_OK
	else:
		return BT_ERROR
		
