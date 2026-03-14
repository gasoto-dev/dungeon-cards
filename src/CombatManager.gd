## CombatManager — drives the combat state machine
class_name CombatManager

enum State {
	PLAYER_TURN,
	ENEMY_TURN,
	COMBAT_END,
}

enum Outcome {
	NONE,
	PLAYER_WIN,
	PLAYER_LOSE,
}

var state: State = State.PLAYER_TURN
var outcome: Outcome = Outcome.NONE
var player: Player
var enemy: Enemy
var turn_count: int = 0  # total turns elapsed (player + enemy)

# Subclass integration
var _subclass: SubclassData = null

signal state_changed(new_state: State)
signal combat_ended(outcome: Outcome)
signal reward_ready(cards: Array)       # emitted on PLAYER_WIN with 3 reward cards
signal combat_resolved                  # stub seam for MapManager — emitted after reward resolved
signal subclass_choice_ready            # emitted on PLAYER_WIN vs UndeadKnight (boss kill)

func _init(p_player: Player, p_enemy: Enemy) -> void:
	player = p_player
	enemy = p_enemy

## Set the active subclass before calling start_combat()
func set_subclass(subclass: SubclassData) -> void:
	_subclass = subclass

## Start combat — applies combat-start passives, then begins player's first turn
func start_combat() -> void:
	state = State.PLAYER_TURN
	_apply_combat_start_passives()
	player.start_turn()
	_apply_turn_start_passives()
	state_changed.emit(state)

## Player ends their turn — transition to enemy turn
func end_player_turn() -> void:
	if state != State.PLAYER_TURN:
		return
	player.end_turn()
	_transition_to(State.ENEMY_TURN)
	_resolve_enemy_turn()

## Play a card from player's hand (returns false if can't play)
func play_card(card: Card) -> bool:
	if state != State.PLAYER_TURN:
		return false
	if not card.is_playable(player.spell_slots):
		return false
	if not player.spend_slots(card.cost):
		return false

	_apply_card_effect(card, player, enemy)

	if card.exhausts:
		player.deck.exhaust_card(card)
	else:
		player.deck.discard_card(card)

	if _check_combat_end():
		return true

	return true

## Check if combat is over — returns true if ended
func _check_combat_end() -> bool:
	if not enemy.is_alive:
		outcome = Outcome.PLAYER_WIN
		state = State.COMBAT_END
		combat_ended.emit(outcome)
		_emit_rewards()
		return true
	if not player.is_alive:
		outcome = Outcome.PLAYER_LOSE
		state = State.COMBAT_END
		combat_ended.emit(outcome)
		return true
	return false

## Emit reward_ready with 3 draft cards when player wins.
## Also emits subclass_choice_ready if the defeated enemy is the UndeadKnight boss.
func _emit_rewards() -> void:
	var reward_mgr := CardRewardManager.new()
	var cards := reward_mgr.generate_reward(3)
	reward_ready.emit(cards)
	if enemy is UndeadKnight:
		subclass_choice_ready.emit()

## Called by UI/MapManager after player selects or skips reward
## Emits combat_resolved so map can advance to next node (stub seam)
func resolve_reward() -> void:
	combat_resolved.emit()

func _resolve_enemy_turn() -> void:
	if state == State.COMBAT_END:
		return
	turn_count += 1
	enemy.decide_intent()
	enemy.execute_action(player)

	# Necromancy: heal player when enemy takes Burn damage this turn
	_apply_necromancy_burn_heal()

	enemy.end_turn()
	if _check_combat_end():
		return
	_transition_to(State.PLAYER_TURN)
	player.start_turn()
	_apply_turn_start_passives()

func _transition_to(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)

## Apply passives that fire once at the very start of combat (before first turn)
func _apply_combat_start_passives() -> void:
	if _subclass == null:
		return
	match _subclass.passive_type:
		SubclassData.PassiveType.CONJURATION_SKELETON:
			player.deck.hand.append(CardFactory.summon_skeleton())
		SubclassData.PassiveType.ILLUSION_WEAKEN_ENEMY:
			enemy.add_status(Weakened.new(_subclass.passive_value))
		# Abjuration block is applied via _apply_turn_start_passives on first turn too

## Apply passives that fire at the start of each player turn
func _apply_turn_start_passives() -> void:
	if _subclass == null:
		return
	if _subclass.passive_type == SubclassData.PassiveType.ABJURATION_TURN_BLOCK:
		player.gain_block(_subclass.passive_value)

## Necromancy: check if enemy has Burn about to tick, and heal player
## Called before enemy.end_turn() so we can read stacks before they decrement
func _apply_necromancy_burn_heal() -> void:
	if _subclass == null:
		return
	if _subclass.passive_type != SubclassData.PassiveType.NECROMANCY_BURN_LIFESTEAL:
		return
	var burn := enemy.get_status("Burn")
	if burn != null and burn.stacks > 0:
		# Burn will tick this turn — heal player
		player.hp = mini(player.max_hp, player.hp + _subclass.passive_value)

func _apply_card_effect(card: Card, attacker: Player, target: Enemy) -> void:
	var effect := card.effect_data
	var is_spell := card.type == Card.Type.SPELL

	if effect.has("damage"):
		var base := int(effect["damage"])
		# Evocation: +passive_value to Spell card damage
		if is_spell and _subclass != null and \
				_subclass.passive_type == SubclassData.PassiveType.EVOCATION_SPELL_DAMAGE:
			base += _subclass.passive_value
		var final_dmg := attacker.calculate_outgoing_damage(base)
		target.take_damage(final_dmg)

	if effect.has("block"):
		attacker.gain_block(int(effect["block"]))

	if effect.has("draw"):
		attacker.deck.draw(int(effect["draw"]))

	if effect.has("burn"):
		target.add_status(Burn.new(int(effect["burn"])))

	if effect.has("vulnerable"):
		target.add_status(Vulnerable.new(int(effect["vulnerable"])))

	if effect.has("weaken"):
		target.add_status(Weakened.new(int(effect["weaken"])))
