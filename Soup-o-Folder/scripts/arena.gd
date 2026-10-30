extends Node3D

@export var start_delay: Timer
@export var max_group_count: int=3
@export var enemy_group_delay: Timer
@export var music: DynamicMusicPlayer
@export var enemies: Array[PackedScene]

@export_group("Difficulty")
@export var enemy_count: int=5
@export var enemies_per_wave: int=2
@export var max_enemies_per_wave: int=50

@export_group("Wave Timing")
@export var wave_break_delay: float=5.0
@export var spawn_radius: float=1.0

var current_enemy_count: int=0
var current_wave: int=0
var is_spawning: bool=false
var wave_finished_emitted: bool=true

func _ready() -> void:
    if start_delay:
        await start_delay.timeout
    while is_inside_tree():
        await _spawn_enemies()
        if not is_inside_tree():
            return
        await get_tree().create_timer(wave_break_delay).timeout

func _spawn_enemies() -> void:
    var spawners: Array[Node]=get_tree().get_nodes_in_group("Spawner")
    if spawners.is_empty() or enemies.is_empty():
        return
    current_wave+=1
    var total_enemies: int=mini(
        enemy_count+(current_wave-1)*enemies_per_wave,
        max_enemies_per_wave)
    is_spawning=true
    wave_finished_emitted=false
    print("wave numero ", current_wave, ". enemies ", total_enemies)
    var spawned: int=0
    while spawned < total_enemies:
        if not is_inside_tree():
            return
        var group_size: int=mini(max_group_count, total_enemies-spawned)
        for i in range(group_size):
            var s: Node3D=spawners.pick_random() as Node3D
            var scene: PackedScene=enemies.pick_random() as PackedScene
            if not is_instance_valid(s) or scene==null:
                continue
            var enemy_instance: Node3D=scene.instantiate() as Node3D
            if enemy_instance==null:
                continue
            var offset: Vector3 = Vector3(
                randf_range(-spawn_radius, spawn_radius),
                0.0,
                randf_range(-spawn_radius, spawn_radius))
            enemy_instance.global_position = s.global_position + offset
            current_enemy_count+=1
            spawned+=1
            enemy_instance.tree_exiting.connect(
                _on_enemy_exiting,
                CONNECT_ONE_SHOT)
            get_tree().current_scene.add_child(enemy_instance)
        if spawned<total_enemies and enemy_group_delay:
            enemy_group_delay.start()
            await enemy_group_delay.timeout
    is_spawning=false
    if spawned==0:
        _finish_wave()
        return
    if music:
        music.started_ambush.emit()
    while current_enemy_count>0:
        if not is_inside_tree():
            return
        await get_tree().process_frame

func _on_enemy_exiting() -> void:
    current_enemy_count=maxi(0, current_enemy_count-1)
    if current_enemy_count==0 and not is_spawning:
        _finish_wave()

func _finish_wave() -> void:
    if wave_finished_emitted:
        return
    wave_finished_emitted=true
    print("wave ", current_wave, " is finished")
    if music:
        music.finished_ambush.emit()
