extends Node3D


@export var start_delay: Timer
@export var max_group_count: int = 3
@export var enemy_group_delay: Timer
@export var music: DynamicMusicPlayer
@export var enemies: Array[PackedScene]


var enemy_count: int = 10
var current_enemy_count: int = 0
var current_wave: int = 0

func _ready() -> void:
    await start_delay.timeout

    _spawn_enemies()



func _spawn_enemies() -> void:
    var spawners := get_tree().get_nodes_in_group("Spawner")

    for i in enemy_count:
        current_enemy_count += 1
        var s := spawners.pick_random() as Node3D
        var enemy_instance := (enemies.pick_random() as PackedScene).instantiate() as Node3D

        enemy_instance.global_position = s.global_position

        enemy_instance.tree_exiting.connect(func():
            current_enemy_count -= 1

            if current_enemy_count == 0:
                music.finished_ambush.emit()
        )

        get_tree().current_scene.add_child(enemy_instance)
    music.started_ambush.emit()
