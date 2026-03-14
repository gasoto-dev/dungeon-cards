extends GutTest

## Tests for DraftCardPool, CardRewardManager, and CombatManager reward signals

# ── DraftCardPool ─────────────────────────────────────────────────────────────

func test_draft_pool_has_at_least_15_cards() -> void:
	var pool := DraftCardPool.all_cards()
	assert_gte(pool.size(), 15)

func test_draft_pool_contains_no_starter_cards() -> void:
	var pool := DraftCardPool.all_cards()
	for card in pool:
		assert_false(card.id in DraftCardPool.STARTER_IDS,
			"Starter card '%s' should not be in draft pool" % card.id)

func test_draft_pool_cost_distribution() -> void:
	var pool := DraftCardPool.all_cards()
	var cost_counts := {0: 0, 1: 0, 2: 0, 3: 0}
	for card in pool:
		if card.cost <= 3:
			cost_counts[card.cost] += 1
	assert_gte(cost_counts[0], 2, "Need at least 2 cost-0 cards")
	assert_gte(cost_counts[1], 3, "Need at least 3 cost-1 cards")
	assert_gte(cost_counts[2], 3, "Need at least 3 cost-2 cards")
	assert_gte(cost_counts[3], 3, "Need at least 3 cost-3 cards")

func test_draft_pool_type_distribution() -> void:
	var pool := DraftCardPool.all_cards()
	var spell_count := pool.filter(func(c): return c.type == Card.Type.SPELL).size()
	var ritual_count := pool.filter(func(c): return c.type == Card.Type.RITUAL).size()
	var enchant_count := pool.filter(func(c): return c.type == Card.Type.ENCHANTMENT).size()
	var cantrip_count := pool.filter(func(c): return c.type == Card.Type.CANTRIP).size()
	assert_gte(spell_count, 3, "Need ≥3 Spells")
	assert_gte(ritual_count, 3, "Need ≥3 Rituals")
	assert_gte(enchant_count, 2, "Need ≥2 Enchantments")
	assert_gte(cantrip_count, 2, "Need ≥2 Cantrips")

func test_draft_pool_has_status_effect_enchantment() -> void:
	var pool := DraftCardPool.all_cards()
	var enchants := pool.filter(func(c): return c.type == Card.Type.ENCHANTMENT)
	var status_enchant := enchants.filter(func(c):
		return c.effect_data.has("enchant_type") and \
			(c.effect_data["enchant_type"].contains("burn") or \
			 c.effect_data["enchant_type"].contains("vulnerable") or \
			 c.effect_data["enchant_type"].contains("weaken"))
	)
	assert_gt(status_enchant.size(), 0, "At least one Enchantment must interact with a status effect")

func test_burning_aura_has_burn_interaction() -> void:
	var pool := DraftCardPool.all_cards()
	var aura := pool.filter(func(c): return c.id == "burning_aura")
	assert_eq(aura.size(), 1)
	assert_eq(aura[0].effect_data["enchant_type"], "burn_per_turn")

func test_draft_card_damage_curve_cost_1() -> void:
	var pool := DraftCardPool.all_cards()
	var cost1_spells := pool.filter(func(c): return c.type == Card.Type.SPELL and c.cost == 1)
	for card in cost1_spells:
		if card.effect_data.has("damage"):
			assert_gte(card.effect_data["damage"], 6, "%s damage should be ≥6" % card.card_name)
			assert_lte(card.effect_data["damage"], 8, "%s damage should be ≤8" % card.card_name)

func test_draft_card_damage_curve_cost_2() -> void:
	var pool := DraftCardPool.all_cards()
	var cost2_spells := pool.filter(func(c): return c.type == Card.Type.SPELL and c.cost == 2)
	for card in cost2_spells:
		if card.effect_data.has("damage"):
			assert_gte(card.effect_data["damage"], 12)
			assert_lte(card.effect_data["damage"], 15)

func test_draft_card_damage_curve_cost_3() -> void:
	var pool := DraftCardPool.all_cards()
	var cost3_spells := pool.filter(func(c): return c.type == Card.Type.SPELL and c.cost == 3)
	for card in cost3_spells:
		if card.effect_data.has("damage") and not card.effect_data.has("hits"):
			# Single-target: damage in 18-22 range
			assert_gte(card.effect_data["damage"], 18,
				"%s single damage should be ≥18" % card.card_name)
			assert_lte(card.effect_data["damage"], 22,
				"%s single damage should be ≤22" % card.card_name)
		elif card.effect_data.has("hits") and card.effect_data.has("damage"):
			# Multi-hit: total damage (hits * damage) must be in 18-22 range
			var total := int(card.effect_data["hits"]) * int(card.effect_data["damage"])
			assert_gte(total, 18,
				"%s total damage (%d) should be ≥18" % [card.card_name, total])
			assert_lte(total, 22,
				"%s total damage (%d) should be ≤22" % [card.card_name, total])

func test_all_cards_have_ids() -> void:
	var pool := DraftCardPool.all_cards()
	for card in pool:
		assert_ne(card.id, "", "Card should have a non-empty id")

func test_school_affinity_field_exists_on_cards() -> void:
	var pool := DraftCardPool.all_cards()
	# Just verify school field is accessible (may be empty string)
	for card in pool:
		assert_true(card.school != null)

# ── CardRewardManager ─────────────────────────────────────────────────────────

func test_generate_reward_returns_3_cards() -> void:
	var mgr := CardRewardManager.new()
	var reward := mgr.generate_reward(3)
	assert_eq(reward.size(), 3)

func test_generate_reward_returns_unique_cards() -> void:
	var mgr := CardRewardManager.new()
	var reward := mgr.generate_reward(3)
	var ids := reward.map(func(c): return c.id)
	# No duplicate ids
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			assert_ne(ids[i], ids[j], "Reward should not contain duplicate cards")

func test_generate_reward_no_starter_cards() -> void:
	var mgr := CardRewardManager.new()
	# Run many times to reduce false-pass probability
	for _i in 20:
		var reward := mgr.generate_reward(3)
		for card in reward:
			assert_false(card.id in DraftCardPool.STARTER_IDS,
				"Starter card '%s' should never appear in reward" % card.id)

func test_select_card_adds_to_deck() -> void:
	var mgr := CardRewardManager.new()
	var deck := Deck.new(CardFactory.starting_deck())
	var initial_total := deck.total_cards()
	var reward := mgr.generate_reward(1)
	mgr.select_card(reward[0], deck)
	assert_eq(deck.total_cards(), initial_total + 1)

func test_skip_reward_leaves_deck_unchanged() -> void:
	var mgr := CardRewardManager.new()
	var deck := Deck.new(CardFactory.starting_deck())
	var initial_total := deck.total_cards()
	mgr.skip_reward()
	assert_eq(deck.total_cards(), initial_total)

func test_generate_reward_with_count_1_returns_1() -> void:
	var mgr := CardRewardManager.new()
	var reward := mgr.generate_reward(1)
	assert_eq(reward.size(), 1)

# ── CombatManager signals ─────────────────────────────────────────────────────

func test_reward_ready_signal_emitted_on_player_win() -> void:
	var player := Player.new()
	var enemy := GoblinScout.new()
	enemy.hp = 1  # one hit kill
	var cm := CombatManager.new(player, enemy)
	cm.start_combat()

	var signal_received := false
	var received_cards: Array = []
	cm.reward_ready.connect(func(cards): signal_received = true; received_cards = cards)

	# Play magic missile to kill enemy
	for card in cm.player.deck.hand:
		if card.id == "magic_missile" and cm.state != CombatManager.State.COMBAT_END:
			cm.play_card(card)
			break

	assert_true(signal_received, "reward_ready should fire on player win")
	assert_eq(received_cards.size(), 3, "reward_ready should emit 3 cards")

func test_reward_ready_not_emitted_on_player_lose() -> void:
	var player := Player.new()
	player.hp = 1  # player dies to goblin
	var enemy := GoblinScout.new()
	var cm := CombatManager.new(player, enemy)
	cm.start_combat()

	var signal_received := false
	cm.reward_ready.connect(func(_cards): signal_received = true)
	cm.end_player_turn()  # goblin kills player

	assert_false(signal_received, "reward_ready should NOT fire on player lose")

func test_combat_resolved_signal_stub_exists() -> void:
	var player := Player.new()
	var enemy := GoblinScout.new()
	var cm := CombatManager.new(player, enemy)
	var signal_received := false
	cm.combat_resolved.connect(func(): signal_received = true)
	cm.resolve_reward()
	assert_true(signal_received, "combat_resolved should emit when resolve_reward is called")
