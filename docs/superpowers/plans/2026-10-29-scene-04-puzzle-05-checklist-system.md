# Implementation Plan: Scene 4 Puzzle 5 Automated Checklist System

**Date:** 2026-10-29  
**Branch:** `feat/OOP`  
**Task ID:** T05 / Puzzle 5 (TaoDam Laptop Isolation Checklist)

---

## 1. Overview & Requirements
In Scene 4, Puzzle 5 (Checklist UI / Task 05 "Isolate TaoDam before inspection") must be checked automatically by the game system based on player actions inside Notebook TaoDam (`NotebookScreen`), rather than player manually clicking static checkboxes.

### Player Action Mappings:
1. **Action 1 (Wi-Fi & LAN)**:
   - Player clicks the Wi-Fi/Network tray button in Taskbar -> opens Network popup.
   - Player toggles Wi-Fi to OFF -> tray icon changes to `res://assets/Icon32x32/world_disable.png` ("No Internet" icon), status shows disconnected.
   - System detects this and marks both `wifi_disabled = true` and `lan_unplugged = true`.
2. **Action 2 (Personal Accounts Unlinked)**:
   - Player opens an app from Start Menu or desktop (e.g. Google Drive or Discord).
   - App window opens displaying a Login screen with a "Login / เข้าสู่ระบบ" button (demonstrating that no personal account is logged in).
   - System detects this and marks `personal_accounts_unlinked = true`.
3. **Action 3 (No Important Work Files)**:
   - Player opens File Explorer (e.g. "งานกลุ่มล้านแปด" / `MenuFiles` or desktop folder icon).
   - Window opens displaying an empty folder view ("โฟลเดอร์นี้ว่างเปล่า (Empty folder - 0 files)").
   - System detects this and marks `no_important_files = true`.
4. **Resolution**:
   - When all 4 conditions are satisfied, `Checklist_UI` automatically completes and fires `puzzle_resolved`.
   - Scene 4 advances smoothly to the next stage (Event Log & Drive History investigation).

---

## 2. Guardrails & Constraints
- `game_client/ui/os_simulation/notebook_screen.tscn` is **STRICTLY LOCKED**. All interaction logic must be hooked via GDScript without modifying this file.
- Telemetry event contract `isolation_checklist_submitted` must remain fully compliant.
- `tests/test_analytics_contract.py` must pass 100%.

---

## 3. Step-by-Step Implementation Steps

### Step 1: Update `checklist_ui.gd`
- Fix node paths to match `Checklist_UI.tscn` (`$TaskObjective/Content/WifiCheck`, etc.).
- Remove dependencies on non-existent `$Panel/Content/SubmitButton` and `$Panel/Content/FeedbackLabel`.
- Make checkboxes read-only to mouse clicks (controlled by game system).
- Add `update_condition(condition_key: String, value: bool) -> void`.
- When all 4 conditions are true, auto-submit puzzle.

### Step 2: Implement Notebook TaoDam Interaction Controller in `scene_04_investigation_intro.gd`
- Wire up nodes inside `NotebookScreen`:
  - `StartButton`: Toggles `StartMenuPopup`.
  - `WifiTrayButton`: Toggles `WifiPopup`.
  - `WifiCloseBtn`: Closes `WifiPopup`.
  - `WifiToggleBtn`: Toggles Wi-Fi state:
    - On -> Off: Updates `WifiStatusLabel`, `WifiCloudSyncLabel`, changes `WifiTrayButton.icon` to `world_disable.png`, text to "No Internet".
    - Triggers `wifi_disabled` and `lan_unplugged` on checklist.
  - `MenuDiscord` / `MenuGGDisk`:
    - Opens an account login prompt window inside `WindowContainer` with a "Login" button.
    - Triggers `personal_accounts_unlinked` on checklist.
  - `MenuFiles` ("งานกลุ่มล้านแปด") / `EvfileIcon`:
    - Opens a folder window inside `WindowContainer` showing empty folder ("โฟลเดอร์นี้ว่างเปล่า").
    - Triggers `no_important_files` on checklist.
  - `StartMenuLeaveBtn`: Closes notebook screen and returns to room.

### Step 3: Wire Scene 4 Transition & Feedback
- Interacting with `taodam` in room shows `notebook_screen` and shows `Checklist_UI`.
- When puzzle resolves:
  - Updates objective label.
  - Advances to Event Log puzzle.

### Step 4: Verification & Testing
- Run `pytest tests/test_analytics_contract.py`.
- Verify GDScript syntax and node references.
