## CardFactory — creates the standard starting deck cards
class_name CardFactory

static func magic_missile() -> Card:
	return Card.new("magic_missile", "Magic Missile", Card.Type.SPELL, 1,
		{"damage": 6}, "Deal 6 damage.")

static func arcane_shield() -> Card:
	return Card.new("arcane_shield", "Arcane Shield", Card.Type.RITUAL, 1,
		{"block": 5}, "Gain 5 Block.")

static func focus() -> Card:
	return Card.new("focus", "Focus", Card.Type.RITUAL, 1,
		{"draw": 2}, "Draw 2 cards.")

## Conjuration subclass — injected into hand at combat start
static func summon_skeleton() -> Card:
	var card := Card.new("summon_skeleton", "Summon Skeleton", Card.Type.RITUAL, 0,
		{"damage": 5}, "Summon a skeleton that deals 5 damage.")
	card.exhausts = true  # disposable: removed from game after use
	return card

static func starting_deck() -> Array[Card]:
	var deck: Array[Card] = []
	for i in 5:
		deck.append(magic_missile())
	for i in 3:
		deck.append(arcane_shield())
	for i in 2:
		deck.append(focus())
	return deck
