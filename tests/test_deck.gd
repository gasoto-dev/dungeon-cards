extends GutTest

## Tests for Deck class

func _make_cards(n: int) -> Array[Card]:
	var cards: Array[Card] = []
	for i in n:
		cards.append(Card.new("card_%d" % i, "Card %d" % i, Card.Type.SPELL, 1, {}))
	return cards

func test_deck_initializes_with_cards() -> void:
	var deck := Deck.new(_make_cards(10))
	assert_eq(deck.total_cards(), 10)

func test_starting_deck_has_10_cards() -> void:
	var deck := Deck.new(CardFactory.starting_deck())
	assert_eq(deck.total_cards(), 10)

func test_draw_moves_cards_to_hand() -> void:
	var deck := Deck.new(_make_cards(10))
	var drawn := deck.draw(5)
	assert_eq(drawn.size(), 5)
	assert_eq(deck.hand.size(), 5)
	assert_eq(deck.draw_pile.size(), 5)

func test_draw_does_not_exceed_hand_size_limit() -> void:
	var deck := Deck.new(_make_cards(15))
	deck.draw(Deck.MAX_HAND_SIZE + 5)
	assert_lte(deck.hand.size(), Deck.MAX_HAND_SIZE)

func test_draw_reshuffles_discard_when_draw_empty() -> void:
	var deck := Deck.new(_make_cards(3))
	deck.draw(3)  # draw all into hand
	deck.discard_hand()  # move to discard
	var drawn := deck.draw(2)  # should reshuffle and draw
	assert_eq(drawn.size(), 2)

func test_discard_card_moves_from_hand_to_discard() -> void:
	var deck := Deck.new(_make_cards(5))
	deck.draw(1)
	var card := deck.hand[0]
	var success := deck.discard_card(card)
	assert_true(success)
	assert_eq(deck.hand.size(), 0)
	assert_eq(deck.discard_pile.size(), 1)

func test_discard_nonexistent_card_returns_false() -> void:
	var deck := Deck.new(_make_cards(5))
	var foreign := Card.new("x", "X", Card.Type.SPELL, 1, {})
	assert_false(deck.discard_card(foreign))

func test_discard_hand_clears_hand() -> void:
	var deck := Deck.new(_make_cards(10))
	deck.draw(5)
	assert_eq(deck.hand.size(), 5)
	deck.discard_hand()
	assert_eq(deck.hand.size(), 0)
	assert_eq(deck.discard_pile.size(), 5)

func test_exhaust_card_removes_from_game() -> void:
	var deck := Deck.new(_make_cards(5))
	deck.draw(1)
	var card := deck.hand[0]
	deck.exhaust_card(card)
	assert_eq(deck.exhaust_pile.size(), 1)
	assert_false(card in deck.hand)

func test_reset_returns_all_cards_to_draw_pile() -> void:
	var deck := Deck.new(_make_cards(10))
	deck.draw(5)
	deck.discard_hand()
	deck.reset()
	assert_eq(deck.draw_pile.size(), 10)
	assert_eq(deck.hand.size(), 0)
	assert_eq(deck.discard_pile.size(), 0)

func test_total_cards_constant_across_operations() -> void:
	var deck := Deck.new(_make_cards(10))
	assert_eq(deck.total_cards(), 10)
	deck.draw(5)
	assert_eq(deck.total_cards(), 10)
	deck.discard_hand()
	assert_eq(deck.total_cards(), 10)
