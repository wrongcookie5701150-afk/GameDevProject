# Cybersecurity Story Game - MVP Master Plan

## Project Overview

A 2D, story-driven cybersecurity learning game built in Godot 4. The MVP follows May, a university student whose files are damaged after she enables active content in a suspicious document. With help from March, the player investigates the incident, identifies the malware behavior, stops its persistence and sync, and restores a safe backup.

The MVP prioritizes playable mechanics, clear feedback, static typing, and maintainable object-oriented structure. Placeholder controls and visuals (such as `ColorRect`, `Panel`, standard Godot fonts, and buttons) are sufficient; custom art and polish are not prerequisites.

The repository also contains a FastAPI analytics backend and contract tests. The Godot project is at `game_client/` (not `game-client/`).

## Learning Outcomes (K-S-A)

| Area | Intended outcome |
| --- | --- |
| Knowledge | Explain how a spoofed sender/domain and macro-enabled document can introduce malware; interpret event timelines, persistence triggers, file changes, and cloud-sync effects; distinguish destructive file wiping from recoverable encryption; describe safe recovery and backup practices. |
| Skills | Inspect sender and file metadata; identify suspicious event-log entries; connect a macro payload to a created helper; decode provided Base64/hex values; isolate a device, preserve evidence, stop persistence/sync, select a clean recovery point, and report findings. |
| Attitudes | Verify sources before trusting attachments; do not enable unexpected active content; contain incidents before attempting recovery; preserve evidence; choose cautious, verified recovery actions. |

Learning is assessed through puzzle results, attempts, hint usage, and a final case summary. Telemetry records task outcomes and task-specific metrics; it supports evaluation and is not itself a learning outcome.

## Story and MVP Flow

| Scene | Story and player flow | Learning/mechanics focus |
| --- | --- | --- |
| 1. Intro | At 19:02, Mesa calls May about the overdue assignment. Dialogue ends by loading the tutorial. | Establish characters, deadline, and motivation. |
| 2. Tutorial and workstation | May reads four messages, moves with WASD, interacts with the workstation, opens the shared report, enables its content, and completes a typing task. | Movement/interact, phone UI, file interaction, and typing feedback. |
| 3. Incident | A fake update and distracting notifications precede the project files becoming `.locked`; a ransom note appears and May contacts March. | Recognize the incident and communicate its visible impact. |
| 4. Investigation and triage | May isolates the old laptop, checks its environment, inspects the event log and drive history, and identifies suspicious activity and the spoofed report. | Isolation checklist, timeline analysis, sender/file provenance. |
| 5. Forensic lab | May works from an evidence copy, inspects the document structure and macro, decodes the helper data, and reasons about persistence and destructive behavior. | Evidence integrity, macro inspection, encoding, event correlation, containment. |
| 6. Recovery and conclusion | May selects a clean version-history point, a separate destination, and disabled sync, then completes the final report and K-S-A evaluation. | Safe restoration, incident summary, learning assessment. |

The scenes should be linked end to end. Each puzzle submission follows the same flow: user input -> base-class validation -> success/failure feedback -> telemetry event -> next task or scene when appropriate.

## Canonical Task and Puzzle IDs

This mapping overrides IDs in older story, architecture, scene/function, and telemetry notes. Use these IDs for all new UI and telemetry work.

| Task | Puzzle | Scene | Canonical activity |
| --- | --- | --- | --- |
| T01 | - | 2 | Read Messages |
| T02 | - | 2 | PC Interaction |
| T03 | - | 2 | Open Cloud File |
| T04 | P00 | 2 | Typing Minigame |
| T05 | - | 4 | Isolated Environment Checklist |
| T06 | P01 | 4 | Event Log Timeline Selection |
| T07 | P02 | 4 | Drive History / Typosquatting |
| T08 | P03 | 5 | Hash Verification |
| T09 | P04 | 5 | Macro Structure / File Mapping |
| T10 | P05 | 5 | Base64 Decode, target `Office_Update_Helper` |
| T11 | P06 | 5 | Hex Decode, target Wiper Mode |
| T12 | P07 | 5 | Stop Persistence, 7-step sequence |
| T13 | P08 | 6 | 3-2-1 Backup and Recovery Configuration |
| T14 | - | 6 | Final Report Fill-in |
| T15 | - | 6 | K-S-A Evaluation Dashboard |

## Full OOP Architecture

This is the planned class hierarchy from `docs/Architecture_plan.md`, expressed without implying that every class or scene already exists.

```text
Node2D (gameplay world and 2D entities)
|-- BaseWorldScene.gd
|   |-- Scene_02_Tutorial.tscn [Tasks 1-4]
|   `-- Scene_04_Investigation_Intro.tscn [investigation world]
`-- BasePlayer.gd (CharacterBody2D)
  `-- Player.tscn

Control (user interface)
|-- BaseOverlayUI.gd
|   |-- Phone_UI.tscn
|   |-- Phone_Chat_UI.tscn
|   |-- Incoming_Call_UI.tscn
|   |-- Dialogue_Box.tscn
|   |-- Checklist_UI.tscn
|   `-- KSA_Evaluation_UI.tscn
|-- BaseOSWindow.gd
|   |-- Desktop_Main_PC.tscn
|   |-- Scene_05_TaoDam_Desktop.tscn
|   |-- Folder_View_UI.tscn
|   `-- Ransom_Note_UI.tscn
`-- BasePuzzleUI.gd
  |-- BaseClickSelectPuzzle.gd
  |   |-- Puzzle_Event_Log.tscn
  |   |-- Puzzle_Drive_History.tscn
  |   `-- Puzzle_File_Structure.tscn
  |-- BaseDecoderPuzzle.gd
  |   |-- Puzzle_Hash_Verify.tscn
  |   `-- Puzzle_Decoder.tscn
  |-- BaseSequencePuzzle.gd
  |   `-- Puzzle_Persistence_Order.tscn
  |-- BaseFormPuzzle.gd
  |   |-- Puzzle_321_Backup.tscn
  |   `-- Puzzle_Last_Boss_Summary.tscn
  `-- Puzzle_Typing_Game.tscn

Analytics pipeline
|-- TelemetryManager.gd (Node / Autoload)
|   `-- TelemetryNetworkAdapter.gd (async HTTP adapter)
`-- BaseTelemetryParam.gd (RefCounted DTO)
  |-- PuzzleTelemetryParam.gd
  |   |-- TypingTelemetryParam.gd
  |   |-- ForensicAnalysisTelemetryParam.gd
  |   `-- SequenceTelemetryParam.gd
  |-- OSTelemetryParam.gd
  |-- IncidentTelemetryParam.gd
  |-- GameplayTelemetryParam.gd
  |-- NarrativeTelemetryParam.gd
  `-- AssessmentTelemetryParam.gd
```

Core responsibilities:

- `BasePlayer` owns four-direction movement and an `Area2D`-based interaction contract; world objects respond to interaction rather than embedding scene-specific puzzle rules in the player.
- `BaseWorldScene` initializes its world, resolves the player, and routes local gameplay events.
- `BasePuzzleUI` owns task timer, attempt count, hint/resolution state, validation flow, and common submission feedback. Specialized puzzle bases implement reusable input patterns.
- `TelemetryManager` owns task timers and event dispatch. Typed DTOs serialize scene/task-specific metrics. The network adapter handles asynchronous backend requests.
- Scene and puzzle subclasses own story-specific content and answer criteria. They should not duplicate shared movement, submission, or telemetry behavior.

## Current Repository Structure

This is the structure observed in the workspace before any scaffolding. Existing paths are case-sensitive in Godot resource references and should not be assumed to match the planned lower-case layout below.

```text
GameDevProject/
|-- backend_api/
|   |-- __init__.py
|   |-- main.py
|   `-- requirements.txt
|-- data_analytics/
|-- database/
|-- docs/
|   |-- Architecture_plan.md
|   |-- Directory_tree.md
|   |-- Story Content.md
|   |-- game_client_improvement_todo.md
|   |-- Git Tutorial.md
|   `-- Work_Plan/Scenes&Scripts_list.md
|-- game_client/
|   |-- project.godot
|   |-- addons/godot_mcp_toolkit/
|   |-- assets/{fonts,House,Icon,Icon32x32,images,sprite,Sprites,styles,Themes}/
|   |-- Scenes/
|   |   |-- Initial/{ContinueModal,desktop_screen,player,playground,room}.tscn
|   |   |-- Notebook/notebook_screen.tscn
|   |   |-- ui/{ContinueModal,FloatMenu,MainMenu,SettingsModal}.tscn
|   |   |-- Puzzle_{321_Backup,Drive_History,Event_Log,Hash_Verify,Typing_Game}.tscn
|   |   |-- Scene_01_Intro.tscn
|   |   |-- Scene_02_Tutorial.tscn
|   |   `-- SplashScreen.tscn
|   `-- Scripts/
|       |-- Core/{BasePlayer,BaseWorldScene,GlobalSettings}.gd
|       |-- desktop/{desktop_icon,desktop_screen,desktop_window}.gd
|       |-- ui/{continue_modal,float_menu,Main_menu,settings_modal}.gd
|       |-- Player.gd
|       |-- TelemetryManager.gd
|       |-- cutscene_01_intro.gd
|       |-- scene_02_tutorial.gd
|       `-- splash_screen.gd
|-- tests/test_analytics_contract.py
|-- pytest.ini
`-- README.md
```

Godot currently registers `TelemetryManager` from `res://Scripts/TelemetryManager.gd`, and its main scene is `res://Scenes/ui/MainMenu.tscn`. Existing base scripts are under `Scripts/Core/`; current project paths and autoload registration must be reconciled deliberately before moving or duplicating them.

## Planned `res://` Directory Structure

The following is the target layout documented in `docs/Directory_tree.md`. It is a plan, not the current on-disk tree. Step 2 will create the requested directories; any relocation or compatibility changes to existing resources must be handled explicitly so current scenes do not break.

```text
res://
|-- project.godot
|-- autoload/
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
|   |-- GameplayTelemetryParam.gd
|   |-- NarrativeTelemetryParam.gd
|   `-- AssessmentTelemetryParam.gd
|-- scenes/
|   |-- common/player/{BasePlayer.gd,Player.tscn}
|   |-- world_scenes/
|   |   |-- BaseWorldScene.gd
|   |   |-- scene_02_tutorial/Scene_02_Tutorial.tscn
|   |   `-- scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn
|   |-- scene_01_intro/Scene_01_Intro.tscn
|   |-- scene_03_incident/Scene_03_Incident.tscn
|   |-- scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn
|   `-- scene_06_recovery/Scene_06_Recovery.tscn
|-- ui/
|   |-- base_classes/{BaseOverlayUI.gd,BaseOSWindow.gd,BasePuzzleUI.gd}
|   |-- overlays/{Incoming_Call_UI,Dialogue_Box,Phone_UI,Phone_Chat_UI,Checklist_UI,KSA_Evaluation_UI}.tscn
|   |-- os_simulation/{Desktop_Main_PC,Folder_View_UI,Ransom_Note_UI}.tscn
|   `-- puzzles/
|       |-- BaseClickSelectPuzzle.gd
|       |-- BaseDecoderPuzzle.gd
|       |-- BaseSequencePuzzle.gd
|       |-- BaseFormPuzzle.gd
|       |-- Puzzle_Typing_Game.tscn
|       |-- Puzzle_Event_Log.tscn
|       |-- Puzzle_Drive_History.tscn
|       |-- Puzzle_Hash_Verify.tscn
|       |-- Puzzle_File_Structure.tscn
|       |-- Puzzle_Decoder.tscn
|       |-- Puzzle_Persistence_Order.tscn
|       |-- Puzzle_321_Backup.tscn
|       `-- Puzzle_Last_Boss_Summary.tscn
`-- assets/{sprites,audio,fonts}/
```

## Development Milestones

1. **Plan and contract alignment** - Confirm the target layout and whether existing files are moved or retained with compatibility references. Reconcile scene/task identifiers, puzzle names, and acceptance criteria against the story, architecture, and scene/function documents. Agree on the MVP boundary before broad migration.
2. **Directory and project foundation** - Create the target directories under `game_client/` (`res://`), preserve existing resources, define shared input/action names, and verify project/autoload/main-scene paths.
3. **Typed core and telemetry** - Implement the player and world base contracts, puzzle submission/validation/timer behavior, telemetry manager and adapter, and typed telemetry DTO subclasses. Verify each shared script parses and can be loaded before building dependent scenes.
4. **Playable opening (Scenes 1-2)** - Connect intro dialogue to the tutorial; implement movement/interact, phone messages, workstation/file interaction, typing task, and completion transitions.
5. **Incident and triage (Scenes 3-4)** - Present the ransomware incident, isolation checklist, event timeline, and drive-history investigation. Add feedback and telemetry for each task.
6. **Forensic investigation (Scene 5)** - Implement evidence/hash checks, document structure and macro inspection, decoder tasks, and persistence/containment sequence using reusable puzzle bases.
7. **Recovery and assessment (Scene 6)** - Implement safe version-history recovery, final report, K-S-A evaluation, and clear ending state.
8. **End-to-end verification** - Play the full route; verify resource links, input, puzzle success/failure, transitions, telemetry payload contracts, and backend compatibility. Run Godot import/runtime checks and the existing Python contract tests.

## Specification Notes

- Task numbering and puzzle mapping are canonicalized in the table above; older document IDs are not to be used for new UI or telemetry code. Preserve the source documents as historical design context, but treat this mapping as authoritative.
- The previous README described a narrower P1 tutorial-only vertical slice and explicitly deferred generic puzzle/telemetry work. This master plan records the requested six-scene MVP; scope must be confirmed before implementing the larger plan.
- The documented target uses lower-case `scenes/`, `ui/`, `autoload/`, and `analytics/`; the live Godot project is being migrated to that layout with references updated alongside the files.

## Source Documents

- [Story Content](docs/Story%20Content.md)
- [Architecture Plan](docs/Architecture_plan.md)
- [Directory Tree](docs/Directory_tree.md)
- [Scene and Script Functions](docs/Work_Plan/Scenes%26Scripts_list.md)
- [Game Client Improvement TODO](docs/game_client_improvement_todo.md)
