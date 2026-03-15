# Dungeon Cards

[![CI](https://github.com/gasoto-dev/dungeon-cards/actions/workflows/ci.yml/badge.svg)](https://github.com/gasoto-dev/dungeon-cards/actions/workflows/ci.yml)

A D&D-themed roguelike deckbuilder built in Godot 4. Play as a Wizard navigating a dungeon, fighting monsters with spells, advancing your subclass, and taking on the Ancient Dragon.

Inspired by Slay the Spire.

## Design
See [docs/GDD.md](docs/GDD.md) for the full Game Design Document.

## Structure
- `docs/` — Game Design Document and design notes
- `src/` — GDScript game logic (deck, combat, state machine)
- `tests/` — GUT unit tests
- `scenes/` — Godot scene files
- `assets/placeholder/` — Placeholder art (colored rectangles)

## Testing
Tests use [GUT (Godot Unit Testing)](https://github.com/bitwes/Gut). Run from Godot editor or CLI.
