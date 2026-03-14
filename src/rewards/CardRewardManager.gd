## CardRewardManager — generates and resolves post-combat card rewards
class_name CardRewardManager

var _pool: Array[Card] = []

signal reward_selected(card: Card)
signal reward_skipped

func _init() -> void:
	_pool = DraftCardPool.all_cards()

## Pick `count` unique random cards from the draft pool
func generate_reward(count: int = 3) -> Array[Card]:
	if _pool.is_empty():
		return []
	var available := _pool.duplicate()
	available.shuffle()
	var result: Array[Card] = []
	for i in mini(count, available.size()):
		result.append(available[i])
	return result

## Add the chosen card to the player's deck and emit reward_selected
func select_card(card: Card, deck: Deck) -> void:
	deck.add_to_discard(card.duplicate_card())
	reward_selected.emit(card)

## Decline the reward — no change to deck
func skip_reward() -> void:
	reward_skipped.emit()
