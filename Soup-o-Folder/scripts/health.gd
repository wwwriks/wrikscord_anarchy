class_name Health extends Node

#
#@export var max_health: int = 10
#
#
#@onready var health := max_health:
	#set(v):
		#if health != v:
			#health_changed.emit()
		#if health <= 0:
			#killed.emit()
		#health = v
#
#
#signal health_changed()
#signal killed()
#
#
#func damage(v: int) -> void:
	#health -= v
