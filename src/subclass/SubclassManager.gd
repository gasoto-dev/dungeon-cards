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

## Note: combat-start and turn-start passives are applied by CombatManager internally
## after set_subclass() is called. SubclassManager is responsible only for school
## definitions and selection state.
