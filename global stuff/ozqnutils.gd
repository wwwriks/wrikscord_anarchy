extends RefCounted
class_name OzqnUtils

static func exp_decay(a, b, speed, delta) -> Variant:
	return b + (a - b) * exp(-speed * delta)

static func exp_decay_f(a: float, b: float, speed: float, delta: float) -> float:
	return b + (a - b) * exp(-speed * delta)

static func get_children_of_type(parent: Node, type: Variant) -> Array:
	var return_arr := []
	var children := parent.get_children()
	for child in children:
		if is_instance_of(child, type):
			return_arr.append(child)
	return return_arr

static func get_all_children_of_type(parent: Node, type: Variant) -> Array:
	var return_arr := []
	var children := get_all_children(parent)
	for child in children:
		if is_instance_of(child, type):
			return_arr.append(child)
	return return_arr

static func get_all_children(parent: Node) -> Array[Node]:
	var arr: Array[Node] = []
	arr.push_back(parent)
	for child in parent.get_children():
		arr.append_array(get_all_children(child))
	return arr
