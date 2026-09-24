class_name Health extends Node


@export var max_health: int = 100


@onready var health := max_health:
    set(v):
        if health != v:
            health_changed.emit()
        health = v


signal health_changed()


func damage(v: int) -> void:
    health -= v
