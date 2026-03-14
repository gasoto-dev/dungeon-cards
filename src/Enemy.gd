## Enemy — base class for all enemies
class_name Enemy

enum Intent {
	ATTACK,
	DEFEND,
	DEBUFF,
	BUFF,
	UNKNOWN,
}

var enemy_name: String = "Enemy"
var hp: int = 10
var max_hp: int = 10
var intent: Intent = Intent.ATTACK
var status_effects: Array[StatusEffect] = []
var is_alive: bool:
	get: return hp > 0

func _init(p_name: String, p_hp: int) -> void:
	enemy_name = p_name
	hp = p_hp
	max_hp = p_hp

## Take damage, applying status effect modifiers
func take_damage(amount: int) -> int:
	amount = _apply_incoming_modifiers(amount)
	hp = maxi(0, hp - amount)
	return amount

## Determine and set the next action (override in subclass)
func decide_intent() -> void:
	intent = Intent.ATTACK

## Execute attack against the player. Returns damage dealt.
func execute_action(player: Player) -> int:
	return 0  # override in subclass

## Add a status effect
func add_status(effect: StatusEffect) -> void:
	for existing in status_effects:
		if existing.effect_name == effect.effect_name:
			existing.add_stacks(effect.stacks)
			return
	status_effects.append(effect)

func get_status(effect_name: String) -> StatusEffect:
	for effect in status_effects:
		if effect.effect_name == effect_name:
			return effect
	return null

## Called at end of enemy's turn
func end_turn() -> void:
	_tick_status_effects()

func calculate_outgoing_damage(base_damage: int) -> int:
	var damage := base_damage
	for effect in status_effects:
		damage = effect.modify_outgoing_damage(damage)
	return maxi(0, damage)

func _apply_incoming_modifiers(damage: int) -> int:
	for effect in status_effects:
		damage = effect.modify_incoming_damage(damage)
	return maxi(0, damage)

func _tick_status_effects() -> void:
	for effect in status_effects:
		var dmg := effect.on_turn_end(self)
		if dmg > 0:
			hp = maxi(0, hp - dmg)
	status_effects = status_effects.filter(func(e): return not e.is_expired())
