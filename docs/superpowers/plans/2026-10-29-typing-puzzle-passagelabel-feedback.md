# Typing Puzzle Real-Time Feedback & Cutscene PassageLabel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Option A real-time BBCode character feedback in `PassageLabel` (black for matched, red for mistyped, gray for untyped) behind transparent `TextEdit`, decouple `FeedbackLabel`, and route Scene 3 timelapse cutscene streaming to `PassageLabel`.

**Architecture:** 
1. `PassageLabel` (`RichTextLabel`) acts as the single visual paper surface in `ms_word.tscn` for both puzzle gameplay (Scene 2) and timelapse cutscene (Scene 3).
2. `typing_game.gd` updates BBCode dynamically in `_on_answer_changed()`, showing the fixed target string with character status colors.
3. `Scene_03_Incident.gd` streams the cutscene story chunks into `PassageLabel` with `TextEdit.editable = false` and removes all `TextCutscene` references.
4. `ms_word.gd` removes obsolete `TextCutscene` lookup and scrolls `passage_label` and `report_editor` together.

**Tech Stack:** Godot 4.x (GDScript, RichTextLabel BBCode), Python 3.12 (pytest).

**Spec:** Approved Design Document in conversation (2026-10-29) selecting Option A (MonkeyType-style character-by-character coloring).

## Global Constraints
- LOCKED FILE: `game_client/ui/os_simulation/notebook_screen.tscn` is STRICTLY LOCKED. Do NOT modify.
- NO DESTRUCTIVE UI OVERHAULS: Preserve `.tscn` structure. Code-level surgical adjustments only. Do NOT create visual styling in GDScript.
- CASE-SENSITIVE PATHS: Always use lowercase `res://scenes/...`.
- TELEMETRY COMPATIBILITY: Pass `pytest tests/test_analytics_contract.py` 100%.

## Review Focus
1. Backspace behavior: When deleting characters, `PassageLabel` must immediately revert trailing characters from red back to untyped gray.
2. Space character mismatch: When a space is expected and mistyped, display a red underscore `[color=red]_[/color]` so player clearly sees missing space.
3. Over-typing behavior: Extra characters typed beyond `TARGET_TEXT.length()` must be appended in red without crashing.
4. Cutscene isolation: While cutscene is streaming in Scene 3, `TextEdit` must not allow typing (`editable = false`).
5. Missing node safety: If `FeedbackLabel` or `TextCutscene` nodes do not exist in the scene tree, scripts must handle `null` gracefully.

---

### Task 1: Implement Real-Time BBCode Character Feedback in `typing_game.gd`

**Files:**
- Modify: `game_client/ui/puzzles/typing_game.gd`

**Interfaces:**
- Consumes: `TARGET_TEXT: String`, `answer_input: TextEdit`, `passage_label: RichTextLabel`
- Produces: Dynamic BBCode string on `passage_label.text` with colored characters; emits `scene_completion_requested` upon perfect match.

- [ ] **Step 1: Update node initialization and BBCode enablement**
  In `_ready()`, ensure `passage_label.bbcode_enabled = true`. Hide `feedback_label` if present. Initialize display with all untyped gray characters via `_update_passage_display("")`.

- [ ] **Step 2: Implement `_update_passage_display(typed_text: String)`**
  Construct BBCode comparing `typed_text` with `TARGET_TEXT`:
  - Matching char: `[color=black]%s[/color]`
  - Mistyped char: `[color=red]%s[/color]` (or `[color=red]_[/color]` if expected char is space `" "`)
  - Untyped char: `[color=#888888]%s[/color]`
  - Extra typed chars past target length: `[color=red]%s[/color]`

- [ ] **Step 3: Update `_on_answer_changed()` and completion conditions**
  Call `_update_passage_display(typed_text)`. Clear `feedback_label.text` if present. Check for full match (case-insensitive) and submit puzzle only when 100% matched and lengths match.

- [ ] **Step 4: Verify syntax and telemetry contract**
  Run `pytest tests/test_analytics_contract.py -k "test_issue3_task04_typing_game"` to ensure analytics contract remains valid.

---

### Task 2: Clean Up `ms_word.gd` Scroll and Node References

**Files:**
- Modify: `game_client/ui/os_simulation/Application/ms_word.gd`

**Interfaces:**
- Consumes: `passage_label: RichTextLabel`, `report_editor: TextEdit`, `v_scroll_bar: VScrollBar`
- Produces: `_update_scrollbar_range()` and `_apply_scroll(val)` without `TextCutscene` references.

- [ ] **Step 1: Remove `TextCutscene` references from `_update_scrollbar_range()`**
  Calculate `content_h` using `passage_label` or `report_editor` custom minimum size and height.

- [ ] **Step 2: Remove `TextCutscene` references from `_apply_scroll(val)`**
  Apply `-val` position offset directly to `passage_label` and `report_editor`.

---

### Task 3: Route Scene 3 Cutscene Streaming to `PassageLabel`

**Files:**
- Modify: `game_client/Scenes/scene_03_incident/Scene_03_Incident.gd`

**Interfaces:**
- Consumes: `ms_word: MSWordApp`, `PassageLabel: RichTextLabel`
- Produces: Streamed text into `passage_label` during timelapse, setting `TextEdit.editable = false`.

- [ ] **Step 1: Update `_init_ui_state()` in `Scene_03_Incident.gd`**
  - Keep `typing_puzzle` visible (`typing_puzzle.show()`).
  - Target `_report_editor` to `PassageLabel` (`RichTextLabel`).
  - Set `passage_label.bbcode_enabled = true` and `passage_label.text = ""`.
  - Locate `TextEdit` and set `editable = false` and `text = ""`.
  - Hide `FeedbackLabel` if found.
  - Remove all fallback searches for `TextCutscene`.

- [ ] **Step 2: Update `_stream_text()` and `_ready_for_save_event()`**
  - Stream chunks via `_report_editor.text += chunk`.
  - Auto-scroll via `ms_word.scroll_to_ratio(progress)`.
  - In `_ready_for_save_event()`, assign `_report_editor.text = FULL_REPORT_TEXT` and scroll to bottom.

---

### Task 4: Full System Verification

**Files:**
- Test: `tests/test_analytics_contract.py`
- Inspect: `git diff` across all modified files.

- [ ] **Step 1: Run telemetry contract test suite**
  Execute `pytest tests/test_analytics_contract.py` and confirm all 11 tests pass.

- [ ] **Step 2: Verify GDScript syntax across all modified files**
  Inspect scripts for parser/syntax errors or unresolved references.
