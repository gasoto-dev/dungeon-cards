## Weakened — deal 25% less damage. Decrements by 1 each turn.
class_name Weakened
extends StatusEffect

func _init(p_stacks: int = 1) -> void:
	super._init("Weakened", p_stacks)

func modify_outgoing_damage(base_damage: int) -> int:
	return int(base_damage * 0.75)

func on_turn_end(_entity: Variant) -> int:
	stacks -= 1
	return 0

func tick() -> bool:
	return stacks <= 0
