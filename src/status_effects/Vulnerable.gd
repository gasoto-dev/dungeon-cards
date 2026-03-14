## Vulnerable — take 50% more damage. Decrements by 1 each turn.
class_name Vulnerable
extends StatusEffect

func _init(p_stacks: int = 1) -> void:
	super._init("Vulnerable", p_stacks)

func modify_incoming_damage(base_damage: int) -> int:
	return int(base_damage * 1.5)

func on_turn_end(_entity: Variant) -> int:
	stacks -= 1
	return 0  # no direct damage

func tick() -> bool:
	return stacks <= 0
