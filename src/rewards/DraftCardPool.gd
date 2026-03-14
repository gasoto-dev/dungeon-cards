## DraftCardPool — all cards available as combat rewards (never contains starter cards)
class_name DraftCardPool

## The set of starter card ids — never included in draft
const STARTER_IDS: Array[String] = ["magic_missile", "arcane_shield", "focus"]

static func all_cards() -> Array[Card]:
	return [
		# ── Cantrips (cost 0, utility only) ──────────────────────────────────
		_make("quick_study",    "Quick Study",    Card.Type.CANTRIP,     0,
			{"draw": 1},            "Draw 1 card.",                          ""),
		_make("minor_ward",     "Minor Ward",     Card.Type.CANTRIP,     0,
			{"block": 2},           "Gain 2 Block.",                         "abjuration"),
		_make("hex",            "Hex",            Card.Type.CANTRIP,     0,
			{"weaken": 1},          "Apply 1 Weakened.",                     "illusion"),

		# ── Cost 1 Spells (6–8 damage) ────────────────────────────────────────
		_make("firebolt",       "Firebolt",       Card.Type.SPELL,       1,
			{"damage": 7},          "Deal 7 damage.",                        "evocation"),
		_make("ice_lance",      "Ice Lance",      Card.Type.SPELL,       1,
			{"damage": 6, "vulnerable": 1}, "Deal 6 damage. Apply 1 Vulnerable.", ""),
		_make("shadow_bolt",    "Shadow Bolt",    Card.Type.SPELL,       1,
			{"damage": 6, "burn": 1},       "Deal 6 damage. Apply 1 Burn.",       "necromancy"),

		# ── Cost 1 Ritual / Enchantment ───────────────────────────────────────
		_make("second_wind",    "Second Wind",    Card.Type.RITUAL,      1,
			{"block": 8},           "Gain 8 Block.",                         "abjuration"),
		_make("frost_ward",     "Frost Ward",     Card.Type.ENCHANTMENT, 1,
			{"enchant_type": "block_per_turn", "value": 4},
			"Each turn, gain 4 Block.",                                       "abjuration"),

		# ── Cost 2 Spells (12–15 damage) ─────────────────────────────────────
		_make("fireball",       "Fireball",       Card.Type.SPELL,       2,
			{"damage": 14},         "Deal 14 damage.",                       "evocation"),
		_make("necrotic_wave",  "Necrotic Wave",  Card.Type.SPELL,       2,
			{"damage": 12, "burn": 3}, "Deal 12 damage. Apply 3 Burn.",      "necromancy"),
		_make("ice_storm",      "Ice Storm",      Card.Type.SPELL,       2,
			{"damage": 13, "vulnerable": 2}, "Deal 13 damage. Apply 2 Vulnerable.", ""),

		# ── Cost 2 Ritual / Enchantment ───────────────────────────────────────
		_make("conjure_familiar","Conjure Familiar", Card.Type.RITUAL,   2,
			{"draw": 3},            "Draw 3 cards.",                         "conjuration"),
		_make("bone_wall",      "Bone Wall",      Card.Type.RITUAL,      2,
			{"block": 15},          "Gain 15 Block.",                        "necromancy"),
		# STATUS EFFECT ENCHANTMENT: interacts with Burn ──────────────────────
		_make("burning_aura",   "Burning Aura",   Card.Type.ENCHANTMENT, 2,
			{"enchant_type": "burn_per_turn", "value": 2},
			"At the start of each turn, apply 2 Burn to the enemy.",         "necromancy"),

		# ── Cost 3 Spells (18–22 damage / multi-hit) ─────────────────────────
		_make("meteor",         "Meteor",         Card.Type.SPELL,       3,
			{"damage": 20},         "Deal 20 damage.",                       "evocation"),
		_make("bone_spear",     "Bone Spear",     Card.Type.SPELL,       3,
			{"hits": 2, "damage": 10}, "Strike twice for 10 damage each.",   "necromancy"),
		_make("blizzard",       "Blizzard",       Card.Type.SPELL,       3,
			{"damage": 18, "vulnerable": 3}, "Deal 18 damage. Apply 3 Vulnerable.", ""),
	]

static func _make(id: String, name: String, type: Card.Type, cost: int,
		effect: Dictionary, desc: String, school: String) -> Card:
	var c := Card.new(id, name, type, cost, effect, desc)
	c.school = school
	return c
