## SkeletonArcher — Act 1 enemy. Applies Vulnerable to player.
class_name SkeletonArcher
extends Enemy

const BASE_ATTACK: int = 5
const VULNERABLE_STACKS: int = 2

func _init() -> void:
	super._init("Skeleton Archer", 18)
	intent = Intent.DEBUFF
	intent_value = BASE_ATTACK

func decide_intent() -> void:
	intent = Intent.DEBUFF
	intent_value = BASE_ATTACK  # also deals damage after applying Vulnerable

## Shoots an arrow that deals damage and applies Vulnerable
func execute_action(player: Player) -> int:
	player.add_status(Vulnerable.new(VULNERABLE_STACKS))
	var damage := calculate_outgoing_damage(BASE_ATTACK)
	player.take_damage(damage)
	return damage
