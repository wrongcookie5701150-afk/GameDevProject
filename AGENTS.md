# Agent Instructions & Project Guidelines (CyberSecurityGame)

This repository contains an educational 2D top-down story-driven cybersecurity game developed in **Godot 4.x** with a Python backend/telemetry testing suite.

All AI coding agents (and human contributors) working on this repository must strictly adhere to the following rules and project constraints.

---

## 1. Strict Project Guardrails (CRITICAL)

1. **LOCKED FILES**:
   - `game_client/ui/os_simulation/notebook_screen.tscn` is **STRICTLY LOCKED**. Do NOT modify this file under any circumstances.
2. **NO DESTRUCTIVE UI OVERHAULS**:
   - Avoid massive `.tscn` rewrites or layout restructurings that can corrupt scene hierarchies or discard existing node signals.
   - Prefer fixing issues via GDScript code or surgical property edits.
3. **CASE-SENSITIVE PATHS**:
   - Always use lowercase directory names when referencing scenes via `get_tree().change_scene_to_file()` or `load()`/`preload()` (e.g., `res://scenes/...`, NOT `res://Scenes/...`).
4. **TELEMETRY CONTRACT COMPATIBILITY**:
   - `TelemetryManager` events must conform to the contract defined and tested in `tests/test_analytics_contract.py`. Do not alter event schema keys without updating and verifying tests.

---

## 2. Architecture & Design Patterns

- **Inheritance & Base Classes**:
  - World scenes inherit from `BaseWorldScene` (`res://scenes/world_scenes/BaseWorldScene.gd`).
  - Puzzle UI elements inherit from `BasePuzzleUI`.
  - Player character logic adheres to `BasePlayer`.
- **Autoload Singletons (`project.godot`)**:
  - `GlobalSettings`: Handles display mode (fullscreen/windowed), audio volumes, and user settings persistence.
  - `TelemetryManager`: Dispatches analytics/game telemetry to network/backend.
  - `FloatMenu`: Global pause menu and settings modal launcher running on a top-level `CanvasLayer`.
  - `InventoryManager`: Manages collected inventory items and evidence.
- **Separation of Concerns**:
  - Keep visual UI presentation separate from non-visual data managers.
  - Do not place heavy game logic inside button signal handlers. Delegate to manager classes or base controllers.

---

## 3. Testing & Verification

Before claiming any task is complete, run appropriate verification commands:

```powershell
# Python Telemetry & Analytics Contract Tests
pytest tests/test_analytics_contract.py
```

For Godot GDScript and scene verification:
- Ensure all newly created or modified scripts parse without compilation errors.
- Ensure node references (`get_node`, `%UniqueNode`, `@onready`) match the actual node tree.
- Check scene file references and UIDs to avoid broken dependencies.

---

## 4. Superpowers Engineering Workflow

- **Brainstorming First**: For any new feature, mechanics design, or architectural change, brainstorm options and confirm requirements before writing code.
- **Implementation Planning**: Multi-step tasks must be structured with clear checklists and test gates (`docs/superpowers/plans/`).
- **Test-Driven & Verification**: Never claim a bug is fixed or a feature is complete without verifiable evidence (run commands, examine outputs, check diffs).
