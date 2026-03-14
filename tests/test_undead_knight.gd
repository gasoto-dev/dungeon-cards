extends GutTest

## Tests for UndeadKnight boss, SubclassChoiceManager, and CombatManager integration

# ── UndeadKnight stats ────────────────────────────────────────────────────────

func test_undead_knight_has_140_hp() -> void:
	var boss := UndeadKnight.new()
	assert_eq(boss.hp, 140)
	assert_eq(boss.max_hp, 140)

func test_undead_knight_correct_name() -> void:
	var boss := UndeadKnight.new()
	assert_eq(boss.enemy_name, "Undead Knight")

func test_undead_knight_not_reanimated_initially() -> void:
	var boss := UndeadKnight.new()
	assert_false(boss.has_reanimated)

# ── Shield Bash ───────────────────────────────────────────────────────────────

func test_shield_bash_deals_10_damage() -> void:
	var boss := UndeadKnight.new()
	var player := Player.new()
	boss.execute_action(player)  # turn 0 = Shield Bash
	assert_eq(player.hp, 50)  # 60 - 10

func test_shield_bash_applies_vulnerable_1() -> void:
	var boss := UndeadKnight.new()
	var player := Player.new()
	boss.execute_action(player)
	var vuln := player.get_status("Vulnerable")
	assert_not_null(vuln)
	assert_eq(vuln.stacks, 1)

# ── Bone Shatter ──────────────────────────────────────────────────────────────

func test_bone_shatter_deals_14_damage() -> void:
	var boss := UndeadKnight.new()
	var player := Player.new()
	boss._attack_turn = 1  # go directly to Bone Shatter — no Vulnerable bleeding in
	boss.execute_action(player)
	assert_eq(player.hp, 46)  # 60 - 14

func test_bone_shatter_bypasses_block() -> void:
	var boss := UndeadKnight.new()
	var player := Player.new()
	player.gain_block(20)
	boss._attack_turn = 1  # Bone Shatter directly
	var hp_before := player.hp
	boss.execute_action(player)
	assert_eq(player.block, 20)        # block untouched
	assert_eq(player.hp, hp_before - 14)  # HP reduced directly

# ── Intent cycling ────────────────────────────────────────────────────────────

func test_intent_pattern_cycles_correctly() -> void:
	var boss := UndeadKnight.new()
	var player := Player.new()
	player.hp = 999  # prevent death
	player.max_hp = 999
	# Turn 1: Shield Bash → Vulnerable applied
	boss.execute_action(player)
	assert_not_null(player.get_status("Vulnerable"))
	var hp_after_bash := player.hp
	# Turn 2: Bone Shatter → unblockable, no new Vulnerable
	player.gain_block(50)  # lots of block to prove it's bypassed
	boss.execute_action(player)
	assert_eq(player.block, 50)  # block untouched by Bone Shatter
	# Turn 3: back to Shield Bash
	player.status_effects.clear()
	player.block = 0
	boss.execute_action(player)
	assert_not_null(player.get_status("Vulnerable"))

# ── Reanimate ─────────────────────────────────────────────────────────────────

func test_first_death_triggers_reanimate() -> void:
	var boss := UndeadKnight.new()
	boss.take_damage(140)  # kill
	assert_true(boss.is_alive)
	assert_eq(boss.hp, 30)
	assert_true(boss.has_reanimated)

func test_reanimate_clears_status_effects() -> void:
	var boss := UndeadKnight.new()
	boss.add_status(Burn.new(5))
	boss.add_status(Weakened.new(2))
	boss.take_damage(140)  # trigger reanimate
	assert_eq(boss.status_effects.size(), 0)

func test_second_death_does_not_reanimate() -> void:
	var boss := UndeadKnight.new()
	boss.take_damage(140)  # first death → reanimate to 30 HP
	assert_true(boss.is_alive)
	boss.take_damage(30)   # second death → stays dead
	assert_false(boss.is_alive)
	assert_eq(boss.hp, 0)

func test_reanimate_only_fires_once() -> void:
	var boss := UndeadKnight.new()
	boss.take_damage(999)  # overkill first pass
	assert_eq(boss.hp, 30)
	boss.take_damage(999)  # second overkill → dead for good
	assert_eq(boss.hp, 0)
	assert_false(boss.is_alive)

func test_partial_damage_does_not_trigger_reanimate() -> void:
	var boss := UndeadKnight.new()
	boss.take_damage(50)
	assert_false(boss.has_reanimated)
	assert_eq(boss.hp, 90)

# ── SubclassChoiceManager ─────────────────────────────────────────────────────

func test_present_choice_returns_5_subclasses() -> void:
	var mgr := SubclassChoiceManager.new()
	assert_eq(mgr.present_choice().size(), 5)

func test_confirm_choice_sets_active_subclass() -> void:
	var mgr := SubclassChoiceManager.new()
	mgr.confirm_choice("necromancy")
	assert_not_null(mgr.active_subclass())
	assert_eq(mgr.active_subclass().id, "necromancy")

func test_active_subclass_null_before_choice() -> void:
	var mgr := SubclassChoiceManager.new()
	assert_null(mgr.active_subclass())

# ── CombatManager signals ─────────────────────────────────────────────────────

func _kill_boss(cm: CombatManager) -> void:
	# Deal enough damage to kill boss twice (through Reanimate)
	cm.enemy.take_damage(140)  # first death → reanimate
	cm.enemy.take_damage(30)   # second death
	# Manually trigger the end check (normally happens in play_card / end_player_turn)
	# We need to exercise _check_combat_end through normal flow
	# Instead: force hp to 0 through the boss object after calling start_combat

func test_subclass_choice_ready_fires_on_undead_knight_defeat() -> void:
	var player := Player.new()
	var boss := UndeadKnight.new()
	boss.hp = 1
	boss.has_reanimated = true  # skip reanimate so one hit kills
	var cm := CombatManager.new(player, boss)
	cm.start_combat()

	var signal_fired := false
	cm.subclass_choice_ready.connect(func(): signal_fired = true)

	# Play magic missile to finish boss
	for card in cm.player.deck.hand:
		if card.id == "magic_missile" and cm.state != CombatManager.State.COMBAT_END:
			cm.play_card(card)
			break

	assert_true(signal_fired, "subclass_choice_ready should fire when UndeadKnight is defeated")

func test_subclass_choice_ready_does_not_fire_for_normal_enemy() -> void:
	var player := Player.new()
	var goblin := GoblinScout.new()
	goblin.hp = 1
	var cm := CombatManager.new(player, goblin)
	cm.start_combat()

	var signal_fired := false
	cm.subclass_choice_ready.connect(func(): signal_fired = true)

	for card in cm.player.deck.hand:
		if card.id == "magic_missile" and cm.state != CombatManager.State.COMBAT_END:
			cm.play_card(card)
			break

	assert_false(signal_fired, "subclass_choice_ready should NOT fire for normal enemies")

func test_reward_ready_also_fires_on_undead_knight_defeat() -> void:
	var player := Player.new()
	var boss := UndeadKnight.new()
	boss.hp = 1
	boss.has_reanimated = true
	var cm := CombatManager.new(player, boss)
	cm.start_combat()

	var reward_fired := false
	cm.reward_ready.connect(func(_cards): reward_fired = true)

	for card in cm.player.deck.hand:
		if card.id == "magic_missile" and cm.state != CombatManager.State.COMBAT_END:
			cm.play_card(card)
			break

	assert_true(reward_fired, "reward_ready should still fire on boss defeat")

# ── take_unblockable_damage on Player ────────────────────────────────────────

func test_unblockable_damage_ignores_block() -> void:
	var player := Player.new()
	player.gain_block(10)
	player.take_unblockable_damage(15)
	assert_eq(player.block, 10)  # block untouched
	assert_eq(player.hp, 45)     # 60 - 15
