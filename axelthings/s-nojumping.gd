extends Label

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("space"):
		self.visible = true
		$AnimationPlayer.play("new_animation")
		$AudioStreamPlayer.play()
