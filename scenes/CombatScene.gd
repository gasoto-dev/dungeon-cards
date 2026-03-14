## CombatScene — first playable UI for Dungeon Cards
## Wires CombatManager to Godot nodes. Placeholder art (colored rectangles).
## Excluded from GUT test requirements per project convention.
extends Control

# ── Type display ─────────────────────────────────────────────────────────────

const TYPE_COLORS: Dictionary = {
	Card.Type.SPELL:       Color(0.8, 0.2, 0.2),
	Card.Type.RITUAL:      Color(0.2, 0.4, 0.9),
	Card.Type.ENCHANTMENT: Color(0.6, 0.2, 0.9),
	Card.Type.CANTRIP:     Color(0.5, 0.5, 0.5),
}

const TYPE_NAMES: Dictionary = {
	Card.Type.SPELL:       "Spell",
	Card.Type.RITUAL:      "Ritual",
	Card.Type.ENCHANTMENT: "Enchantment",
	Card.Type.CANTRIP:     "Cantrip",
}

# ── Game objects ──────────────────────────────────────────────────────────────

var combat_manager: CombatManager
var player: Player
var enemy: Enemy

# ── UI references ─────────────────────────────────────────────────────────────

@onready var enemy_name_label: Label         = $Layout/BattleArea/EnemyPanel/VBox/EnemyName
@onready var enemy_hp_bar: ProgressBar       = $Layout/BattleArea/EnemyPanel/VBox/EnemyHPBar
@onready var enemy_hp_label: Label           = $Layout/BattleArea/EnemyPanel/VBox/EnemyHPLabel
@onready var enemy_block_label: Label        = $Layout/BattleArea/EnemyPanel/VBox/EnemyBlockLabel
@onready var enemy_intent_label: Label       = $Layout/BattleArea/EnemyPanel/VBox/EnemyIntentLabel
@onready var enemy_defeated_overlay: Label   = $Layout/BattleArea/EnemyPanel/EnemyDefeated

@onready var player_hp_bar: ProgressBar      = $Layout/BattleArea/PlayerPanel/VBox/PlayerHPBar
@onready var player_hp_label: Label          = $Layout/BattleArea/PlayerPanel/VBox/PlayerHPLabel
@onready var player_block_label: Label       = $Layout/BattleArea/PlayerPanel/VBox/PlayerBlockLabel
@onready var spell_slot_container: HBoxContainer = $Layout/BattleArea/PlayerPanel/VBox/SpellSlots
@onready var status_effects_label: Label     = $Layout/BattleArea/PlayerPanel/VBox/StatusEffects

@onready var card_container: HBoxContainer   = $Layout/HandArea/CardContainer
@onready var end_turn_button: Button         = $Layout/HandArea/EndTurnButton

@onready var victory_overlay: Panel          = $VictoryOverlay
@onready var defeat_overlay: Panel           = $DefeatOverlay
@onready var subclass_hint_label: Label      = $SubclassHint
@onready var reward_screen: Control          = $RewardOverlay/RewardScreen

# ── Ready ─────────────────────────────────────────────────────────────────────

func _ready() -> void:
	player = Player.new()
	enemy = GoblinScout.new()
	combat_manager = CombatManager.new(player, enemy)
	add_child(combat_manager)

	# Wire signals
	combat_manager.state_changed.connect(_on_state_changed)
	combat_manager.combat_ended.connect(_on_combat_ended)
	combat_manager.reward_ready.connect(_on_reward_ready)
	combat_manager.subclass_choice_ready.connect(_on_subclass_choice_ready)

	if reward_screen.has_signal("card_selected"):
		reward_screen.card_selected.connect(_on_reward_card_selected)
	if reward_screen.has_signal("reward_skipped"):
		reward_screen.reward_skipped.connect(_on_reward_skipped)

	end_turn_button.pressed.connect(_on_end_turn_pressed)

	# Hide overlays
	victory_overlay.visible = false
	defeat_overlay.visible = false
	subclass_hint_label.visible = false
	_set_reward_visible(false)

	# Start
	combat_manager.start_combat()
	_refresh_ui()

# ── Signal handlers ───────────────────────────────────────────────────────────

func _on_state_changed(_new_state: CombatManager.State) -> void:
	_refresh_ui()

func _on_combat_ended(result: CombatManager.Outcome) -> void:
	match result:
		CombatManager.Outcome.PLAYER_WIN:
			enemy_defeated_overlay.visible = true
			victory_overlay.visible = true
			end_turn_button.disabled = true
		CombatManager.Outcome.PLAYER_LOSE:
			defeat_overlay.visible = true
			end_turn_button.disabled = true
	_refresh_ui()

func _on_reward_ready(cards: Array) -> void:
	_set_reward_visible(true)
	if reward_screen.has_method("show_rewards"):
		reward_screen.show_rewards(cards)

func _on_reward_card_selected(_card: Card) -> void:
	_set_reward_visible(false)
	combat_manager.resolve_reward()

func _on_reward_skipped() -> void:
	_set_reward_visible(false)
	combat_manager.resolve_reward()

func _on_subclass_choice_ready() -> void:
	subclass_hint_label.visible = true
	subclass_hint_label.text = "Subclass choice coming soon"

func _on_end_turn_pressed() -> void:
	if combat_manager.state == CombatManager.State.PLAYER_TURN:
		combat_manager.end_player_turn()

# ── Card play ──────────────────────────────────────────────────────────────────

func _on_card_pressed(card: Card) -> void:
	if combat_manager.state != CombatManager.State.PLAYER_TURN:
		return
	combat_manager.play_card(card)
	_refresh_hand()
	_refresh_player_display()
	_refresh_enemy_display()

# ── UI refresh ────────────────────────────────────────────────────────────────

func _refresh_ui() -> void:
	_refresh_enemy_display()
	_refresh_player_display()
	_refresh_hand()

func _refresh_enemy_display() -> void:
	enemy_name_label.text = enemy.enemy_name
	enemy_hp_bar.max_value = enemy.max_hp
	enemy_hp_bar.value = enemy.hp
	enemy_hp_label.text = "%d / %d" % [enemy.hp, enemy.max_hp]
	enemy_block_label.text = "Block: %d" % enemy.block
	enemy_intent_label.text = "Intent: %s" % _intent_label(enemy.intent)
	enemy_defeated_overlay.visible = not enemy.is_alive

func _refresh_player_display() -> void:
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.hp
	player_hp_label.text = "%d / %d" % [player.hp, player.max_hp]
	player_block_label.text = "Block: %d" % player.block

	# Spell slot pips
	for child in spell_slot_container.get_children():
		child.queue_free()
	for i in range(player.max_spell_slots):
		var pip := Label.new()
		pip.text = "●" if i < player.spell_slots else "○"
		pip.add_theme_font_size_override("font_size", 20)
		spell_slot_container.add_child(pip)

	# Status effects
	if player.status_effects.is_empty():
		status_effects_label.text = "No status effects"
	else:
		var parts: Array[String] = []
		for effect in player.status_effects:
			parts.append("%s(%d)" % [effect.effect_name, effect.stacks])
		status_effects_label.text = " | ".join(PackedStringArray(parts))

func _refresh_hand() -> void:
	for child in card_container.get_children():
		child.queue_free()
	for card in player.deck.hand:
		var panel := _make_card_panel(card)
		card_container.add_child(panel)

func _make_card_panel(card: Card) -> PanelContainer:
	var can_play := card.is_playable(player.spell_slots) and \
		combat_manager.state == CombatManager.State.PLAYER_TURN

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(150, 220)

	# Gray out unaffordable cards
	if not can_play:
		panel.modulate = Color(0.5, 0.5, 0.5, 0.7)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Type badge
	var badge := ColorRect.new()
	badge.color = TYPE_COLORS.get(card.type, Color.WHITE)
	badge.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(badge)

	var type_lbl := Label.new()
	type_lbl.text = TYPE_NAMES.get(card.type, "Unknown")
	type_lbl.add_theme_font_size_override("font_size", 11)
	type_lbl.add_theme_color_override("font_color", TYPE_COLORS.get(card.type, Color.WHITE))
	vbox.add_child(type_lbl)

	# Name
	var name_lbl := Label.new()
	name_lbl.text = card.card_name
	name_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_lbl)

	# Cost
	var cost_lbl := Label.new()
	cost_lbl.text = "Cost: %d" % card.cost
	vbox.add_child(cost_lbl)

	# Description
	var desc_lbl := Label.new()
	desc_lbl.text = card.description
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(desc_lbl)

	# Play button
	var btn := Button.new()
	btn.text = "Play"
	btn.disabled = not can_play
	btn.pressed.connect(func(): _on_card_pressed(card))
	vbox.add_child(btn)

	return panel

func _intent_label(intent: Enemy.Intent) -> String:
	match intent:
		Enemy.Intent.ATTACK: return "Attack"
		Enemy.Intent.DEFEND: return "Defend"
		Enemy.Intent.BUFF:   return "Buff"
		_: return "Unknown"

func _set_reward_visible(visible_flag: bool) -> void:
	if reward_screen and reward_screen.get_parent():
		reward_screen.get_parent().visible = visible_flag
