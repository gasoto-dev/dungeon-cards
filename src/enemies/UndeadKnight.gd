## UndeadKnight — Act 1 Boss. Heavy armor, Reanimate once at 30 HP.
class_name UndeadKnight
extends Enemy

const BASE_HP: int = 140
const REANIMATE_HP: int = 30
const SHIELD_BASH_DAMAGE: int = 10
const BONE_SHATTER_DAMAGE: int = 14

var has_reanimated: bool = false
var _attack_turn: int = 0  # 0 = Shield Bash, 1 = Bone Shatter, cycles

func _init() -> void:
	super._init("Undead Knight", BASE_HP)
	intent = Intent.ATTACK

## Override take_damage to intercept first death and Reanimate
func take_damage(amount: int) -> int:
	var actual := super.take_damage(amount)
	if hp <= 0 and not has_reanimated:
		_reanimate()
	return actual

## Reanimate: reset to 30 HP, clear all status effects, set flag
func _reanimate() -> void:
	hp = REANIMATE_HP
	has_reanimated = true
	status_effects.clear()

## Decide next intent (cycles Shield Bash → Bone Shatter → Shield Bash …)
func decide_intent() -> void:
	if _attack_turn % 2 == 0:
		intent = Intent.ATTACK    # Shield Bash
	else:
		intent = Intent.ATTACK    # Bone Shatter (also an attack, different method)

## Execute the turn action. Returns total HP damage dealt to player.
func execute_action(player: Player) -> int:
	var damage: int
	if _attack_turn % 2 == 0:
		damage = _shield_bash(player)
	else:
		damage = _bone_shatter(player)
	_attack_turn += 1
	return damage

## Shield Bash: 10 damage, then apply Vulnerable(1) to player
## Vulnerable takes effect on the NEXT hit — does not amplify its own application
func _shield_bash(player: Player) -> int:
	var dmg := calculate_outgoing_damage(SHIELD_BASH_DAMAGE)
	var dealt := player.take_damage(dmg)
	player.add_status(Vulnerable.new(1))
	return dealt

## Bone Shatter: 14 armor-piercing damage (bypasses player Block)
func _bone_shatter(player: Player) -> int:
	var dmg := calculate_outgoing_damage(BONE_SHATTER_DAMAGE)
	return player.take_unblockable_damage(dmg)
