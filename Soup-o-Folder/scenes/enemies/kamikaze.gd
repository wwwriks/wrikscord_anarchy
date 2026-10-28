extends CharacterBody3D


@export var explosion_area: Area3D
@export var explosion_scene: PackedScene


func _ready() -> void:
    explosion_area.body_entered.connect(func(b: Node3D):
        if b.is_in_group("Player"):
            queue_free()
            if explosion_scene == null: return
            var expl: Node3D = explosion_scene.instantiate()
            add_sibling(expl)
            expl.global_position = global_position
    )
