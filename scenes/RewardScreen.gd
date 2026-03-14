## RewardScreen — displays 3 card reward options post-combat
## Excluded from GUT test requirements; tested manually by playing the game.
extends Control

signal card_selected(card: Card)
signal reward_skipped

# Type badge colors (placeholder rectangles)
const TYPE_COLORS: Dictionary = {
	Card.Type.SPELL:       Color(0.8, 0.2, 0.2),   # red
	Card.Type.RITUAL:      Color(0.2, 0.4, 0.9),   # blue
	Card.Type.ENCHANTMENT: Color(0.6, 0.2, 0.9),   # purple
	Card.Type.CANTRIP:     Color(0.5, 0.5, 0.5),   # grey
}

const TYPE_NAMES: Dictionary = {
	Card.Type.SPELL:       "Spell",
	Card.Type.RITUAL:      "Ritual",
	Card.Type.ENCHANTMENT: "Enchantment",
	Card.Type.CANTRIP:     "Cantrip",
}

@onready var card_container: HBoxContainer = $VBox/CardContainer
@onready var skip_button: Button = $VBox/SkipButton

var _reward_cards: Array[Card] = []

func show_rewards(cards: Array[Card]) -> void:
	_reward_cards = cards
	_build_card_panels()

func _build_card_panels() -> void:
	for child in card_container.get_children():
		child.queue_free()
	for card in _reward_cards:
		var panel := _make_card_panel(card)
		card_container.add_child(panel)

func _make_card_panel(card: Card) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(200, 280)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Type badge (colored rectangle)
	var badge_color := TYPE_COLORS.get(card.type, Color.WHITE)
	var badge := ColorRect.new()
	badge.color = badge_color
	badge.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(badge)

	var type_label := Label.new()
	type_label.text = TYPE_NAMES.get(card.type, "Unknown")
	type_label.add_theme_color_override("font_color", badge_color)
	vbox.add_child(type_label)

	# Card name
	var name_label := Label.new()
	name_label.text = card.card_name
	name_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(name_label)

	# Cost
	var cost_label := Label.new()
	cost_label.text = "Cost: %d" % card.cost
	vbox.add_child(cost_label)

	# Effect description
	var desc_label := Label.new()
	desc_label.text = card.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	# Select button
	var select_btn := Button.new()
	select_btn.text = "Choose"
	select_btn.pressed.connect(func(): _on_card_selected(card))
	vbox.add_child(select_btn)

	return panel

func _on_card_selected(card: Card) -> void:
	card_selected.emit(card)

func _on_skip_pressed() -> void:
	reward_skipped.emit()

func _ready() -> void:
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)
