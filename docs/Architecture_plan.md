# Architecture Plan

```text
Godot Game Architecture (Full OOP Class Hierarchy)
│
├── 🟢 Node2D (Gameplay World & 2D Entities)
│   │
│   ├── BaseWorldScene.gd (Node2D)  <-- Abstract Base Class สำหรับฉากเดินในห้อง 2D
│   │   │   [Properties: tile_map, player_spawn_pos, interactables]
│   │   │   [Methods: setup_scene(), trigger_event(), on_player_interacted()]
│   │   │
│   │   ├── Scene_02_Tutorial.tscn (BaseWorldScene) [Task 1-4]
│   │   └── Scene_04_Investigation_Intro.tscn (BaseWorldScene) [Task 5-7]
│   │
│   └── BasePlayer.gd (CharacterBody2D)  <-- Class ควบคุมตัวละครเมย์ (Entity)
│       │   [Properties: move_speed, current_direction, is_interacting]
│       │   [Methods: move(), interact(), emit_gameplay_telemetry()]
│       │
│       └── Player.tscn (BasePlayer)  <-- Instantiated ใน BaseWorldScene
│
├── 🔵 Control (User Interface Components)
│   │
│   ├── BaseOverlayUI.gd (Control / CanvasLayer)  <-- Base Class สำหรับ UI ลอยหน้าจอ
│   │   ├── Phone_UI.tscn (BaseOverlayUI)
│   │   ├── Phone_Chat_UI.tscn (BaseOverlayUI)
│   │   ├── Incoming_Call_UI.tscn (BaseOverlayUI)
│   │   ├── Dialogue_Box.tscn (BaseOverlayUI)
│   │   ├── Checklist_UI.tscn (BaseOverlayUI)
│   │   └── KSA_Evaluation_UI.tscn (BaseOverlayUI)
│   │
│   ├── BaseOSWindow.gd (Control)  <-- Base Class จำลองระบบปฏิบัติการ (May PC & เต่าดำ)
│   │   ├── Desktop_Main_PC.tscn (BaseOSWindow)
│   │   ├── Scene_05_TaoDam_Desktop.tscn (BaseOSWindow)
│   │   ├── Folder_View_UI.tscn (BaseOSWindow)
│   │   └── Ransom_Note_UI.tscn (BaseOSWindow)
│   │
│   └── BasePuzzleUI.gd (Control)  <-- Abstract Base Class สำหรับ ปริศนา/มินิเกม ทั้งหมด
│       │   [Properties: task_id, hint_delay_seconds, attempt_count, is_resolved, hint_used]
│       │   [Methods: _ready(), submit_puzzle(), validate_answer(), on_solve_success(), on_solve_failed()]
│       │
│       ├── BaseClickSelectPuzzle.gd (BasePuzzleUI)
│       │   ├── Puzzle_Event_Log.tscn (BaseClickSelectPuzzle) [Task 6]
│       │   ├── Puzzle_Drive_History.tscn (BaseClickSelectPuzzle) [Task 7]
│       │   └── Puzzle_File_Structure.tscn (BaseClickSelectPuzzle) [Task 9-10]
│       │
│       ├── BaseDecoderPuzzle.gd (BasePuzzleUI)
│       │   ├── Puzzle_Hash_Verify.tscn (BaseDecoderPuzzle) [Task 8]
│       │   └── Puzzle_Decoder.tscn (BaseDecoderPuzzle) [Task 11, 13]
│       │
│       ├── BaseSequencePuzzle.gd (BasePuzzleUI)
│       │   └── Puzzle_Persistence_Order.tscn (BaseSequencePuzzle) [Task 14]
│       │
│       ├── BaseFormPuzzle.gd (BasePuzzleUI)
│       │   ├── Puzzle_321_Backup.tscn (BaseFormPuzzle) [Task 15]
│       │   └── Puzzle_Last_Boss_Summary.tscn (BaseFormPuzzle) [Task 16]
│       │
│       └── Puzzle_Typing_Game.tscn (BasePuzzleUI) [Task 4]
│
└── ⚙️ Analytics Engine Pipeline
    │
    ├── TelemetryManager.gd (Node / Autoload Singleton)
    │   │   [Properties: active_timers, player_session_id, backend_url]
    │   │   [Signals: telemetry_sent, telemetry_failed, adaptive_gameplay_updated]
    │   │   [Methods: start_task_timer(), stop_task_timer(), track_event(), track_quick_event()]
    │   │
    │   └── TelemetryNetworkAdapter.gd (Node)  <-- Async HTTP Transfer ถึง FastAPI
    │
    └── BaseTelemetryParam.gd (RefCounted)  <-- Abstract Base DTO
        ├── PuzzleTelemetryParam.gd (BaseTelemetryParam)
        │   └── TypingTelemetryParam.gd (PuzzleTelemetryParam)
        │   └── ForensicAnalysisTelemetryParam.gd (PuzzleTelemetryParam)
        │   └── SequenceTelemetryParam.gd (PuzzleTelemetryParam)
        ├── OSTelemetryParam.gd (BaseTelemetryParam)
        ├── IncidentTelemetryParam.gd (BaseTelemetryParam)
        ├── GameplayTelemetryParam.gd (BaseTelemetryParam)
        ├── NarrativeTelemetryParam.gd (BaseTelemetryParam)
        └── AssessmentTelemetryParam.gd (BaseTelemetryParam)
```
