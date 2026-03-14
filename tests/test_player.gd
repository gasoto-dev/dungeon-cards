extends GutTest

## Tests for Player class

func test_player_starts_at_60_hp() -> void:
	var player := Player.new()
	assert_eq(player.hp, 60)
	assert_eq(player.max_hp, 60)

func test_player_starts_with_3_spell_slots() -> void:
	var player := Player.new()
	assert_eq(player.spell_slots, 3)
	assert_eq(player.max_spell_slots, 3)

func test_player_is_alive_at_start() -> void:
	var player := Player.new()
	assert_true(player.is_alive)

func test_take_damage_reduces_hp() -> void:
	var player := Player.new()
	player.take_damage(10)
	assert_eq(player.hp, 50)

func test_block_absorbs_damage() -> void:
	var player := Player.new()
	player.gain_block(5)
	player.take_damage(8)
	assert_eq(player.block, 0)
	assert_eq(player.hp, 57)  # 8 - 5 = 3 damage

func test_block_fully_absorbs_when_damage_less_than_block() -> void:
	var player := Player.new()
	player.gain_block(10)
	player.take_damage(6)
	assert_eq(player.block, 4)
	assert_eq(player.hp, 60)

func test_damage_cannot_reduce_hp_below_zero() -> void:
	var player := Player.new()
	player.take_damage(999)
	assert_eq(player.hp, 0)

func test_player_dies_at_zero_hp() -> void:
	var player := Player.new()
	player.take_damage(60)
	assert_false(player.is_alive)

func test_end_turn_resets_block() -> void:
	var player := Player.new()
	player.gain_block(5)
	player.end_turn()
	assert_eq(player.block, 0)

func test_start_turn_refills_spell_slots() -> void:
	var player := Player.new()
	player.spend_slots(3)
	assert_eq(player.spell_slots, 0)
	player.start_turn()
	assert_eq(player.spell_slots, 3)

func test_start_turn_draws_5_cards() -> void:
	var player := Player.new()
	player.start_turn()
	assert_eq(player.deck.hand.size(), 5)

func test_spend_slots_deducts_correctly() -> void:
	var player := Player.new()
	var success := player.spend_slots(2)
	assert_true(success)
	assert_eq(player.spell_slots, 1)

func test_spend_slots_fails_when_insufficient() -> void:
	var player := Player.new()
	var success := player.spend_slots(5)
	assert_false(success)
	assert_eq(player.spell_slots, 3)  # unchanged

func test_status_effects_stack() -> void:
	var player := Player.new()
	player.add_status(Burn.new(2))
	player.add_status(Burn.new(3))
	var burn := player.get_status("Burn")
	assert_not_null(burn)
	assert_eq(burn.stacks, 5)

func test_burn_damages_at_end_of_turn() -> void:
	var player := Player.new()
	player.add_status(Burn.new(3))
	player.end_turn()
	assert_eq(player.hp, 57)  # 60 - 3 burn damage
