## SubclassManager — holds the 5 school definitions and tracks the active selection
class_name SubclassManager

var _schools: Array[SubclassData] = []
var _active: SubclassData = null

func _init() -> void:
	_schools = [
		SubclassData.new(
			"evocation",
			"Evocation",
			"Spell cards deal +2 damage.",
			SubclassData.PassiveType.EVOCATION_SPELL_DAMAGE,
			2
		),
		SubclassData.new(
			"abjuration",
			"Abjuration",
			"Gain +3 Block at the start of each turn.",
			SubclassData.PassiveType.ABJURATION_TURN_BLOCK,
			3
		),
		SubclassData.new(
			"necromancy",
			"Necromancy",
			"Heal 2 HP whenever an enemy takes Burn damage.",
			SubclassData.PassiveType.NECROMANCY_BURN_LIFESTEAL,
			2
		),
		SubclassData.new(
			"conjuration",
			"Conjuration",
			"Start each combat with a 0-cost Summon Skeleton card in hand.",
			SubclassData.PassiveType.CONJURATION_SKELETON,
			1
		),
		SubclassData.new(
			"illusion",
			"Illusion",
			"Enemies enter combat with 1 stack of Weakened.",
			SubclassData.PassiveType.ILLUSION_WEAKEN_ENEMY,
			1
		),
	]

## Returns all 5 available schools
func available_schools() -> Array[SubclassData]:
	return _schools.duplicate()

## Set the active school by id. Does nothing if id not found.
func select_school(school_id: String) -> void:
	for school in _schools:
		if school.id == school_id:
			_active = school
			return

## Returns the active subclass, or null if not yet selected
func active_subclass() -> SubclassData:
	return _active

## Apply combat-start passives (Abjuration block, Conjuration skeleton, Illusion weakened)
## Call this at the start of each combat after set_subclass is applied.
func apply_combat_start(player: Player, enemy: Enemy) -> void:
	if _active == null:
		return
	match _active.passive_type:
		SubclassData.PassiveType.ABJURATION_TURN_BLOCK:
			player.gain_block(_active.passive_value)
		SubclassData.PassiveType.CONJURATION_SKELETON:
			var skeleton := CardFactory.summon_skeleton()
			player.deck.hand.append(skeleton)
		SubclassData.PassiveType.ILLUSION_WEAKEN_ENEMY:
			enemy.add_status(Weakened.new(_active.passive_value))
