# Dungeon Cards — Game Design Document

**Genre:** Roguelike deckbuilder  
**Engine:** Godot 4  
**Theme:** Dungeons & Dragons  
**Inspiration:** Slay the Spire  
**Status:** v0.1 — initial design

---

## Overview

Dungeon Cards is a single-player roguelike deckbuilder set in a D&D fantasy world. The player is a Wizard navigating a dungeon floor by floor, fighting monsters with a card deck, collecting new cards as rewards, and ultimately facing an Ancient Dragon as the final boss.

---

## Player Character — Wizard

- **Starting HP:** 60
- **Starting Spell Slots:** 3 (refill to 3 at the start of each turn)
- **Starting Deck:** 10 cards
  - 5x Magic Missile (deal 6 damage, cost 1)
  - 3x Arcane Shield (gain 5 Block, cost 1)
  - 2x Focus (draw 2 cards, cost 1)

### Subclass Advancement
Unlocks after defeating the Act 1 boss. Player chooses one school:

| School | Playstyle |
|--------|-----------|
| Evocation | Pure damage — maximize spell power |
| Abjuration | Defense — high block, counter-attacks |
| Necromancy | Drain/undead — life steal, cursed cards, skeleton summons |
| Conjuration | Summons — creatures fight alongside you each turn |
| Illusion | Debuffs — weaken, confuse, exhaust enemy cards |

Each subclass unlocks a unique card pool and a passive ability.

---

## Core Mechanics

### Spell Slots (Resource)
- 3 Spell Slots per turn (equivalent to Slay the Spire energy)
- Each card costs 1–3 slots
- Unused slots do not carry over
- Relics/cards can temporarily increase max slots

### Turn Structure
1. Draw 5 cards
2. Play cards (spend Spell Slots)
3. End turn → enemy attacks → discard hand
4. Repeat until combat ends

### Card Types
- **Spell (Attack):** Deal damage
- **Ritual (Skill):** Utility — draw, buff, debuff
- **Enchantment (Power):** Persistent passive for rest of combat
- **Cantrip:** 0-cost minor effect

### Status Effects
- **Burn:** Take X damage at end of turn
- **Weakened:** Deal 25% less damage
- **Vulnerable:** Take 50% more damage
- **Silenced:** Cannot play Enchantments this turn
- **Cursed:** One card in hand becomes unplayable

---

## Run Structure

### Act 1 — The Dungeon (10 floors)
- Normal encounters, elites, shops, rest sites, events
- Boss: **Undead Knight** (armored skeleton paladin)
- Reward: Subclass choice

### Act 2 — The Catacombs (12 floors)
- Harder enemies, more elites
- Optional **Side Quest** branch (player chooses to take it):
  - 3 bonus floors with unique encounters + better rewards
  - Loops back into Act 2 then proceeds to Act 3
- Boss: **Beholder** (3 eye rays per turn)

### Act 3 — The Dragon's Lair (8 floors)
- Elite-heavy, punishing
- Final Boss: **Ancient Dragon** (3 phases)
  - Phase 1: Claw attacks + Fire Breath (Burn stacks)
  - Phase 2: Flies, gains Armor, AOE damage
  - Phase 3: Enrage below 30% HP — double attacks

---

## Map
Node-based (Slay the Spire style). Types: Combat, Elite, Rest Site, Shop, Event, Boss.

---

## Enemy List (v0.1)

| Enemy | HP | Act | Notes |
|-------|----|----|-------|
| Goblin Scout | 20 | 1 | Deals 8, sometimes debuffs |
| Skeleton Archer | 18 | 1 | Applies Vulnerable |
| Giant Rat | 30 | 1 | Attacks twice for 5 |
| Cursed Tome (Elite) | 45 | 1 | Silences, spawns spell copies |
| Stone Golem (Elite) | 60 | 1 | Gains Armor each turn |
| Shadow Stalker | 35 | 2 | Applies Weakened |
| Zombie Mage | 40 | 2 | Steals top card from deck |
| Gargoyle | 50 | 2 | Immune to Block every other turn |
| Undead Knight (Boss) | 140 | 1 | Reanimates once at 30 HP |
| Beholder (Boss) | 180 | 2 | 3 different Eye Rays per turn |
| Ancient Dragon (Boss) | 350 | 3 | 3-phase fight |

---

## Technical Notes
- Game logic in `src/` as pure GDScript classes — fully testable
- GUT test framework configured in initial project
- All logic classes have tests in `tests/`
- Scenes in `scenes/` are visual layer only
- Placeholder art in `assets/placeholder/` (colored rectangles)

---

## Open Questions
- [ ] How many relics can player hold per run?
- [ ] Side quest — always available in Act 2, or conditional unlock?
- [ ] Card upgrade system at rest sites?

---

## Coding Conventions

### Status effect ordering (critical)
When an action both applies a status AND deals damage, **damage fires before the status is applied** (Slay the Spire behavior). The debuff affects the *next* hit, not the one that applies it.

Example: Shield Bash → deal 10 damage first, then apply Vulnerable to player.

**Pattern to watch:** Any time `take_damage()` and `apply_status()` appear in the same action, verify order is damage → status.

### Test isolation for sequential actions
When testing multiple enemy actions in sequence, always call `end_turn()` between them to reset per-turn state (block, status counters). Without this, status effects bleed between action tests.

Preferred pattern:
```gdscript
func test_two_actions():
    boss.action_one(player)
    boss.end_turn()
    player.end_turn()
    boss.action_two(player)
```

Or set `boss._attack_turn` directly to isolate a specific action without executing prior ones.
