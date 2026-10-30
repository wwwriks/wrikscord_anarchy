extends CharacterBody3D

@export var explosion_area: Area3D
@export var explosion_scene: PackedScene=preload("res://Soup-o-Folder/scenes/explosion.tscn")
@export var weapon_case_scene: PackedScene=preload("res://Soup-o-Folder/scenes/weapon_case.tscn")
@export var hp_scene_case: PackedScene=preload("res://Soup-o-Folder/scenes/hp_case.tscn")

var damage_given=false
var exploded=false

func _spawn_explosion() -> void:
	if exploded:
		return
	exploded=true
	var drop_chance=randi_range(1,5)
	match drop_chance:
		1:
			var weapon_box=weapon_case_scene.instantiate()
			get_parent().add_child(weapon_box)
			weapon_box.global_position=global_position+Vector3(0,0.5,0)
			print("spawn weapon case")
		2:
			var hp_box=hp_scene_case.instantiate()
			get_parent().add_child(hp_box)
			hp_box.global_position=global_position+Vector3(0,0.5,0)
			print("spawn hp case")
	if explosion_scene==null:
		return
	var player=get_tree().get_first_node_in_group("Player")
	if player:
		player.kill_count()
	var expl:=explosion_scene.instantiate() as Node3D
	get_parent().add_child(expl)
	expl.global_position=global_position

func _on_bomb_area_body_entered(b: Node3D) -> void:
	if damage_given:
		return
	if not b.is_in_group("Player"):
		return
	damage_given = true
	$bomb_area.set_deferred("monitoring", false)
	_spawn_explosion()
	if b.has_method("take_damage"):
		b.take_damage()
	queue_free()

func take_damage_enemy():
	print("ай больно в ноге блять")
	_spawn_explosion()
