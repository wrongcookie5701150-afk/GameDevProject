# Project Superpowers Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up git hygiene, establish project rules (`AGENTS.md`), centralize the FloatMenu into a global Autoload, and verify project stability following Superpowers engineering standards.

**Architecture:** 
1. Git Hygiene: Ignore `.skills/`, clean orphan temp files.
2. Rule Enforcement: Establish root-level `AGENTS.md` containing strict project constraints, testing commands, and architecture rules.
3. Global UI: Elevate `FloatMenu.tscn` into a global `CanvasLayer` Autoload, eliminating per-scene duplicate nodes and duplicate ESC input handlers.
4. Verification: Run telemetry tests and scene integrity checks.

**Tech Stack:** Godot 4.x (GDScript), Python 3.12 (pytest), Git

---

## Global Constraints
- Do NOT touch `res://ui/os_simulation/notebook_screen.tscn` (Locked as per PROGRESSSION.md).
- Avoid destructive `.tscn` rewrites.
- Ensure all scene paths strictly use lowercase directories (`res://scenes/...`).
- Run tests and check outputs before claiming completion.

---

### Task 1: Git Hygiene & Cleanup
**Files:**
- Modify: `.gitignore`
- Remove: Orphan `*.tmp` files across `game_client/`

- [ ] Step 1.1: Add `.skills/` to root `.gitignore`.
- [ ] Step 1.2: Remove orphan `.tmp` files (`FloatMenu.tscn1282066778.tmp`, etc.).
- [ ] Step 1.3: Verify `git status` shows clean tracking with no `.skills/` untracked.

---

### Task 2: Project Rules & Guidelines (`AGENTS.md`)
**Files:**
- Create: `AGENTS.md`

- [ ] Step 2.1: Author `AGENTS.md` containing project architecture, locked files, GDScript conventions, and test commands.
- [ ] Step 2.2: Verify formatting and clarity.

---

### Task 3: Global FloatMenu & Input Centralization
**Files:**
- Modify: `game_client/ui/menus/FloatMenu.tscn`
- Modify: `game_client/ui/menus/float_menu.gd`
- Modify: `game_client/project.godot`
- Modify: `game_client/scenes/world_scenes/scene_02_tutorial/scene_02_tutorial.gd`
- Modify: `game_client/scenes/scene_01_intro/Scene_01_Intro.tscn`
- Modify: `game_client/scenes/world_scenes/scene_02_tutorial/Scene_02_Tutorial.tscn`
- Modify: `game_client/scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn`

- [ ] Step 3.1: Adjust `FloatMenu.tscn` and `float_menu.gd` to work as a CanvasLayer Autoload with `can_pause` support.
- [ ] Step 3.2: Register `FloatMenu` in `project.godot` Autoload list.
- [ ] Step 3.3: Remove duplicate ESC handling in `scene_02_tutorial.gd`.
- [ ] Step 3.4: Remove local duplicate `FloatMenu` instances from Scene 1, Scene 2, and Scene 4.

---

### Task 4: Automated Verification & Review
**Files:**
- Test: `tests/test_analytics_contract.py`

- [ ] Step 4.1: Run `pytest` to confirm telemetry contract passes.
- [ ] Step 4.2: Verify Godot configuration and syntax validity.
- [ ] Step 4.3: Final inspection of git diff and status.
