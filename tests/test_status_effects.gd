extends GutTest

## Tests for Burn, Vulnerable, Weakened status effects

# --- Burn ---

func test_burn_deals_damage_equal_to_stacks() -> void:
	var burn := Burn.new(3)
	assert_eq(burn.on_turn_end(null), 3)

func test_burn_decrements_stacks_after_tick() -> void:
	var burn := Burn.new(3)
	burn.on_turn_end(null)
	assert_eq(burn.stacks, 2)

func test_burn_expires_at_zero_stacks() -> void:
	var burn := Burn.new(1)
	burn.on_turn_end(null)
	assert_true(burn.is_expired())

func test_burn_stacks_add_correctly() -> void:
	var burn := Burn.new(2)
	burn.add_stacks(3)
	assert_eq(burn.stacks, 5)

func test_burn_does_not_modify_outgoing_damage() -> void:
	var burn := Burn.new(3)
	assert_eq(burn.modify_outgoing_damage(10), 10)

func test_burn_does_not_modify_incoming_damage() -> void:
	var burn := Burn.new(3)
	assert_eq(burn.modify_incoming_damage(10), 10)

# --- Vulnerable ---

func test_vulnerable_increases_incoming_damage_by_50_percent() -> void:
	var vuln := Vulnerable.new(2)
	assert_eq(vuln.modify_incoming_damage(10), 15)

func test_vulnerable_damage_calculation_floors() -> void:
	var vuln := Vulnerable.new(1)
	assert_eq(vuln.modify_incoming_damage(7), 10)  # int(7 * 1.5) = 10

func test_vulnerable_decrements_on_turn_end() -> void:
	var vuln := Vulnerable.new(2)
	vuln.on_turn_end(null)
	assert_eq(vuln.stacks, 1)

func test_vulnerable_expires_at_zero() -> void:
	var vuln := Vulnerable.new(1)
	vuln.on_turn_end(null)
	assert_true(vuln.is_expired())

func test_vulnerable_does_not_affect_outgoing_damage() -> void:
	var vuln := Vulnerable.new(2)
	assert_eq(vuln.modify_outgoing_damage(10), 10)

# --- Weakened ---

func test_weakened_reduces_outgoing_damage_by_25_percent() -> void:
	var weak := Weakened.new(1)
	assert_eq(weak.modify_outgoing_damage(8), 6)  # int(8 * 0.75) = 6

func test_weakened_floors_calculation() -> void:
	var weak := Weakened.new(1)
	assert_eq(weak.modify_outgoing_damage(10), 7)  # int(10 * 0.75) = 7

func test_weakened_decrements_on_turn_end() -> void:
	var weak := Weakened.new(2)
	weak.on_turn_end(null)
	assert_eq(weak.stacks, 1)

func test_weakened_expires_at_zero() -> void:
	var weak := Weakened.new(1)
	weak.on_turn_end(null)
	assert_true(weak.is_expired())

func test_weakened_does_not_affect_incoming_damage() -> void:
	var weak := Weakened.new(1)
	assert_eq(weak.modify_incoming_damage(10), 10)

# --- StatusEffect base ---

func test_status_effect_name_set_on_init() -> void:
	var effect := StatusEffect.new("TestEffect", 3)
	assert_eq(effect.effect_name, "TestEffect")
	assert_eq(effect.stacks, 3)

func test_not_expired_with_positive_stacks() -> void:
	var effect := StatusEffect.new("Test", 1)
	assert_false(effect.is_expired())
