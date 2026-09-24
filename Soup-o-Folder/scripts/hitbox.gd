class_name Hitbox extends Area3D


signal damaged(v: int)



func damage(amount: int) -> void:
    damaged.emit(amount)
