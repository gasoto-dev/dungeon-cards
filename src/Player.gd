## Player — Wizard character state
class_name Player

const MAX_SPELL_SLOTS: int = 3
const STARTING_HP: int = 60
const STARTING_HAND_SIZE: int = 5

var max_hp: int = STARTING_HP
var hp: int = STARTING_HP
var spell_slots: int = MAX_SPELL_SLOTS
var max_spell_slots: int = MAX_SPELL_SLOTS
var block: int = 0
var status_effects: Array[StatusEffect] = []
var deck: Deck
var is_alive: bool:
	get: return hp > 0

func _init() -> void:
	deck = Deck.new(CardFactory.starting_deck())

## Apply incoming damage, reduced by block first
func take_damage(amount: int) -> int:
	amount = _apply_incoming_status_modifiers(amount)
	var absorbed := mini(block, amount)
	block -= absorbed
	var remaining := amount - absorbed
	hp = maxi(0, hp - remaining)
	return remaining  # actual HP damage taken

## Gain block (shields)
func gain_block(amount: int) -> void:
	block += amount

## Called at start of player's turn
func start_turn() -> void:
	spell_slots = max_spell_slots
	deck.draw(STARTING_HAND_SIZE)

## Called at end of player's turn — ticks status effects, discards hand
func end_turn() -> void:
	block = 0  # block does not persist between turns
	_tick_status_effects()
	deck.discard_hand()

## Take damage that bypasses Block entirely (armor-piercing)
func take_unblockable_damage(amount: int) -> int:
	amount = _apply_incoming_status_modifiers(amount)
	hp = maxi(0, hp - amount)
	return amount

## Spend spell slots to play a card
func spend_slots(amount: int) -> bool:
	if spell_slots < amount:
		return false
	spell_slots -= amount
	return true

## Add a status effect (stacks if same type already present)
func add_status(effect: StatusEffect) -> void:
	for existing in status_effects:
		if existing.effect_name == effect.effect_name:
			existing.add_stacks(effect.stacks)
			return
	status_effects.append(effect)

## Get a status effect by name, or null
func get_status(effect_name: String) -> StatusEffect:
	for effect in status_effects:
		if effect.effect_name == effect_name:
			return effect
	return null

## Modify outgoing damage through all active status effects
func calculate_outgoing_damage(base_damage: int) -> int:
	var damage := base_damage
	for effect in status_effects:
		damage = effect.modify_outgoing_damage(damage)
	return maxi(0, damage)

func _apply_incoming_status_modifiers(damage: int) -> int:
	for effect in status_effects:
		damage = effect.modify_incoming_damage(damage)
	return maxi(0, damage)

func _tick_status_effects() -> void:
	for effect in status_effects:
		var dmg := effect.on_turn_end(self)
		if dmg > 0:
			hp = maxi(0, hp - dmg)
	status_effects = status_effects.filter(func(e): return not e.is_expired())
