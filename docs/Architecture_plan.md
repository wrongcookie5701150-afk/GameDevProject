# Architecture Plan (7-Scene Linear Flow & OOP Hierarchy)

```text
Godot Game Architecture (Full OOP Class Hierarchy)
│
├── 🟣 Autoload Singletons (project.godot)
│   ├── GlobalSettings.gd           <-- จัดการหน้าจอ เสียง และการตั้งค่าผู้เล่น
│   ├── TelemetryManager.gd         <-- ส่งข้อมูล Analytics ไปยัง FastAPI Backend
│   │   └── TelemetryNetworkAdapter.gd (Async HTTP)
│   ├── FloatMenu.tscn              <-- เมนูหยุดเกม (Pause) และตั้งค่าบน CanvasLayer
│   └── InventoryManager.gd         <-- จัดการกระเป๋าไอเทม (เช่น แฟลชไดรฟ์ EV-DRIVE)
│
├── 🟢 Node2D (Gameplay World & 2D Entities)
│   │
│   ├──Scene_01_Intro.tscn (cutscene_01_intro.gd)
│   │   └── [Scene 1: ฉากเปิดเรื่องในห้องนอน เมษามีสายเรียกเข้าทวงงาน -> ไปยัง Scene 2]
│   │
│   ├── BaseWorldScene.gd (Node2D)  <-- Abstract Base Class สำหรับฉากเดินในห้องนอน 2D
│   │   │   [Properties: player_node, note_board_ui]
│   │   │   [Methods: setup_scene(), open_note_board(), _setup_inventory_ui()]
│   │   │
│   │   ├── Scene_02_Tutorial.tscn (scene_02_tutorial.gd)
│   │   │   └── [Scene 2: ห้องนอน & มือถือ (phone_panel.tscn) อ่านแชทเมษา (T01) แล้วเดินไปเปิด PC (T02) -> ไปยัง Scene 3]
│   │   │
│   │   └── Scene_04_Investigation_Intro.tscn (scene_04_investigation_intro.gd)
│   │       └── [Scene 4: ห้องนอน & มือถือ (phone_panel_investigation.tscn) แชทปรึกษาพี่มาร์ช -> จัดวางเต่าดำบนโต๊ะ -> หยิบแฟลชไดรฟ์ EV-DRIVE จากชั้นหนังสือ -> นำไปเสียบเครื่อง PC ของเมย์เพื่อทำ Forensic Image -> เปิดเต่าดำไปยัง Scene 5]
│   │
│   └── BasePlayer.gd (CharacterBody2D)
│       └── Player.tscn (Player.gd) <-- ตัวละครเมย์ที่อยู่ใน Playground.tscn
│
├── 💻 Control (OS Simulation & Dedicated Computer/Notebook Scenes)
│   │
│   ├── DesktopScreenController (desktop_screen.gd / desktop_screen.tscn)
│   │   │   [จำลองระบบปฏิบัติการบนเครื่อง PC ของเมย์: GG Disk, โฟลเดอร์งานกลุ่ม, MS Word, Discord, Wi-Fi Tray]
│   │   │
│   │   └── Scene_03_Incident.tscn (Scene_03_Incident.gd extends DesktopScreenController)
│   │       └── [Scene 3: เครื่อง PC ของเมย์ — ดาวน์โหลดงานกลุ่มจาก GG Disk -> เปิด Report.docx ใน MS Word -> กด Enable Macro (T03) -> เล่นมินิเกมพิมพ์งาน Puzzle_Typing_Game (T04) -> ตัดเข้า Cutscene Timelapse อัตโนมัติ (19:30-21:23) -> กด Save -> ติด Ransomware (.locked + RansomNote) -> แจ้งเตือนพี่มาร์ช -> กดออกจากคอมไปยัง Scene 4]
│   │
│   ├── Scene_05_TaoDam_Desktop.tscn (Scene_05_TaoDam_Desktop.gd)
│   │   └── [Scene 5: โน้ตบุ๊กเต่าดำ (NotebookScreen) — ตรวจสอบคุณสมบัติการ Isolate (Checklist_UI - T05): ตัดเน็ต Wi-Fi/LAN, เช็คบัญชี Cloud/Discord ว่าไม่ได้ Login (AppLoginWindow), และเช็ค File Explorer ว่าไม่มีไฟล์สำคัญในเครื่อง (FileExplorerWindow) -> ไปยัง Scene 6]
│   │
│   ├── Scene_06_TaoDam_Investigation.tscn (Scene_06_TaoDam_Investigation.gd)
│   │   └── [Scene 6: โน้ตบุ๊กเต่าดำ (NotebookScreen + ForensicToolbar + EV-DRIVE E:) — สืบสวนหลักฐานจากแฟลชไดรฟ์ครบทั้ง 6 ขั้นตอน:
│   │        1. เทียบค่า MD5 Hash (Puzzle_Hash_Verify - T08)
│   │        2. ตรวจเวลาเปิดไฟล์ใน Windows_Event_Log.txt (Puzzle_Event_Log - T06)
│   │        3. ตรวจอีเมลผู้ส่งปลอมใน Drive_Activity.log (Puzzle_Drive_History - T07)
│   │        4. ตรวจโครงสร้างไฟล์ Macro vbaProject.bin (Puzzle_File_Structure - T09)
│   │        5. ถอดรหัส Base64/Hex หาชื่อ Helper และโหมด FILE_WIPE (Puzzle_Decoder - T10/T11)
│   │        6. เรียงลำดับการหยุด Persistence & Scheduled Task 7 ขั้นตอน (Puzzle_Persistence_Order - T12)
│   │        พร้อมแอปเสริม EvFolder, InspectorApp, DecoderApp -> ไปยัง Scene 7]
│   │
│   └── Scene_07_Recovery.tscn (Scene_07_Recovery.gd)
│       └── [Scene 7: เครื่อง PC ของเมย์ (DesktopScreen) — กู้คืนไฟล์จาก 3-2-1 Backup ก่อนเวลา 19:02 (Puzzle_321_Backup - T13) -> นั่งทำรายงานสรุปเหตุการณ์ส่งอาจารย์ (Puzzle_Last_Boss_Summary - T14) -> แสดงผลประเมิน KSA (KSA_Evaluation_UI - T15) -> กลับสู่ MainMenu.tscn]
│
├── 🧩 BasePuzzleUI.gd (Control)  <-- Abstract Base Class สำหรับปริศนา/มินิเกมทั้งหมด
│   ├── checklist_ui.gd (Checklist_UI.tscn)                    [Scene 5 - T05]
│   ├── typing_game.gd (Puzzle_Typing_Game.tscn)               [Scene 3 - T04]
│   ├── BaseClickSelectPuzzle.gd
│   │   ├── event_log_puzzle.gd (Puzzle_Event_Log.tscn)        [Scene 6 - T06]
│   │   ├── drive_history_puzzle.gd (Puzzle_Drive_History.tscn)[Scene 6 - T07]
│   │   └── macro_structure_puzzle.gd (Puzzle_File_Structure.tscn) [Scene 6 - T09]
│   ├── BaseDecoderPuzzle.gd
│   │   ├── hash_verify_puzzle.gd (Puzzle_Hash_Verify.tscn)    [Scene 6 - T08]
│   │   └── decoder_puzzle.gd (Puzzle_Decoder.tscn)            [Scene 6 - T10, T11]
│   ├── BaseSequencePuzzle.gd
│   │   └── persistence_order_puzzle.gd (Puzzle_Persistence_Order.tscn) [Scene 6 - T12]
│   ├── backup_recovery_puzzle.gd (Puzzle_321_Backup.tscn)     [Scene 7 - T13]
│   ├── incident_report_puzzle.gd (Puzzle_Last_Boss_Summary.tscn) [Scene 7 - T14]
│   └── ksa_evaluation.gd (KSA_Evaluation_UI.tscn)             [Scene 7 - T15]
│
└── ⚙️ Analytics Engine Pipeline (res://analytics/)
    └── BaseTelemetryParam.gd (RefCounted)
        ├── PuzzleTelemetryParam.gd
        │   ├── TypingTelemetryParam.gd
        │   ├── ForensicAnalysisTelemetryParam.gd
        │   └── SequenceTelemetryParam.gd
        ├── OSTelemetryParam.gd
        ├── IncidentTelemetryParam.gd
        ├── RecoveryTelemetryParam.gd
        ├── GameplayTelemetryParam.gd
        ├── NarrativeTelemetryParam.gd
        └── AssessmentTelemetryParam.gd
```
