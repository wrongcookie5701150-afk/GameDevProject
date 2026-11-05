# Directory Tree (`game_client/` / `res://`)

```text
res://
├── project.godot
│
├── 📂 autoload/                                 # Global Singletons
│   ├── GlobalSettings.gd                        # ตั้งค่าการแสดงผลและเสียง
│   ├── InventoryManager.gd                      # จัดการไอเทมในกระเป๋า (เช่น EV-DRIVE)
│   ├── TelemetryManager.gd                      # Autoload Engine หลักสำหรับรับ-ส่ง Analytics
│   └── TelemetryNetworkAdapter.gd               # จัดการ HTTP/API Request แบบ Async ไปยัง FastAPI
│
├── 📂 analytics/                                # DTO Classes สำหรับห่อหุ้มข้อมูล Telemetry
│   ├── BaseTelemetryParam.gd
│   ├── PuzzleTelemetryParam.gd
│   ├── TypingTelemetryParam.gd
│   ├── ForensicAnalysisTelemetryParam.gd
│   ├── SequenceTelemetryParam.gd
│   ├── OSTelemetryParam.gd
│   ├── IncidentTelemetryParam.gd
│   ├── RecoveryTelemetryParam.gd
│   ├── GameplayTelemetryParam.gd
│   ├── NarrativeTelemetryParam.gd
│   └── AssessmentTelemetryParam.gd
│
├── 📂 scenes/                                   # ฉากทั้งหมดของเกม (เรียงตามลำดับ Scene 1 -> 7)
│   ├── 📂 splash/
│   │   ├── SplashScreen.tscn                    # ฉากโหลดก่อนเข้าเกม (ข้ามตอนเปิดเกมปกติ)
│   │   └── splash_screen.gd
│   │
│   ├── 📂 common/                               # Entities & Reusable Objects ในฉากห้องนอน 2D
│   │   ├── 📂 player/
│   │   │   ├── BasePlayer.gd
│   │   │   ├── Player.gd
│   │   │   └── Player.tscn
│   │   └── 📂 interact_object/
│   │       ├── interact_object.gd
│   │       ├── glow.gdshader
│   │       ├── bed.tscn
│   │       ├── bookshelf.tscn
│   │       ├── desktop.tscn
│   │       ├── ev_drive.tscn
│   │       ├── lamp.tscn
│   │       ├── note_board.tscn
│   │       ├── notebook.tscn
│   │       ├── plant_pot.tscn
│   │       └── speaker.tscn
│   │
│   ├── 📂 initial/                              # แผนที่ห้องนอนหลัก (Playground Prefab)
│   │   ├── playground.tscn
│   │   ├── playground.gd
│   │   ├── room.tscn
│   │   ├── note_board.tscn
│   │   └── note_board.gd
│   │
│   ├── 📂 scene_01_intro/                       # [Scene 1] Cutscene เปิดเรื่องในห้องนอน (รับสายเมษา)
│   │   ├── Scene_01_Intro.tscn
│   │   └── cutscene_01_intro.gd
│   │
│   ├── 📂 world_scenes/                         # ฉากเดินในห้องนอน 2D + โทรศัพท์มือถือ (สืบทอดจาก BaseWorldScene)
│   │   ├── BaseWorldScene.gd
│   │   ├── 📂 scene_02_tutorial/                # [Scene 2] ห้องนอน & มือถือ (อ่านแชทเมษา -> เดินไปเปิดคอม PC)
│   │   │   ├── Scene_02_Tutorial.tscn
│   │   │   └── scene_02_tutorial.gd
│   │   └── 📂 scene_04_investigation_intro/     # [Scene 4] ห้องนอน & มือถือ (คุยพี่มาร์ช -> วางเต่าดำ -> หยิบแฟลชไดรฟ์ไปทำ Image ที่ PC -> เปิดเต่าดำ)
│   │       ├── Scene_04_Investigation_Intro.tscn
│   │       └── scene_04_investigation_intro.gd
│   │
│   ├── 📂 scene_03_incident/                    # [Scene 3] เครื่อง PC ของเมย์ (โหลดไฟล์งานกลุ่ม + พิมพ์งาน Typing Game + Cutscene ติด Ransomware)
│   │   ├── Scene_03_Incident.tscn
│   │   ├── Scene_03_Incident.gd
│   │   └── background.gd
│   │
│   ├── 📂 scene_05_taodam_desktop/              # [Scene 5] โน้ตบุ๊กเต่าดำ (ตรวจสอบคุณสมบัติการ Isolate 4 ข้อด้วย Checklist_UI)
│   │   ├── Scene_05_TaoDam_Desktop.tscn
│   │   └── Scene_05_TaoDam_Desktop.gd
│   │
│   ├── 📂 scene_06_taodam_investigation/        # [Scene 6] โน้ตบุ๊กเต่าดำ (เสียบ EV-DRIVE สืบสวนหลักฐานครบ 6 ขั้นตอน: Hash -> EventLog -> DriveLog -> Macro -> Decode -> StopTask)
│   │   ├── Scene_06_TaoDam_Investigation.tscn
│   │   └── Scene_06_TaoDam_Investigation.gd
│   │
│   └── 📂 scene_07_recovery/                    # [Scene 7] เครื่อง PC ของเมย์ (กู้คืน 3-2-1 Backup -> ทำรายงานสรุปเหตุการณ์ -> ประเมินผล KSA)
│       ├── Scene_07_Recovery.tscn
│       └── Scene_07_Recovery.gd
│
├── 📂 ui/                                       # ระบบ User Interface ทั้งหมด
│   ├── 📂 menus/                                # เมนูหลักและหน้าต่างตั้งค่า
│   │   ├── MainMenu.tscn / Main_menu.gd
│   │   ├── FloatMenu.tscn / float_menu.gd
│   │   ├── SettingsModal.tscn / settings_modal.gd
│   │   └── ContinueModal.tscn / continue_modal.gd
│   │
│   ├── 📂 base_classes/                         # Abstract Base Classes ของ UI
│   │   ├── BaseOverlayUI.gd
│   │   ├── BaseOSWindow.gd
│   │   └── BasePuzzleUI.gd
│   │
│   ├── 📂 overlays/                             # UI ลอยหน้าจอ
│   │   ├── Checklist_UI.tscn / checklist_ui.gd  # [Scene 5 - T05] เช็คเงื่อนไขการ Isolate เต่าดำ
│   │   ├── KSA_Evaluation_UI.tscn               # [Scene 7 - T15] สรุปคะแนน K-S-A
│   │   └── inventory_bar.tscn / inventory_bar.gd
│   │
│   ├── 📂 os_simulation/                        # ระบบจำลอง OS (PC ของเมย์, เต่าดำ, และมือถือ)
│   │   ├── desktop_screen.tscn / desktop_screen.gd
│   │   ├── notebook_screen.tscn                 # 🔒 STRICTLY LOCKED (ห้ามแก้ไขไฟล์นี้โดยตรง)
│   │   ├── phone_panel.tscn / phone_panel.gd    # มือถือใน Scene 2 (คุยกับเมษา)
│   │   ├── phone_panel_investigation.tscn / phone_panel_investigation.gd # มือถือใน Scene 4 (คุยกับพี่มาร์ช)
│   │   └── 📂 Application/
│   │       ├── gg_disk.tscn / gg_disk.gd
│   │       ├── downloaded_folder.tscn / downloaded_folder.gd
│   │       ├── ms_word.tscn / ms_word.gd
│   │       ├── discord_app.tscn / discord_app.gd
│   │       ├── ev_folder.tscn / ev_folder.gd
│   │       ├── inspector_app.tscn / inspector_app.gd
│   │       └── decoder_app.tscn / decoder_app.gd
│   │
│   └── 📂 puzzles/                              # ปริศนาและมินิเกมทั้งหมด (สืบทอดจาก BasePuzzleUI)
│       ├── BaseClickSelectPuzzle.gd
│       ├── BaseDecoderPuzzle.gd
│       ├── BaseSequencePuzzle.gd
│       ├── BaseFormPuzzle.gd
│       ├── Puzzle_Typing_Game.tscn / typing_game.gd                 # [Scene 3 - T04]
│       ├── Puzzle_Hash_Verify.tscn / hash_verify_puzzle.gd          # [Scene 6 - T08]
│       ├── Puzzle_Event_Log.tscn / event_log_puzzle.gd              # [Scene 6 - T06]
│       ├── Puzzle_Drive_History.tscn / drive_history_puzzle.gd      # [Scene 6 - T07]
│       ├── Puzzle_File_Structure.tscn / macro_structure_puzzle.gd   # [Scene 6 - T09]
│       ├── Puzzle_Decoder.tscn / decoder_puzzle.gd                  # [Scene 6 - T10, T11]
│       ├── Puzzle_Persistence_Order.tscn / persistence_order_puzzle.gd # [Scene 6 - T12]
│       ├── Puzzle_321_Backup.tscn / backup_recovery_puzzle.gd       # [Scene 7 - T13]
│       ├── Puzzle_Last_Boss_Summary.tscn / incident_report_puzzle.gd # [Scene 7 - T14]
│       └── ksa_evaluation.gd                                        # [Scene 7 - T15]
│
└── 📂 assets/                                   # ไฟล์ฟอนต์ รูปภาพ ไอคอน และเสียงประกอบ
```
