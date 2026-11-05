# TaoDam Evidence Inspector Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the FileTree and FileContent preview in `inspector_app.tscn`, populate all 8+ forensic evidence files from the story, and wire up the window controls to Scene 5 Desktop.

**Architecture:**
- Create `game_client/ui/os_simulation/Application/inspector_app.gd` managing Tree hierarchy, file content mapping, TextEdit preview, and window closing/minimizing.
- Update `inspector_app.tscn` to attach `inspector_app.gd`, configure FileTree min width (130px), set TextEdit to read-only with text wrapping.
- Wire up `InspectorIcon` on `NotebookScreen` and `InspectorButton` in `Scene_05_TaoDam_Desktop.gd` to toggle `InspectorApp`.
- Verify with automated tests (`pytest tests/test_analytics_contract.py`).

**Tech Stack:** Godot 4.x (GDScript), Python (pytest)

---

## Global Constraints
- `game_client/ui/os_simulation/notebook_screen.tscn` is **STRICTLY LOCKED**. Do NOT modify it.
- Keep scene edits surgical and non-destructive.
- Ensure case-sensitive paths use lowercase directories.
- Run tests and verify before completion.

---

### Task 1: Create `inspector_app.gd` Controller
**Files:**
- Create: `game_client/ui/os_simulation/Application/inspector_app.gd`

- [ ] Step 1.1: Define evidence dataset mapping keys to forensic text (Manifest, README, Report_Final, VBA macro, Event Log, Drive Activity, Helper.dat, Scheduled Task, Ransom Note, and Folder overviews).
- [ ] Step 1.2: Implement `_ready()` and `_populate_tree()` to build the TreeItem hierarchy under root `EV-DRIVE (E:)`.
- [ ] Step 1.3: Connect `tree.item_selected` to display matching content in `%TextEdit` (or find_child).
- [ ] Step 1.4: Connect `Exit` and `Minimize` buttons to hide the application window.

---

### Task 2: Update `inspector_app.tscn` UI
**Files:**
- Modify: `game_client/ui/os_simulation/Application/inspector_app.tscn`

- [ ] Step 2.1: Attach `inspector_app.gd` to root node `InspectorApp`.
- [ ] Step 2.2: Adjust `FileTree` panel `custom_minimum_size` to Vector2(130, 0) so file names fit comfortably.
- [ ] Step 2.3: Configure `TextEdit` properties (`editable = false`, `wrap_mode = 1` for line wrapping).

---

### Task 3: Wire Inspector in Scene 5 Desktop
**Files:**
- Modify: `game_client/scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.gd`

- [ ] Step 3.1: Locate `InspectorApp` inside `notebook_screen/WindowContainer/InspectorApp`.
- [ ] Step 3.2: Connect `InspectorIcon` on `NotebookScreen` to toggle `InspectorApp`.
- [ ] Step 3.3: Update `_on_inspector_pressed()` in forensic toolbar to toggle/show `InspectorApp`.
- [ ] Step 3.4: Connect `InspectorApp.close_requested` / hide handling.

---

### Task 4: Verification & Test Execution
**Files:**
- Test: `tests/test_analytics_contract.py`

- [ ] Step 4.1: Run `pytest tests/test_analytics_contract.py` outside sandbox to verify full test suite passes.
- [ ] Step 4.2: Verify node paths and signal connections across modified files.
- [ ] Step 4.3: Review git diff.
