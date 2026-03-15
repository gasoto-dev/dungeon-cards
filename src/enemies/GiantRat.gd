## GiantRat — Act 1 enemy. Attacks twice for 5 each hit.
class_name GiantRat
extends Enemy

const HITS: int = 2
const DAMAGE_PER_HIT: int = 5

func _init() -> void:
	super._init("Giant Rat", 30)
	intent = Intent.ATTACK
	intent_value = HITS * DAMAGE_PER_HIT

func decide_intent() -> void:
	intent = Intent.ATTACK
	intent_value = HITS * DAMAGE_PER_HIT  # 2x5 = 10 total

## Bites twice — each hit is a separate damage instance (block applies per hit? No — block
## absorbs across the full turn; we resolve both hits sequentially so block applies first then HP)
func execute_action(player: Player) -> int:
	var total := 0
	for i in HITS:
		var damage := calculate_outgoing_damage(DAMAGE_PER_HIT)
		total += player.take_damage(damage)
	return total
