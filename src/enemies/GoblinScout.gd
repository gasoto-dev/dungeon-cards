## GoblinScout — Act 1 basic enemy. Deals 8 damage.
class_name GoblinScout
extends Enemy

const BASE_ATTACK: int = 8

func _init() -> void:
	super._init("Goblin Scout", 20)
	intent = Intent.ATTACK

func decide_intent() -> void:
	intent = Intent.ATTACK

func execute_action(player: Player) -> int:
	var damage := calculate_outgoing_damage(BASE_ATTACK)
	player.take_damage(damage)
	return damage
