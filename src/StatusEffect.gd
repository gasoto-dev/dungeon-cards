## StatusEffect — base class for all status effects
class_name StatusEffect

var effect_name: String = ""
var stacks: int = 0  # intensity/duration

func _init(p_name: String, p_stacks: int = 1) -> void:
	effect_name = p_name
	stacks = p_stacks

## Called at the end of the affected entity's turn.
## Returns damage to apply to the entity (0 if none).
func on_turn_end(entity: Variant) -> int:
	return 0

## Called when calculating outgoing damage from the entity.
## Returns the modified damage value.
func modify_outgoing_damage(base_damage: int) -> int:
	return base_damage

## Called when calculating incoming damage to the entity.
## Returns the modified damage value.
func modify_incoming_damage(base_damage: int) -> int:
	return base_damage

## Decrement stacks (if applicable). Returns true if effect expires.
func tick() -> bool:
	return false

## Add stacks (for stackable effects like Burn)
func add_stacks(amount: int) -> void:
	stacks += amount

func is_expired() -> bool:
	return stacks <= 0
