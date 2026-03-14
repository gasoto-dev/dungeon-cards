## SubclassData — defines a Wizard school and its passive ability
class_name SubclassData
extends Resource

enum PassiveType {
	EVOCATION_SPELL_DAMAGE,   # Spell cards deal +N damage
	ABJURATION_TURN_BLOCK,    # Gain +N Block at start of each player turn
	NECROMANCY_BURN_LIFESTEAL, # Heal N HP when enemy takes Burn damage
	CONJURATION_SKELETON,      # Inject a 0-cost Summon Skeleton into hand at combat start
	ILLUSION_WEAKEN_ENEMY,    # Enemy starts combat with N stack(s) of Weakened
}

var id: String = ""
var school_name: String = ""
var description: String = ""
var passive_type: PassiveType = PassiveType.EVOCATION_SPELL_DAMAGE
var passive_value: int = 0

func _init(p_id: String, p_name: String, p_desc: String,
		p_type: PassiveType, p_value: int) -> void:
	id = p_id
	school_name = p_name
	description = p_desc
	passive_type = p_type
	passive_value = p_value
