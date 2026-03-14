extends GutTest

## Tests for Card resource

func test_card_init_sets_fields() -> void:
	var card := Card.new("mm", "Magic Missile", Card.Type.SPELL, 1, {"damage": 6}, "Deal 6 damage.")
	assert_eq(card.id, "mm")
	assert_eq(card.card_name, "Magic Missile")
	assert_eq(card.type, Card.Type.SPELL)
	assert_eq(card.cost, 1)
	assert_eq(card.effect_data["damage"], 6)
	assert_eq(card.description, "Deal 6 damage.")

func test_card_default_not_exhaustible() -> void:
	var card := Card.new("mm", "Magic Missile", Card.Type.SPELL, 1, {})
	assert_false(card.exhausts)

func test_is_playable_with_enough_slots() -> void:
	var card := Card.new("c", "Card", Card.Type.SPELL, 2, {})
	assert_true(card.is_playable(2))
	assert_true(card.is_playable(3))

func test_is_playable_with_insufficient_slots() -> void:
	var card := Card.new("c", "Card", Card.Type.SPELL, 2, {})
	assert_false(card.is_playable(1))
	assert_false(card.is_playable(0))

func test_cantrip_always_playable() -> void:
	var card := Card.new("c", "Cantrip", Card.Type.CANTRIP, 0, {})
	assert_true(card.is_playable(0))

func test_duplicate_card_is_independent_copy() -> void:
	var original := Card.new("mm", "Magic Missile", Card.Type.SPELL, 1, {"damage": 6})
	var copy := original.duplicate_card()
	copy.effect_data["damage"] = 99
	assert_eq(original.effect_data["damage"], 6)  # original unchanged

func test_card_types_defined() -> void:
	assert_eq(Card.Type.SPELL, 0)
	assert_eq(Card.Type.RITUAL, 1)
	assert_eq(Card.Type.ENCHANTMENT, 2)
	assert_eq(Card.Type.CANTRIP, 3)
