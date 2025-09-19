extends RigidBody3D

var tar = null
var moveTimer = 0
var moveTimerMax = 3
var moveSpeed = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tar == null:
		#FIND PLAYER
		var players = get_tree().get_nodes_in_group("player")
		for player in players:
			if player is CharacterBody3D:
				tar = player
	#MOVE TOWARDS THEM
	if tar != null:
		var dis = (tar.global_position - global_position).length();
		var dir = (tar.global_position - global_position).normalized()
		if moveTimer<0:
			linear_velocity = dir*moveSpeed
			moveTimer = 1+(randf()*moveTimerMax)
		else:
			moveTimer-=1*delta
		if dis>250:
			linear_velocity = dir*15
	#LIGHT CHANGES BASED ON SPEED
	var a = linear_velocity.length()
	$OmniLight3D.light_energy = a*3
	$OmniLight3D.omni_range = a*15

func _on_kill_zone_body_entered(body: Node3D) -> void:
	#CHECK IF COLLIDING WITH PLAYER
	if body is CharacterBody3D:
		body.velocity+=linear_velocity
	if body is RigidBody3D:
		body.linear_velocity+=linear_velocity
