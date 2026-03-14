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

signal state_changed(new_state: State)
signal combat_ended(outcome: Outcome)

func _init(p_player: Player, p_enemy: Enemy) -> void:
	player = p_player
	enemy = p_enemy

## Start combat — begin player's first turn
func start_combat() -> void:
	state = State.PLAYER_TURN
	player.start_turn()
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
		return true
	if not player.is_alive:
		outcome = Outcome.PLAYER_LOSE
		state = State.COMBAT_END
		combat_ended.emit(outcome)
		return true
	return false

func _resolve_enemy_turn() -> void:
	if state == State.COMBAT_END:
		return
	turn_count += 1
	enemy.decide_intent()
	enemy.execute_action(player)
	enemy.end_turn()
	if _check_combat_end():
		return
	_transition_to(State.PLAYER_TURN)
	player.start_turn()

func _transition_to(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)

func _apply_card_effect(card: Card, attacker: Player, target: Enemy) -> void:
	var effect := card.effect_data

	if effect.has("damage"):
		var base := int(effect["damage"])
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
