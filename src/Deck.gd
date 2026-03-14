## Deck — manages draw pile, discard pile, exhaust pile, and hand
class_name Deck

var draw_pile: Array[Card] = []
var discard_pile: Array[Card] = []
var exhaust_pile: Array[Card] = []
var hand: Array[Card] = []

const MAX_HAND_SIZE: int = 10

func _init(cards: Array[Card] = []) -> void:
	for card in cards:
		draw_pile.append(card)
	shuffle()

## Shuffle the draw pile in place
func shuffle() -> void:
	draw_pile.shuffle()

## Draw n cards into hand; reshuffles discard if draw pile runs out
func draw(n: int) -> Array[Card]:
	var drawn: Array[Card] = []
	for i in n:
		if hand.size() >= MAX_HAND_SIZE:
			break
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			_reshuffle_discard()
		if not draw_pile.is_empty():
			var card := draw_pile.pop_back()
			hand.append(card)
			drawn.append(card)
	return drawn

## Discard a specific card from hand
func discard_card(card: Card) -> bool:
	var idx := hand.find(card)
	if idx == -1:
		return false
	hand.remove_at(idx)
	discard_pile.append(card)
	return true

## Discard entire hand (end of turn)
func discard_hand() -> void:
	for card in hand:
		discard_pile.append(card)
	hand.clear()

## Exhaust a card (remove from game for this combat)
func exhaust_card(card: Card) -> bool:
	var idx := hand.find(card)
	if idx == -1:
		return false
	hand.remove_at(idx)
	exhaust_pile.append(card)
	return true

## Add a card directly to discard pile (e.g., reward cards)
func add_to_discard(card: Card) -> void:
	discard_pile.append(card)

## Total cards across all piles (including hand)
func total_cards() -> int:
	return draw_pile.size() + discard_pile.size() + exhaust_pile.size() + hand.size()

## Reset: move all non-exhausted cards back to draw pile and shuffle
func reset() -> void:
	for card in hand:
		draw_pile.append(card)
	hand.clear()
	for card in discard_pile:
		draw_pile.append(card)
	discard_pile.clear()
	shuffle()

func _reshuffle_discard() -> void:
	for card in discard_pile:
		draw_pile.append(card)
	discard_pile.clear()
	shuffle()
