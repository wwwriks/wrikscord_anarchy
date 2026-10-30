extends CharacterBody3D

var speed :=8.0
@export var deceleration := 1.0
@export var acceleration := 1.0
@export var air_acceleration_factor := 2.0
@export var jump_velocity := 1.0

var hp=3
var mouse_sens=0.005
var kills=-1
var reloading=false
var current_gun="gun"
var ammo=8
var total_ammo=8

const max_look_up=deg_to_rad(90)
const max_look_down=deg_to_rad(-90)

var rotation_y=0.0
var rotation_x=0.0
var bob_time=0.0
var last_step=0

var bob_speed=10.0
var bob_amount=0.025
var bob_side_amount=0.02
var bob_roll_amount=0.2

var air_acceleration: float = 1.0
var weapon_position=Vector3.ZERO
var weapon_rotation=Vector3.ZERO

@export var mouse_sway_amount=0.04
@export var mouse_sway_rotation=0.04
@export var jump_sway_amount=0.12
@export var jump_sway_rotation=0.08
@export var sway_speed=8.0

@export var camera_bob_speed=9.0
@export var camera_bob_amount=0.018
@export var camera_bob_side_amount=0.025
@export var camera_bob_forward_amount=0.012
@export var camera_bob_pitch=0.012
@export var camera_bob_roll=0.018

@export var damage_shake_amount=2.5
@export var damage_shake_speed=4.0

@export var shotgun_pellets=15
@export var shotgun_spread=12.0

var mouse_sway=Vector2.ZERO
var jump_sway=0.0
var was_on_floor=true

var damage_shake=0.0
var camera_base_position=Vector3.ZERO
var camera_bob=Vector3.ZERO
var camera_bob_rotation=Vector2.ZERO
var camera_bob_time=0.0

@onready var camera=$Camera3D
@onready var items=$Camera3D/items

@export var bullet_scene: PackedScene=preload("res://Soup-o-Folder/scenes/bullet.tscn")

func update_ammo_label():
	$ui/ammo_label.text="[shake]"+str(ammo)

func _ready() -> void:
	kill_count()
	change_weapon(current_gun)
	update_ammo_label()
	blood_handler()
	$MeshInstance3D.hide()
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	weapon_position=items.position
	weapon_rotation=items.rotation
	camera_base_position=camera.position

func blood_handler():
	if hp>3:
		hp=3
	match hp:
		3:
			$ui/Heart1.show()
			$ui/Heart2.show()
			$ui/Heart3.show()
			$ui/blood.modulate="#96969600"
		2:
			$ui/Heart1.show()
			$ui/Heart2.show()
			$ui/Heart3.hide()
			$ui/blood.modulate="#969696a1"
		1:
			$ui/Heart2.hide()
			$ui/blood.modulate="#969696"
		0:
			DynamicMusicPlayer.instance._play_musical_button()
			var trans := get_tree().get_first_node_in_group("transition_screen") as ColorRect
			var t := create_tween()
			t.tween_interval(2.0)
			t.tween_method(func(f: float):
				trans.set_instance_shader_parameter("factor", f)    
			, 0.0, 1.0, 1.0)
			await DynamicMusicPlayer.instance.finished
			get_tree().change_scene_to_file("res://Soup-o-Folder/scenes/death_scene.tscn")

func kill_count():
	kills+=1
	$ui/kills_label.text="[shake]"+str(kills)

func take_damage():
	hp-=1
	damage_shake=1.0
	blood_handler()

func reload():
	if reloading or ammo==total_ammo:
		return
	reloading=true
	$Camera3D/items/items_anim.play(str(current_gun)+"_reload")
	await $Camera3D/items/items_anim.animation_finished
	ammo=total_ammo
	update_ammo_label()
	reloading=false

func change_weapon(new_weapon):
	match new_weapon:
		"machinegun":
			$Camera3D/items/machinegun_model.show()
			$Camera3D/items/gun_gun.hide()
			$Camera3D/items/shotgun_model.hide()
			$Camera3D/items/awp_model.hide()
			total_ammo=15
		"gun":
			$Camera3D/items/machinegun_model.hide()
			$Camera3D/items/gun_gun.show()
			$Camera3D/items/shotgun_model.hide()
			$Camera3D/items/awp_model.hide()
			total_ammo=8
		"shotgun":
			$Camera3D/items/machinegun_model.hide()
			$Camera3D/items/gun_gun.hide()
			$Camera3D/items/shotgun_model.show()
			$Camera3D/items/awp_model.hide()
			total_ammo=2
		"awp":
			$Camera3D/items/machinegun_model.hide()
			$Camera3D/items/gun_gun.hide()
			$Camera3D/items/shotgun_model.hide()
			$Camera3D/items/awp_model.show()
			total_ammo=3
	current_gun=str(new_weapon)
	ammo=total_ammo
	reloading=false
	update_ammo_label()
	$Camera3D/items/items_anim.play(str(current_gun)+"_up")

func shoot():
	if ammo<=0 or reloading:
		return
	if $Camera3D/items/items_anim.is_playing():
		return
	$Camera3D/items/items_anim.play(str(current_gun)+"_shoot")
	$shoot_sound.play()
	ammo-=1
	var marker=$Camera3D/Marker3D
	if current_gun=="shotgun":
		for i in range(shotgun_pellets):
			var bullet=bullet_scene.instantiate()
			bullet.global_transform=marker.global_transform
			bullet.rotate_object_local(Vector3.UP,deg_to_rad(randf_range(-shotgun_spread,shotgun_spread)))
			bullet.rotate_object_local(Vector3.RIGHT,deg_to_rad(randf_range(-shotgun_spread,shotgun_spread)))
			get_tree().current_scene.add_child(bullet)
	else:
		var bullet=bullet_scene.instantiate()
		bullet.global_transform=marker.global_transform
		get_tree().current_scene.add_child(bullet)
	update_ammo_label()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode()==Input.MOUSE_MODE_CAPTURED:
		rotation_y-=event.relative.x*mouse_sens
		rotation_x-=event.relative.y*mouse_sens
		rotation_x=clamp(rotation_x,max_look_down,max_look_up)
		mouse_sway.x=clamp(event.relative.x*0.002,-mouse_sway_amount,mouse_sway_amount)
		mouse_sway.y=clamp(event.relative.y*0.002,-mouse_sway_amount,mouse_sway_amount)

func _process(delta: float) -> void:
	if hp <= 0: return
	rotation.y=rotation_y

	var horizontal_velocity=Vector3(velocity.x,0,velocity.z)
	var movement_speed=horizontal_velocity.length()
	var bob_strength=clamp(movement_speed/speed,0.0,1.0) if is_on_floor() else 0.0

	if bob_strength>0.05:
		camera_bob_time+=delta*camera_bob_speed*clamp(movement_speed/speed,0.0,1.5)
		var target_bob=Vector3(
			sin(camera_bob_time)*camera_bob_side_amount,
			-abs(sin(camera_bob_time*2.0))*camera_bob_amount,
			sin(camera_bob_time*2.0)*camera_bob_forward_amount
		)*bob_strength
		var target_rotation=Vector2(
			cos(camera_bob_time*2.0)*camera_bob_pitch,
			sin(camera_bob_time)*camera_bob_roll
		)*bob_strength
		camera_bob=camera_bob.lerp(target_bob,clamp(delta*10.0,0.0,1.0))
		camera_bob_rotation=camera_bob_rotation.lerp(target_rotation,clamp(delta*10.0,0.0,1.0))
	else:
		camera_bob=camera_bob.lerp(Vector3.ZERO,clamp(delta*7.0,0.0,1.0))
		camera_bob_rotation=camera_bob_rotation.lerp(Vector2.ZERO,clamp(delta*7.0,0.0,1.0))

	camera.rotation.x=rotation_x+camera_bob_rotation.x
	camera.rotation.z=camera_bob_rotation.y

	if damage_shake>0.0:
		camera.position=camera_base_position+camera_bob+Vector3(
			randf_range(-damage_shake_amount,damage_shake_amount)*damage_shake,
			randf_range(-damage_shake_amount,damage_shake_amount)*damage_shake,
			0.0
		)
		damage_shake=move_toward(damage_shake,0.0,delta*damage_shake_speed)
	else:
		camera.position=camera.position.lerp(camera_base_position+camera_bob,clamp(delta*damage_shake_speed,0.0,1.0))

	var input_dir:=Input.get_vector("left","right","up","down")
	mouse_sway=mouse_sway.lerp(Vector2.ZERO,clamp(delta*sway_speed,0.0,1.0))
	var target_position=weapon_position
	var target_rotation=weapon_rotation
	if movement_speed>0.1 and is_on_floor():
		bob_time+=delta*bob_speed*(movement_speed/speed)
		var current_step=int(floor(bob_time/PI))
		if current_step!=last_step:
			$step_sound.play()
			last_step=current_step
		target_position.x+=sin(bob_time)*bob_side_amount
		target_position.y-=abs(cos(bob_time))*bob_amount
		target_rotation.z-=input_dir.x*bob_roll_amount
		target_rotation.x-=sin(bob_time*2.0)*0.015
	target_position.x-=mouse_sway.x
	target_position.y+=mouse_sway.y
	target_rotation.y+=mouse_sway.x*mouse_sway_rotation
	target_rotation.x+=mouse_sway.y*mouse_sway_rotation
	target_position.y+=jump_sway*jump_sway_amount
	target_rotation.x-=jump_sway*jump_sway_rotation
	items.position=items.position.lerp(target_position,clamp(delta*12.0,0.0,1.0))
	items.rotation=items.rotation.lerp(target_rotation,clamp(delta*12.0,0.0,1.0))

func _physics_process(delta: float) -> void:
	if hp <= 0: return
	var input_dir:=Vector2.ZERO
	input_dir.x=Input.get_axis("left","right")
	input_dir.y=Input.get_axis("up","down")
	var on_floor=is_on_floor()
	if not on_floor:
		velocity+=get_gravity()*delta
	elif Input.is_action_pressed("space"):
		$step_sound.play()
		air_acceleration*=air_acceleration_factor*input_dir.length()
		velocity.y=get_gravity().y*-jump_velocity
	if was_on_floor and not on_floor:
		jump_sway=1.0
	was_on_floor=on_floor
	jump_sway=move_toward(jump_sway,0.0,delta*sway_speed)
	if Input.is_action_pressed("shoot") and not reloading:
		shoot()
	if Input.is_action_just_pressed("reload") and not reloading:
		reload()
	air_acceleration=maxf(air_acceleration-delta/deceleration,1.0)
	var direction:=(transform.basis*Vector3(input_dir.x,0,input_dir.y))
	if not direction.is_zero_approx():
		var s:=speed*air_acceleration
		velocity.x=lerp(velocity.x,direction.x*s,1.0-exp(-delta*speed*acceleration))
		velocity.z=lerp(velocity.z,direction.z*s,1.0-exp(-delta*speed*acceleration))
	else:
		velocity.x=lerp(velocity.x,0.0,1.0-exp(-delta*speed*deceleration))
		velocity.z=lerp(velocity.z,0.0,1.0-exp(-delta*speed*deceleration))
	move_and_slide()
