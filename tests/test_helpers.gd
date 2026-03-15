## test_helpers.gd
## Shared helpers for GUT test files.
## Usage: var h := load("res://tests/test_helpers.gd").new()
##        h.simulate_full_turn(enemy, player)

extends RefCounted

## Simulate a complete turn boundary between two actions.
## Resets block on both sides and decrements/clears status effects.
## Use this between sequential enemy.execute_action() calls in tests
## to prevent status effect bleed from one action carrying into the next.
func simulate_full_turn(enemy: Enemy, player: Player) -> void:
	enemy.end_turn()
	player.end_turn()
