extends Node
class_name RumbleAbility

@export var user : CharacterBody3D
@export var cooldownTimer : Timer
@export var abilityCooldown : float = 8
@export var chargable : bool = false
@export var canHold : bool = true
@export var chargeTimeNecessary : float = 1.5

var canUseAbility = true
var cooldownOff = true

var chargeTimer : float = 0

func _ready() -> void:
	cooldownTimer = Timer.new()
	cooldownTimer.one_shot = true
	call_deferred("add_child", cooldownTimer)
	cooldownTimer.timeout.connect(_time_out)
	
	if chargable:
		var chargeTimer : float = 0

func _time_out() -> void:
	cooldownOff = true

func _process(delta) -> void:
	var abilityInput = Input.is_action_pressed("m1")
	#var abilityRelease = Input.is_action_("m1")
	if cooldownOff:
		if abilityInput and chargable and chargeTimer<chargeTimeNecessary:
			chargeTimer+=delta
			print("CHARGING "+str(chargeTimer/chargeTimeNecessary)+"%")
		if (!chargable) or (!abilityInput and chargeTimer >= chargeTimeNecessary):
			abilityEffect()
			chargeTimer = 0
			cooldownOff = false
			cooldownTimer.start(abilityCooldown)
			print("ON COOLDOWN FOR "+str(abilityCooldown)+" SECONDS")
		if !abilityInput:
			chargeTimer = 0

func abilityEffect():
	print("ABILITY ACTIVATED")
	if user==null: return false
	user.velocity
