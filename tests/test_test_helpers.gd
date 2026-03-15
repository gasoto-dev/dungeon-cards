extends GutTest

## Tests for the shared test helper utilities.

func test_simulate_full_turn_resets_player_block() -> void:
	var h := load("res://tests/test_helpers.gd").new()
	var enemy := Enemy.new()
	enemy.enemy_name = "Dummy"
	enemy.hp = 10
	var player := Player.new()
	player.gain_block(5)
	assert_eq(player.block, 5)
	h.simulate_full_turn(enemy, player)
	assert_eq(player.block, 0)

func test_simulate_full_turn_resets_enemy_block() -> void:
	var h := load("res://tests/test_helpers.gd").new()
	var enemy := Enemy.new()
	enemy.enemy_name = "Dummy"
	enemy.hp = 10
	enemy.gain_block(8)
	var player := Player.new()
	assert_eq(enemy.block, 8)
	h.simulate_full_turn(enemy, player)
	assert_eq(enemy.block, 0)

func test_simulate_full_turn_decrements_player_status() -> void:
	var h := load("res://tests/test_helpers.gd").new()
	var enemy := Enemy.new()
	enemy.enemy_name = "Dummy"
	enemy.hp = 10
	var player := Player.new()
	# Add Vulnerable (2 stacks) manually
	var vuln := StatusEffect.new("Vulnerable", 2)
	player.status_effects.append(vuln)
	assert_eq(player.get_status("Vulnerable").stacks, 2)
	h.simulate_full_turn(enemy, player)
	# end_turn decrements — either reduced or removed
	var after := player.get_status("Vulnerable")
	assert_true(after == null or after.stacks < 2)
