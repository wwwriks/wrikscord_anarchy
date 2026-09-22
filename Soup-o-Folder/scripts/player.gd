extends CharacterBody3D

var speed=8.0
var jump_velocity=4

var hp=3

var mouse_sens=0.005

var reloading=false
var current_gun="pistol"
var ammo=25
var total_ammo=25

const max_look_up=deg_to_rad(90)
const max_look_down=deg_to_rad(-90)

var rotation_y=0.0
var rotation_x=0.0

var bob_time=0.0

var bob_speed=10.0
var bob_amount=0.025
var bob_side_amount=0.02
var bob_roll_amount=0.2

var weapon_position=Vector3.ZERO
var weapon_rotation=Vector3.ZERO

@onready var camera=$Camera3D
@onready var items=$Camera3D/items

func update_ammo_label():
	$ui/ammo_label.text="[shake]"+str(ammo)

func _ready() -> void:
	update_ammo_label()
	blood_handler()
	$MeshInstance3D.hide()
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	weapon_position=items.position
	weapon_rotation=items.rotation

func blood_handler():
	match hp:
		3:
			$ui/blood.modulate="#96969600"
		2:
			$ui/blood.modulate="#969696a1"
		3:
			$ui/blood.modulate="#969696"

func reload():
	reloading=true
	$Camera3D/items/items_anim.play("machinegun_reload")
	await $Camera3D/items/items_anim.animation_finished
	ammo=total_ammo
	update_ammo_label()
	reloading=false

func shoot():
	if not $Camera3D/items/items_anim.is_playing() and ammo>0:
		$Camera3D/items/items_anim.play("machinegun_shoot")
		ammo-=1
		update_ammo_label()
	if ammo<=0:
		reload()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode()==Input.MOUSE_MODE_CAPTURED:
		rotation_y-=event.relative.x*mouse_sens
		rotation_x-=event.relative.y*mouse_sens
		rotation_x=clamp(rotation_x,max_look_down,max_look_up)

func _process(delta: float) -> void:
	rotation.y=rotation_y
	camera.rotation.x=rotation_x
	var horizontal_velocity=Vector3(velocity.x, 0, velocity.z)
	var movement_speed=horizontal_velocity.length()
	var input_dir:=Input.get_vector("left", "right", "up", "down")
	if movement_speed > 0.1 and is_on_floor():
		bob_time+=delta*bob_speed*(movement_speed/speed)
		var bob_x=sin(bob_time)*bob_side_amount
		var bob_y=abs(cos(bob_time))*bob_amount
		var target_position=weapon_position
		target_position.x+=bob_x
		target_position.y-=bob_y
		items.position=items.position.lerp(target_position,delta*12.0)
		var target_rotation=weapon_rotation
		target_rotation.z-=input_dir.x*bob_roll_amount
		target_rotation.x-=sin(bob_time*2.0)*0.015
		items.rotation=items.rotation.lerp(target_rotation,delta*12.0)
	else:
		items.position=items.position.lerp(weapon_position,delta*10.0)
		items.rotation=items.rotation.lerp(weapon_rotation,delta*10.0)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity+=get_gravity()*delta
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y=jump_velocity
	if Input.is_action_pressed("shoot") and reloading==false:
		shoot()
	if Input.is_action_just_pressed("reload") and reloading==false:
		reload()
	var input_dir:=Input.get_vector("left", "right", "up", "down")
	var direction:=(transform.basis*Vector3(input_dir.x,0,input_dir.y)).normalized()
	if direction:
		velocity.x=direction.x*speed
		velocity.z=direction.z*speed
	else:
		velocity.x=move_toward(velocity.x,0,speed)
		velocity.z=move_toward(velocity.z,0,speed)

	move_and_slide()
