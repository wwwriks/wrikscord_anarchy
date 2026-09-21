extends RumbleAbility

@export var fx : Sprite3D
@export var fxTimer : Timer

func _enter_tree() -> void:
	fx.visible = false

func abilityEffect():
	if user==null: return false
	user.velocity *= 3
	user.velocity.y *= .5
	
	fx.visible = true
	fxTimer.start(1)
