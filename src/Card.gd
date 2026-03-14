class_name Card
extends Resource

enum Type {
	SPELL,       # Attack — deal damage
	RITUAL,      # Skill — utility: draw, buff, debuff
	ENCHANTMENT, # Power — persistent passive for rest of combat
	CANTRIP,     # 0-cost minor effect
}

@export var id: String = ""
@export var card_name: String = ""
@export var type: Type = Type.SPELL
@export var cost: int = 1
@export var effect_data: Dictionary = {}
@export var description: String = ""
@export var exhausts: bool = false  # single-use: removed from deck after play

func _init(p_id: String = "", p_name: String = "", p_type: Type = Type.SPELL,
		p_cost: int = 1, p_effect: Dictionary = {}, p_desc: String = "") -> void:
	id = p_id
	card_name = p_name
	type = p_type
	cost = p_cost
	effect_data = p_effect
	description = p_desc

func is_playable(spell_slots: int) -> bool:
	return spell_slots >= cost

func duplicate_card() -> Card:
	var c := Card.new()
	c.id = id
	c.card_name = card_name
	c.type = type
	c.cost = cost
	c.effect_data = effect_data.duplicate(true)
	c.description = description
	c.exhausts = exhausts
	return c
