extends BTBase
class_name BTDecorator

func init(obj):
	pass

func run(obj, delta):
	if get_children_count() > 0:
		status = c._execute(obj, delta)
		return status
	return BT_OK

func exit(obj, status):
	pass

