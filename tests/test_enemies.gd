extends GutTest

## Tests for all Act 1 enemies

# --- GoblinScout ---

func test_goblin_scout_has_correct_stats() -> void:
	var goblin := GoblinScout.new()
	assert_eq(goblin.hp, 20)
	assert_eq(goblin.max_hp, 20)
	assert_eq(goblin.enemy_name, "Goblin Scout")
	assert_true(goblin.is_alive)

func test_goblin_scout_deals_8_damage() -> void:
	var goblin := GoblinScout.new()
	var player := Player.new()
	goblin.execute_action(player)
	assert_eq(player.hp, 52)  # 60 - 8

func test_goblin_scout_damage_reduced_by_block() -> void:
	var goblin := GoblinScout.new()
	var player := Player.new()
	player.gain_block(3)
	goblin.execute_action(player)
	assert_eq(player.hp, 55)  # 60 - (8-3)

func test_goblin_scout_intent_is_attack() -> void:
	var goblin := GoblinScout.new()
	goblin.decide_intent()
	assert_eq(goblin.intent, Enemy.Intent.ATTACK)

# --- SkeletonArcher ---

func test_skeleton_archer_has_correct_stats() -> void:
	var archer := SkeletonArcher.new()
	assert_eq(archer.hp, 18)
	assert_eq(archer.enemy_name, "Skeleton Archer")

func test_skeleton_archer_applies_vulnerable() -> void:
	var archer := SkeletonArcher.new()
	var player := Player.new()
	archer.execute_action(player)
	var vuln := player.get_status("Vulnerable")
	assert_not_null(vuln)
	assert_eq(vuln.stacks, 2)

func test_skeleton_archer_also_deals_damage() -> void:
	var archer := SkeletonArcher.new()
	var player := Player.new()
	archer.execute_action(player)
	assert_lt(player.hp, 60)

func test_skeleton_archer_intent_is_debuff() -> void:
	var archer := SkeletonArcher.new()
	archer.decide_intent()
	assert_eq(archer.intent, Enemy.Intent.DEBUFF)

# --- GiantRat ---

func test_giant_rat_has_correct_stats() -> void:
	var rat := GiantRat.new()
	assert_eq(rat.hp, 30)
	assert_eq(rat.enemy_name, "Giant Rat")

func test_giant_rat_attacks_twice_for_5_each() -> void:
	var rat := GiantRat.new()
	var player := Player.new()
	rat.execute_action(player)
	assert_eq(player.hp, 50)  # 60 - (5 + 5)

func test_giant_rat_each_hit_applies_separately_to_block() -> void:
	# With 6 block: first hit absorbs 5 (1 block remaining), second hit: 1 block + 4 hp damage
	var rat := GiantRat.new()
	var player := Player.new()
	player.gain_block(6)
	rat.execute_action(player)
	assert_eq(player.block, 0)
	assert_eq(player.hp, 56)  # 4 hp damage from second hit

func test_giant_rat_intent_is_attack() -> void:
	var rat := GiantRat.new()
	rat.decide_intent()
	assert_eq(rat.intent, Enemy.Intent.ATTACK)

# --- Enemy take_damage ---

func test_enemy_take_damage_reduces_hp() -> void:
	var goblin := GoblinScout.new()
	goblin.take_damage(10)
	assert_eq(goblin.hp, 10)

func test_enemy_dies_at_zero_hp() -> void:
	var goblin := GoblinScout.new()
	goblin.take_damage(20)
	assert_false(goblin.is_alive)

func test_enemy_hp_cannot_go_below_zero() -> void:
	var goblin := GoblinScout.new()
	goblin.take_damage(999)
	assert_eq(goblin.hp, 0)
