class_name Rewind extends Node

## Mask to flatten vectors via v * mask for simplicity
const FLATTEN_MASK := Vector3(1,0,1)

## Common inverse scale. Calculated as 1.0 / Inverse Scale Factor.
## Used to help translate properties using Quake Units into Godot Units.
const Q_INVERSE_SCALE: float = 0.03125

## Converts Quake 1 axis to Godot axis (taken from Func_Godot)
static func Q_q2g_vec(vec: Variant)->Vector3:
	var org: Vector3 = Vector3.ZERO
	if vec is Vector3:
		org = vec
	elif vec is String:
		var arr: PackedFloat64Array = (vec as String).split_floats(" ")
		for i in max(arr.size(), 3):
			org[i] = arr[i]
	return Vector3(org.y, org.z, org.x)