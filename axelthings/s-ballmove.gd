extends AudioStreamPlayer3D

func _process(delta: float) -> void:
	var ball = self.get_parent()
	if ball.get_class() == "CharacterBody3D":
		var speed = ball.velocity.length()
		if speed < 0.1:
			self.volume_db = -1000.0
		else:
			self.volume_db = 0.0
