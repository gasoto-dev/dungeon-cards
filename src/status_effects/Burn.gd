## Burn — deal stacks damage at end of turn, then reduce stacks by 1
class_name Burn
extends StatusEffect

func _init(p_stacks: int = 1) -> void:
	super._init("Burn", p_stacks)

## Deals stacks damage and ticks down by 1
func on_turn_end(_entity: Variant) -> int:
	var damage := stacks
	stacks -= 1
	return damage

func tick() -> bool:
	return stacks <= 0
