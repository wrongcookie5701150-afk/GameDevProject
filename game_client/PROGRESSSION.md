# Project Progression Status: Cybersecurity Educational Game (MVP)

## 1. Project Overview

- **Engine:** Godot 4.x
- **Genre:** 2D Top-Down Story-Driven Educational Cybersecurity Game
- **Architecture:** 7-Scene Linear Flow alternating between Bedroom/Phone (`BaseWorldScene`), May's PC (`DesktopScreenController`), and TaoDam Forensic Laptop (`NotebookScreen`), powered by reusable `BasePuzzleUI` subclasses and `TelemetryManager`.

## 2. Current 7-Scene Structure & Status

- **✅ Scene 1 (`res://scenes/scene_01_intro/Scene_01_Intro.tscn`) — Intro Cutscene**
  - Bedroom opening cutscene where May receives a phone call from Mesa about the group report. Transitions to Scene 2.
- **✅ Scene 2 (`res://scenes/world_scenes/scene_02_tutorial/Scene_02_Tutorial.tscn`) — Bedroom & Phone Tutorial**
  - Restored `PhonePanelController` (`phone_panel.gd`) on `PhonePanel`.
  - Player reads Mesa's chat messages (`[P]`, `T01`) and walks to May's Desktop PC (`[Spacebar]`, `T02`) to transition directly to Scene 3.
- **✅ Scene 3 (`res://scenes/scene_03_incident/Scene_03_Incident.tscn`) — May's PC: Typing Game & Incident Cutscene**
  - `Scene_03_Incident.gd` now extends `DesktopScreenController` (`desktop_screen.gd`).
  - **Phase A (Interactive)**: Player opens `GG Disk`, downloads `งานกลุ่ม`, opens `Report.docx` in `MsWord`, enables Macro content (`T03`), and completes `Puzzle_Typing_Game` (`T04`).
  - **Phase B (Cutscene)**: Automatically runs the timelapse sequence (`19:30` -> `21:23`), prompts player to click `Save`, plays the red glitch flash, locks files (`.locked`), displays `RansomNote`, shows March's Discord notification toast, and enables `ออก (Exit)` to transition to Scene 4.
- **✅ Scene 4 (`res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn`) — Bedroom & Phone: Prep TaoDam & Forensic Image**
  - Dedicated Bedroom & Phone scene (`PhonePanelInvestigation`).
  - Player chats with March (`[P]`), prepares TaoDam on the desk, picks up the `EV-DRIVE` flashdrive from the bookshelf, brings it to May's PC to create a **Forensic Image** copy (`EVDrivePanel`), and interacts with TaoDam to transition to Scene 5.
- **✅ Scene 5 (`res://scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn`) — TaoDam Notebook: Isolation Check**
  - Dedicated scene on `NotebookScreen` with `Checklist_UI` (`T05`), `AppLoginWindow`, and `FileExplorerWindow`.
  - Verifies all 4 isolation conditions (Wi-Fi off, LAN unplugged, no personal cloud/Discord accounts logged in, no local important files) before plugging in `EV-DRIVE`. Transitions to Scene 6.
- **✅ Scene 6 (`res://scenes/scene_06_taodam_investigation/Scene_06_TaoDam_Investigation.tscn`) — TaoDam Notebook: Forensic Investigation**
  - Dedicated forensic investigation scene on `NotebookScreen` with `ForensicToolbar`, `EvFolder`, `InspectorApp`, and `DecoderApp`.
  - Executes all 6 forensic puzzles in order:
    1. `Puzzle_Hash_Verify` (`T08` - MD5 Hash Verification)
    2. `Puzzle_Event_Log` (`T06` - Windows Event Log Timeline `19:02:10`)
    3. `Puzzle_Drive_History` (`T07` - GG Disk Activity Log Typosquatting `@universcity.example`)
    4. `Puzzle_File_Structure` (`T09` - Macro Structure `word/vbaProject.bin`)
    5. `Puzzle_Decoder` (`T10` & `T11` - Base64 `Office_Update_Helper` & Hex/Base64 `FILE_WIPE`)
    6. `Puzzle_Persistence_Order` (`T12` - 7-Step Persistence Containment Sequence)
  - Transitions to Scene 7 upon completion.
- **✅ Scene 7 (`res://scenes/scene_07_recovery/Scene_07_Recovery.tscn`) — May's PC: Backup Recovery, Final Report & KSA**
  - Styled on May's PC (`DesktopScreen`).
  - Player completes `Puzzle_321_Backup` (`T13`), `Puzzle_Last_Boss_Summary` (`T14`), and reviews `KSA_Evaluation_UI` (`T15`) before returning to `MainMenu.tscn`.

## 3. Strict Development Guardrails

- **Notebook Screen is Locked:** Never modify `res://ui/os_simulation/notebook_screen.tscn`. Layer overlays or hide child nodes at runtime via GDScript in parent scenes.
- **Case-Sensitive Paths:** Always use lowercase directory names in `res://` paths (`res://scenes/...`, `res://ui/...`).
- **Telemetry Contract:** Puzzle telemetry events conform to `tests/test_analytics_contract.py`.
