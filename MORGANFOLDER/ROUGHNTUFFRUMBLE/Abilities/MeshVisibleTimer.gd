extends Timer

@export var thing : Node = null

func _on_timeout() -> void:
	thing.visible = false
