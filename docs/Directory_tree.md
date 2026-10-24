# Directory tree

```text
res://
├── project.godot
│
├── 📂 autoload/                          # Central Controllers (Singleton)
│   ├── TelemetryManager.gd               # Autoload Engine หลักสำหรับรับ-ส่ง Analytics
│   └── TelemetryNetworkAdapter.gd        # Node ย่อยช่วยจัดการ HTTP/API Request แบบ Async
│
├── 📂 analytics/                         # รวม DTO Classes สำหรับห่อหุ้มข้อมูล Analytics
│   ├── BaseTelemetryParam.gd             # Base DTO
│   ├── PuzzleTelemetryParam.gd           # Base DTO สำหรับ Mini-games
│   ├── TypingTelemetryParam.gd           # DTO สำหรับมินิเกมพิมพ์งาน
│   ├── ForensicAnalysisTelemetryParam.gd # DTO สำหรับงานวิเคราะห์ Hash/Base64/Hex
│   ├── SequenceTelemetryParam.gd         # DTO สำหรับการเรียงลำดับขั้นตอน Persistence
│   ├── OSTelemetryParam.gd               # DTO สำหรับการโต้ตอบหน้าจอ OS & Typosquatting
│   ├── IncidentTelemetryParam.gd         # DTO สำหรับการกักกันเครื่องเต่าดำ
│   ├── GameplayTelemetryParam.gd         # DTO สำหรับการเดินและโต้ตอบในโลก 2D
│   ├── NarrativeTelemetryParam.gd        # DTO สำหรับ Chat / Phone / Dialogue
│   └── AssessmentTelemetryParam.gd       # DTO สำหรับประเมินผล K-S-A
│
├── 📂 scenes/                            # ฉากและ Entities ทั้งหมดในเกม
│   ├── 📂 common/                        # Entities & Reusable Objects ที่ถูกนำไปดึงใช้ใน World Scene
│   │   └── player/
│   │       ├── BasePlayer.gd             # Script หลักควบคุมการเดิน/Interact ของเมย์
│   │       └── Player.tscn               # Node2D Character Scene (ถูก Instantiate ใน World)
│   │
│   ├── 📂 world_scenes/                 # ฉาก 2D ที่มี Node2D + Player ผูกอยู่ภายใน
│   │   ├── BaseWorldScene.gd            # Script Abstract จัดการระบบภายใน World
│   │   ├── scene_02_tutorial/
│   │   │   └── Scene_02_Tutorial.tscn   # ฉากห้องนอน/ฝึกสอน (ดึง Player.tscn มาวาง)
│   │   └── scene_04_investigation_intro/
│   │       └── Scene_04_Investigation_Intro.tscn # ฉากเดินไปหยิบ EV Drive (ดึง Player.tscn มาวาง)
│   │
│   ├── scene_01_intro/
│   │   └── Scene_01_Intro.tscn          # Cutscene เปิดเรื่อง
│   ├── scene_03_incident/
│   │   └── Scene_03_Incident.tscn       # Cutscene เหตุการณ์ติด Ransomware
│   ├── scene_05_taodam_desktop/
│   │   └── Scene_05_TaoDam_Desktop.tscn  # หน้าจอเดสก์ท็อปเต่าดำ
│   └── scene_06_recovery/
│       └── Scene_06_Recovery.tscn       # ฉากสรุปและกู้คืนข้อมูล
│
├── 📂 ui/                                # ระบบ User Interface ทั้งหมด
│   ├── 📂 base_classes/                  # Abstract Base Classes ของ UI
│   │   ├── BaseOverlayUI.gd
│   │   ├── BaseOSWindow.gd
│   │   └── BasePuzzleUI.gd               # Abstract Class สำหรับ Puzzle UI ทั้งหมด
│   │
│   ├── 📂 overlays/                      # UI ลอยหน้าจอ / ระบบสื่อสาร
│   │   ├── Incoming_Call_UI.tscn
│   │   ├── Dialogue_Box.tscn
│   │   ├── Phone_UI.tscn
│   │   ├── Phone_Chat_UI.tscn
│   │   ├── Checklist_UI.tscn             # [Task 5] เช็กสภาพเครื่องเต่าดำ
│   │   └── KSA_Evaluation_UI.tscn        # แดชบอร์ดสรุปคะแนน K-S-A
│   │
│   ├── 📂 os_simulation/                 # ระบบจำลอง OS บนคอมพิวเตอร์
│   │   ├── Desktop_Main_PC.tscn
│   │   ├── Folder_View_UI.tscn
│   │   └── Ransom_Note_UI.tscn
│   │
│   └── 📂 puzzles/                       # Interactive Puzzles & Mini-games [สืบทอดจาก BasePuzzleUI]
│       ├── BaseClickSelectPuzzle.gd
│       ├── BaseDecoderPuzzle.gd
│       ├── BaseSequencePuzzle.gd
│       ├── BaseFormPuzzle.gd
│       ├── Puzzle_Typing_Game.tscn       # [Task 4] พิมพ์งาน 300 คำ
│       ├── Puzzle_Event_Log.tscn         # [Task 6] Event Log Timeline
│       ├── Puzzle_Drive_History.tscn     # [Task 7] Typosquatting
│       ├── Puzzle_Hash_Verify.tscn       # [Task 8] MD5 Hash Check
│       ├── Puzzle_File_Structure.tscn   # [Task 9-10] Macro Structure
│       ├── Puzzle_Decoder.tscn          # [Task 11, 13] Base64 / Hex
│       ├── Puzzle_Persistence_Order.tscn # [Task 14] 7 Steps Order
│       ├── Puzzle_321_Backup.tscn        # [Task 15] 3-2-1 Recovery Config
│       └── Puzzle_Last_Boss_Summary.tscn # [Task 16] Final Report Fill-in
│
└── 📂 assets/                            # ไฟล์ Media (Sprites, Sounds, Fonts)
    ├── sprites/
    ├── audio/
    └── fonts/
```
