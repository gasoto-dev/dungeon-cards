# GUT — Godot Unit Testing

This project uses GUT v9.3.0 for Godot 4.

## Setup

GUT is NOT bundled in this repo (binary/asset). To install:

1. Open the project in Godot 4
2. Go to **AssetLib** (top bar) → search "GUT"
3. Install "Gut - Godot Unit Testing" by Butch Wesley
4. Enable the plugin: **Project → Project Settings → Plugins → Gut → Enable**

Alternatively, download from: https://github.com/bitwes/Gut/releases

## Running Tests

With GUT installed:
- Use the GUT panel in the Godot editor (bottom panel)
- Or run via CLI: `godot --headless -s addons/gut/gut_cmdln.gd`

## Test Location

All test files are in `tests/`. Each file extends `GutTest` and follows `test_*` naming.
