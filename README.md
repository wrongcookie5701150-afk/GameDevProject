# Cybersecurity Story Game - MVP Master Plan

## Project Overview

A 2D, story-driven cybersecurity learning game built in Godot 4.x (`game_client/`). The story follows May, a university student whose group project files are encrypted/wiped after she enables macros in a suspicious document from a spoofed sender. With guidance from her senior March, the player prepares an isolated forensic laptop ("TaoDam"), creates a forensic image on an external flashdrive (`EV-DRIVE`), verifies hashes, analyzes Windows Event Logs, GG Disk activity logs, and VBA macros, decodes Base64/Hex payloads, stops persistence, restores clean backups using the 3-2-1 rule, and completes the final incident report.

The repository also contains a FastAPI analytics backend (`backend_api/`) and contract tests (`tests/test_analytics_contract.py`).

## Learning Outcomes (K-S-A)

| Area | Intended outcome |
| --- | --- |
| Knowledge | Explain how a spoofed sender/domain and macro-enabled document can introduce malware; interpret event timelines, persistence triggers, file changes, and cloud-sync effects; distinguish destructive file wiping from recoverable encryption; describe safe recovery and backup practices. |
| Skills | Inspect sender and file metadata; identify suspicious event-log entries; connect a macro payload to a created helper; decode provided Base64/hex values; isolate a device, preserve evidence, stop persistence/sync, select a clean recovery point, and report findings. |
| Attitudes | Verify sources before trusting attachments; do not enable unexpected active content; contain incidents before attempting recovery; preserve evidence; choose cautious, verified recovery actions. |

## 7-Scene Linear Story & Gameplay Flow

The game alternates cleanly between **Bedroom & Phone (`BaseWorldScene`)**, **May's Desktop PC (`DesktopScreen`)**, and **TaoDam Forensic Notebook (`NotebookScreen`)** across 7 distinct scenes:

| Scene | Scene File (`res://scenes/...`) | Environment | Story & Player Flow | Tasks / Puzzles |
| --- | --- | --- | --- | --- |
| **Scene 1** | `scene_01_intro/Scene_01_Intro.tscn` | Bedroom Cutscene | At 19:02, May receives a phone call from Mesa reminding her to finish the group report. | Narrative Intro |
| **Scene 2** | `world_scenes/scene_02_tutorial/Scene_02_Tutorial.tscn` | Bedroom & Phone | May walks in the bedroom (`WASD`), presses `[P]` to read Mesa's chat messages on her phone, then walks to her Desktop PC and presses `[Spacebar]`. | `T01` (Read Messages), `T02` (PC Interaction) |
| **Scene 3** | `scene_03_incident/Scene_03_Incident.tscn` | May's PC (`DesktopScreen`) | **Phase A (Interactive)**: Open `GG Disk`, download `งานกลุ่ม`, open `Report.docx` in `MsWord`, click `Enable` on the Macro banner, and complete `Puzzle_Typing_Game`.<br>**Phase B (Incident Cutscene)**: Timelapse (`19:30` -> `21:23`) streams the report text and notifications, prompts player to click `Save`, triggers the glitch + `.locked` files + `RansomNote`, shows March's Discord toast, and unlocks `ออก (Exit)`. | `T03` (Download & Macro Enable), `T04` / `P00` (`Puzzle_Typing_Game`), Incident Cutscene |
| **Scene 4** | `world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn` | Bedroom & Phone | Press `[P]` to chat with March for incident response advice -> Place **TaoDam** notebook on the desk & pick up **Flashdrive (`EV-DRIVE`)** from the bookshelf -> Bring `EV-DRIVE` to May's PC to create a **Forensic Image** copy -> Interact with TaoDam on the desk. | March Chat, Collect `EV-DRIVE`, Create Forensic Image |
| **Scene 5** | `scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn` | TaoDam Notebook (`NotebookScreen`) | Verify TaoDam's **Isolated Environment** before plugging in evidence: (1) Disconnect Wi-Fi & LAN via tray icon, (2) Check `Start > Discord / GG Disk` to confirm no personal accounts are logged in (`AppLoginWindow`), (3) Check `Start > Files` to confirm no important local files exist (`FileExplorerWindow`). | `T05` (`Checklist_UI`) |
| **Scene 6** | `scene_06_taodam_investigation/Scene_06_TaoDam_Investigation.tscn` | TaoDam Notebook (`NotebookScreen` + `ForensicToolbar`) | Plug in `EV-DRIVE (E:)` and perform the 6-step forensic investigation on TaoDam:<br>1. Verify MD5 Hash (`Puzzle_Hash_Verify`)<br>2. Inspect `Windows_Event_Log.txt` (`Puzzle_Event_Log`)<br>3. Inspect `Drive_Activity.log` typosquatting (`Puzzle_Drive_History`)<br>4. Inspect `.docx` macro structure (`Puzzle_File_Structure`)<br>5. Decode helper name & `FILE_WIPE` mode (`Puzzle_Decoder`)<br>6. Order the 7 persistence containment steps (`Puzzle_Persistence_Order`)<br>*(Also includes interactive `EvFolder`, `InspectorApp`, and `DecoderApp` windows)* | `T08` (`P03`), `T06` (`P01`), `T07` (`P02`), `T09` (`P04`), `T10` (`P05`), `T11` (`P06`), `T12` (`P07`) |
| **Scene 7** | `scene_07_recovery/Scene_07_Recovery.tscn` | May's PC (`DesktopScreen`) | Return to May's PC to: (1) Configure safe **3-2-1 Backup Recovery** from before `19:02` (`18:55` clean point, separate external drive, cloud sync disabled), (2) Complete the **Final Incident Report**, and (3) Review the **K-S-A Assessment Summary** before returning to `MainMenu.tscn`. | `T13` (`P08` - `Puzzle_321_Backup`), `T14` (`P09` - `Puzzle_Last_Boss_Summary`), `T15` (`P10` - `KSA_Evaluation_UI`) |

> **Note on `SplashScreen.tscn`**: `res://scenes/splash/SplashScreen.tscn` is intentionally skipped on startup (`run/main_scene` is `res://ui/menus/MainMenu.tscn`) and reserved only for pre-game loading when needed.

## Canonical Task and Puzzle IDs

*(Note: Telemetry `scene_id` values on puzzle nodes remain aligned with the backend contract in `tests/test_analytics_contract.py`)*

| Task | Puzzle | Active Scene | Telemetry `scene_id` | Canonical Activity |
| --- | --- | --- | --- | --- |
| T01 | - | Scene 2 | `Scene_02` | Read Mesa's Messages on Phone |
| T02 | - | Scene 2 | `Scene_02` | Bedroom PC Interaction |
| T03 | - | Scene 3 | `Scene_02` | Download Cloud Folder & Enable Macro |
| T04 | P00 | Scene 3 | `Scene_02` | Typing Minigame (`Puzzle_Typing_Game`) |
| T05 | - | Scene 5 | `Scene_04` | Isolated Environment Checklist (`Checklist_UI`) |
| T08 | P03 | Scene 6 | `Scene_05` | MD5 Hash Verification (`Puzzle_Hash_Verify`) |
| T06 | P01 | Scene 6 | `Scene_04` | Event Log Timeline Selection (`Puzzle_Event_Log`) |
| T07 | P02 | Scene 6 | `Scene_04` | Drive History / Typosquatting (`Puzzle_Drive_History`) |
| T09 | P04 | Scene 6 | `Scene_05` | Macro Structure Inspection (`Puzzle_File_Structure`) |
| T10 | P05 | Scene 6 | `Scene_05` | Base64 Decode (`Office_Update_Helper`) |
| T11 | P06 | Scene 6 | `Scene_05` | Hex -> Base64 Decode (`FILE_WIPE`) |
| T12 | P07 | Scene 6 | `Scene_05` | Stop Persistence 7-Step Sequence (`Puzzle_Persistence_Order`) |
| T13 | P08 | Scene 7 | `Scene_06` | 3-2-1 Backup & Recovery Configuration (`Puzzle_321_Backup`) |
| T14 | P09 | Scene 7 | `Scene_06` | Final Incident Report (`Puzzle_Last_Boss_Summary`) |
| T15 | P10 | Scene 7 | `Scene_06` | K-S-A Evaluation Summary (`KSA_Evaluation_UI`) |

## Current `res://` Directory Structure (`game_client/`)

```text
res://
|-- project.godot
|-- autoload/
|   |-- GlobalSettings.gd
|   |-- InventoryManager.gd
|   |-- TelemetryManager.gd
|   `-- TelemetryNetworkAdapter.gd
|-- analytics/
|   |-- BaseTelemetryParam.gd
|   |-- PuzzleTelemetryParam.gd
|   |-- TypingTelemetryParam.gd
|   |-- ForensicAnalysisTelemetryParam.gd
|   |-- SequenceTelemetryParam.gd
|   |-- OSTelemetryParam.gd
|   |-- IncidentTelemetryParam.gd
|   |-- RecoveryTelemetryParam.gd
|   |-- GameplayTelemetryParam.gd
|   |-- NarrativeTelemetryParam.gd
|   `-- AssessmentTelemetryParam.gd
|-- scenes/
|   |-- splash/SplashScreen.tscn (+ splash_screen.gd)
|   |-- common/
|   |   |-- player/{BasePlayer.gd, Player.gd, Player.tscn}
|   |   `-- interact_object/{interact_object.gd, bed, bookshelf, desktop, ev_drive, lamp, note_board, notebook, plant_pot, speaker}.tscn
|   |-- initial/{playground.tscn, playground.gd, room.tscn, note_board.tscn, note_board.gd}
|   |-- scene_01_intro/{Scene_01_Intro.tscn, cutscene_01_intro.gd}
|   |-- world_scenes/
|   |   |-- BaseWorldScene.gd
|   |   |-- scene_02_tutorial/{Scene_02_Tutorial.tscn, scene_02_tutorial.gd}
|   |   `-- scene_04_investigation_intro/{Scene_04_Investigation_Intro.tscn, scene_04_investigation_intro.gd}
|   |-- scene_03_incident/{Scene_03_Incident.tscn, Scene_03_Incident.gd, background.gd}
|   |-- scene_05_taodam_desktop/{Scene_05_TaoDam_Desktop.tscn, Scene_05_TaoDam_Desktop.gd}
|   |-- scene_06_taodam_investigation/{Scene_06_TaoDam_Investigation.tscn, Scene_06_TaoDam_Investigation.gd}
|   `-- scene_07_recovery/{Scene_07_Recovery.tscn, Scene_07_Recovery.gd}
|-- ui/
|   |-- menus/{MainMenu, FloatMenu, SettingsModal, ContinueModal}.tscn (+ .gd)
|   |-- base_classes/{BaseOverlayUI.gd, BaseOSWindow.gd, BasePuzzleUI.gd}
|   |-- overlays/{Checklist_UI, KSA_Evaluation_UI, inventory_bar}.tscn (+ .gd)
|   |-- os_simulation/
|   |   |-- desktop_screen.tscn (+ desktop_screen.gd, desktop_icon.gd, desktop_window.gd)
|   |   |-- notebook_screen.tscn [STRICTLY LOCKED]
|   |   |-- phone_panel.tscn (+ phone_panel.gd)
|   |   |-- phone_panel_investigation.tscn (+ phone_panel_investigation.gd)
|   |   `-- Application/{gg_disk, downloaded_folder, ms_word, discord_app, ev_folder, inspector_app, decoder_app}.tscn (+ .gd)
|   `-- puzzles/
|       |-- {BaseClickSelectPuzzle, BaseDecoderPuzzle, BaseSequencePuzzle, BaseFormPuzzle}.gd
|       |-- Puzzle_Typing_Game.tscn (+ typing_game.gd)
|       |-- Puzzle_Hash_Verify.tscn (+ hash_verify_puzzle.gd)
|       |-- Puzzle_Event_Log.tscn (+ event_log_puzzle.gd)
|       |-- Puzzle_Drive_History.tscn (+ drive_history_puzzle.gd)
|       |-- Puzzle_File_Structure.tscn (+ macro_structure_puzzle.gd)
|       |-- Puzzle_Decoder.tscn (+ decoder_puzzle.gd)
|       |-- Puzzle_Persistence_Order.tscn (+ persistence_order_puzzle.gd)
|       |-- Puzzle_321_Backup.tscn (+ backup_recovery_puzzle.gd)
|       `-- Puzzle_Last_Boss_Summary.tscn (+ incident_report_puzzle.gd)
`-- assets/
```

## Source Documents

- [Story Content](docs/Story%20Content.md)
- [Architecture Plan](docs/Architecture_plan.md)
- [Directory Tree](docs/Directory_tree.md)
- [Scene and Script Functions](docs/Work_Plan/Scenes%26Scripts_list.md)
- [Progression Status](game_client/PROGRESSSION.md)
