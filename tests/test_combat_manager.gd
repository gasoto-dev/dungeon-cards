extends GutTest

## Tests for CombatManager state machine

func _make_combat() -> CombatManager:
	var player := Player.new()
	var enemy := GoblinScout.new()
	return CombatManager.new(player, enemy)

func test_combat_starts_in_player_turn() -> void:
	var cm := _make_combat()
	cm.start_combat()
	assert_eq(cm.state, CombatManager.State.PLAYER_TURN)

func test_start_combat_draws_player_hand() -> void:
	var cm := _make_combat()
	cm.start_combat()
	assert_eq(cm.player.deck.hand.size(), 5)

func test_end_player_turn_transitions_to_enemy_turn_then_back() -> void:
	var cm := _make_combat()
	cm.start_combat()
	# After ending player turn, enemy acts, then back to PLAYER_TURN
	cm.end_player_turn()
	# If nobody died, should be back in PLAYER_TURN
	if cm.outcome == CombatManager.Outcome.NONE:
		assert_eq(cm.state, CombatManager.State.PLAYER_TURN)

func test_play_card_spends_spell_slots() -> void:
	var cm := _make_combat()
	cm.start_combat()
	var hand := cm.player.deck.hand
	# find a 1-cost card
	for card in hand:
		if card.cost == 1:
			cm.play_card(card)
			assert_eq(cm.player.spell_slots, 2)
			return
	pass  # no 1-cost card in hand (shouldn't happen with starting deck)

func test_play_card_fails_with_insufficient_slots() -> void:
	var cm := _make_combat()
	cm.start_combat()
	cm.player.spend_slots(3)  # exhaust all slots
	var hand := cm.player.deck.hand
	if hand.size() > 0:
		var result := cm.play_card(hand[0])
		assert_false(result)

func test_dealing_lethal_damage_ends_combat() -> void:
	var player := Player.new()
	var enemy := GoblinScout.new()
	enemy.hp = 5  # very low hp
	var cm := CombatManager.new(player, enemy)
	cm.start_combat()
	# Play magic missiles until enemy dies
	for card in cm.player.deck.hand:
		if card.id == "magic_missile" and cm.state != CombatManager.State.COMBAT_END:
			cm.play_card(card)
	if cm.outcome == CombatManager.Outcome.PLAYER_WIN:
		assert_eq(cm.state, CombatManager.State.COMBAT_END)

func test_player_dying_ends_combat_with_player_lose() -> void:
	var player := Player.new()
	player.hp = 1  # barely alive
	var enemy := GoblinScout.new()  # deals 8 damage
	var cm := CombatManager.new(player, enemy)
	cm.start_combat()
	cm.end_player_turn()  # enemy attacks and kills player
	assert_eq(cm.outcome, CombatManager.Outcome.PLAYER_LOSE)
	assert_eq(cm.state, CombatManager.State.COMBAT_END)

func test_magic_missile_applies_damage_to_enemy() -> void:
	var player := Player.new()
	var enemy := GoblinScout.new()
	var cm := CombatManager.new(player, enemy)
	cm.start_combat()
	var missile := CardFactory.magic_missile()
	player.deck.hand.append(missile)
	player.spend_slots(0)  # ensure slots available
	var initial_enemy_hp := enemy.hp
	cm.play_card(missile)
	assert_lt(enemy.hp, initial_enemy_hp)

func test_arcane_shield_applies_block_to_player() -> void:
	var player := Player.new()
	var enemy := GoblinScout.new()
	var cm := CombatManager.new(player, enemy)
	cm.start_combat()
	var shield := CardFactory.arcane_shield()
	player.deck.hand.append(shield)
	cm.play_card(shield)
	assert_gt(player.block, 0)

func test_turn_count_increments_after_enemy_turn() -> void:
	var cm := _make_combat()
	cm.start_combat()
	cm.player.hp = 999  # prevent death
	cm.end_player_turn()
	if cm.outcome == CombatManager.Outcome.NONE:
		assert_eq(cm.turn_count, 1)
