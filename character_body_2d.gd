extends CharacterBody2D

var speed : int

func _ready():
	speed = 100

func get_input():
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed

func _physics_process(_delta):
	#player movement
	get_input()
	move_and_slide()
	
	if Input.is_action_just_pressed("left"):
		$AnimatedSprite2D.animation = "walk W"
	elif Input.is_action_just_pressed("right"):
		$AnimatedSprite2D.animation = "walk E"
	elif Input.is_action_just_pressed("up"):
		$AnimatedSprite2D.animation = "walk N"
	elif Input.is_action_just_pressed("down"):
		$AnimatedSprite2D.animation = "walk S"
	elif Input.is_action_pressed("left") and Input.is_action_pressed("up"):
		$AnimatedSprite2D.animation = "walk NW"
	elif Input.is_action_pressed("left") and Input.is_action_pressed("down"):
		$AnimatedSprite2D.animation = "walk SW"
	elif Input.is_action_pressed("right") and Input.is_action_pressed("down"):
		$AnimatedSprite2D.animation = "walk SE"
	elif Input.is_action_pressed("right") and Input.is_action_pressed("up"):
		$AnimatedSprite2D.animation = "walk NE"
