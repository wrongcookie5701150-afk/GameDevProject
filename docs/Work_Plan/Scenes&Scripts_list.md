# Scene & Node Functions

### **Scene 1: Intro Cutscene (19.02 น.)**
ฉาก Cutscene เปิดเรื่อง เมย์นอนฟังเพลงแล้วมีสายเรียกเข้าจากเมษาโทรมาทวงงาน

- **Scene & Nodes ที่ต้องสร้าง:**
  - `Scene_01_Intro.tscn` (ฉาก Cutscene เมย์นอนฟังเพลง)
  - `Incoming_Call_UI.tscn` (หน้าต่าง UI สายเรียกเข้าจำลอง)
  - `Dialogue_Box.tscn` (กล่องข้อความบทสนทนา)
- **ฟังก์ชัน GDScript ที่ต้องสร้าง:**
  - `play_intro_audio()`: เล่นเสียงดนตรี/บรรยากาศ
  - `show_call_popup(caller_name: String)`: แสดง UI สายเรียกเข้าของเมษา
  - `start_dialogue(dialogue_id: String)`: เล่นบทสนทนาทางโทรศัพท์
  - `finish_cutscene()`: สลับฉากเข้าสู่ Scene 2 Tutorial

---

### **Scene 2: Game Tutorial & Workstation (ฉากฝึกสอนและพิมพ์งาน)**
ฉากเมย์ยืนข้างเตียง ฝึกควบคุมตัวละคร เปิดมือถือดูแชต เดินไปโต๊ะคอม และพิมพ์รายงาน

- **Scene & Nodes ที่ต้องสร้าง:**
  - `Scene_02_Tutorial.tscn` (ฉากห้องพัก 2D TileMap/YSort)
  - `Player.tscn` (ตัวละครเมย์ มี CollisionShape2D และ Area2D)
  - `Phone_UI.tscn` (หน้าจอมือถือจำลอง - กด `[P]` หรือคลิก Notification เพื่ออ่านแชต)
  - `Desktop_Main_PC.tscn` (หน้าจอคอมหลัก: GG Disk, Text Editor, Recycle Bin, Settings)
  - `Puzzle_Typing_Game.tscn` (มินิเกมจำลองการพิมพ์งาน 300 คำ)
- **ฟังก์ชัน GDScript ที่ต้องสร้าง:**
  - `move(direction: Vector2)`: ควบคุมการเคลื่อนที่ 4 ทิศทาง (W, A, S, D)
  - `interact()`: กด Spacebar โต้ตอบกับโต๊ะคอมพิวเตอร์
  - `toggle_phone()` / `read_message(msg_id: String)`: เปิดมือถืออ่านแชตเมษา (Task 1)
  - `open_cloud_file(file_name: String)`: เปิดไฟล์ใน GG Disk และกด Enable Content (Task 3)
  - `process_typing_input(key_char: String) -> bool`: รับค่าการพิมพ์และนับคำจนครบ 300 คำ (Task 4)
  - `calculate_typing_wpm() -> float`: คำนวณความเร็ว WPM และ Accuracy เพื่อส่งให้ Telemetry

---

### **Scene 3: Ransomware Incident Cutscene (21.23 น.)**
ฉาก Cutscene เกิดแจ้งเตือนขยะ/อัปเดตปลอม ไฟล์งานกลายเป็นนามสกุล `.locked` และขึ้นข้อความข่มขู่

- **Scene & Nodes ที่ต้องสร้าง:**
  - `Scene_03_Incident.tscn` (ฉาก Cutscene เหตุการณ์ติดมัลแวร์)
  - `Folder_View_UI.tscn` (หน้าต่างโฟลเดอร์ไฟล์งานกลุ่ม 4 ไฟล์)
  - `Ransom_Note_UI.tscn` (หน้าต่างไฟล์ `README_TO_RECOVER_FILES.txt`)
- **ฟังก์ชัน GDScript ที่ต้องสร้าง:**
  - `play_timelapse_popups()`: แสดงป๊อปอัปแจ้งเตือนขยะและอัปเดตโปรแกรมปลอม
  - `corrupt_files_visual()`: เปลี่ยนสีโฟลเดอร์เป็นสีเทา และเปลี่ยนนามสกุลไฟล์ทั้ง 4 เป็น `.locked`
  - `display_ransom_note()`: แสดงหน้าต่างข้อความเรียกค่าไถ่และล็อกการใช้งานเครื่อง

---

### **Scene 4: Investigation Intro & Triage (เข้าสู่วิถีไซเบอร์)**
ฉากแชต/โทรคุยกับมาร์ช ตรวจสอบเครื่องเต่าดำ (Isolated Environment) อ่าน Event Log และตรวจ Drive History

- **Scene & Nodes ที่ต้องสร้าง:**
  - `Scene_04_Investigation_Intro.tscn`
  - `Phone_Chat_UI.tscn` (หน้าต่างคุยแชตและรับสายโทรศัพท์จากมาร์ช)
  - `Checklist_UI.tscn` (Task 5: เช็กสภาพเครื่องเต่าดำ ปิด Wi-Fi, ถอดสาย LAN, ไม่มีบัญชีส่วนตัว)
  - `Puzzle_Event_Log.tscn` (Task 6 / Puzzle 2: ตรวจ Windows Event Log และคลิก Timeline `19:02:10`)
  - `Puzzle_Drive_History.tscn` (Task 7 / Puzzle 1: ตรวจ Drive History จับผิดโดเมนปลอม `universcity.example`)
- **ฟังก์ชัน GDScript ที่ต้องสร้าง:**
  - `validate_isolated_env(checklist: Dictionary) -> bool`: ตรวจความพร้อมของเต่าดำ (Task 5)
  - `select_event_log_entry(timestamp: String) -> bool`: ตรวจสอบการเลือก Timeline `19:02:10` (Task 6)
  - `check_typosquatting(sender_email: String) -> bool`: ตรวจจับอีเมลปลอมบน GG Disk (Task 7)
  - `pickup_ev_drive()`: ให้ผู้เล่นเดินไปเก็บ EV Drive จากชั้นหนังสือมาเสียบทำ Forensic Copy

---

### **Scene 5: Forensic Lab (วิเคราะห์หลักฐานบนเต่าดำ)**
ฉากวิเคราะห์ไฟล์ใน EV Drive ด้วยโปรแกรมบนเต่าดำ (FTK Imager, olevba, Decoder, Inspector)

- **Scene & Nodes ที่ต้องสร้าง:**
  - `Scene_05_TaoDam_Desktop.tscn` (เดสก์ท็อปจำลองเครื่องเต่าดำ)
  - `Puzzle_Hash_Verify.tscn` (Task 8 / Puzzle 3: ตรวจสอบและเปรียบเทียบค่า MD5 Hash กับ Manifest)
  - `Puzzle_File_Structure.tscn` (Task 9-10 / Puzzle 4: ตรวจพบ `vbaProject.bin` และจับคู่ไฟล์)
  - `Puzzle_Decoder.tscn` (Task 11, 13 / Puzzle 5-6: ถอดรหัส Base64 และ Hex ใน Helper.dat)
  - `Puzzle_Persistence_Order.tscn` (Task 14 / Puzzle 7: เรียงลำดับ 7 ขั้นตอนตัดวงจร Persistence)
- **ฟังก์ชัน GDScript ที่ต้องสร้าง:**
  - `verify_evidence_hashes(input_hash: String, manifest_hash: String) -> bool`: ยืนยันความสมบูรณ์ไฟล์ (Task 8)
  - `inspect_macro_content(file_path: String)`: แสดงโครงสร้างไฟล์ Word Macro ที่มี `vbaProject.bin` (Task 9-10)
  - `decode_payload(encoded_str: String, codec: String) -> String`: ถอดรหัส Base64 และ Hex (Task 11, 13)
  - `submit_persistence_steps(player_sequence: Array) -> bool`: ตรวจการเรียงลำดับ 7 ขั้นตอนหยุดภัยคุกคาม (Task 14)

---

### **Scene 6: Recovery & Conclusion (กำจัดภัยคุกคามและกู้คืนข้อมูล)**
ฉากกู้คืนข้อมูลตามกฎ 3-2-1 Backup และทำมินิเกมเติมคำสรุปบทเรียน (The Last Boss) พร้อมสรุปผล K-S-A

- **Scene & Nodes ที่ต้องสร้าง:**
  - `Scene_06_Recovery.tscn`
  - `Puzzle_321_Backup.tscn` (Task 15 / Puzzle 8: เลือก Recovery Point ก่อน 19:02, โฟลเดอร์ใหม่, ปิด Cloud Sync)
  - `Puzzle_Last_Boss_Summary.tscn` (Task 16: เติมคำสรุปบทเรียน 3-4 ข้อลงในรายงาน)
  - `KSA_Evaluation_UI.tscn` (หน้าต่างแสดงผลคะแนนและผลการเรียนรู้ K-S-A)
- **ฟังก์ชัน GDScript ที่ต้องสร้าง:**
  - `validate_recovery_options(recovery_point, dest, sync_state) -> bool`: ตรวจสอบการกู้คืนตามกฎ 3-2-1 (Task 15)
  - `submit_final_report_answers(answers: Array) -> bool`: ตรวจคำตอบเติมคำสรุปบทเรียน (Task 16)
  - `display_evaluation_report()`: แสดงผลรายงานสรุปการสืบสวนและคะแนน K-S-A

---

### **Global Systems / Autoload (`TelemetryManager.gd`)**
ระบบตัวกลางเชื่อมต่อระหว่าง Scene ย่อยกับระบบ Analytics Backend (FastAPI):

- **ฟังก์ชันและระบบ:**
  - `start_task_timer(task_id: String)`: เริ่มจับเวลาเมื่อเข้าสู่ Puzzle/Task
  - `stop_task_timer(task_id: String) -> float`: หยุดจับเวลาและคืนค่าเป็นวินาที
  - `track_event(scene_id, task_id, event_type, duration_seconds, is_correct, attempt_count, hint_used, metrics)`: ส่ง Event และพารามิเตอร์เฉพาะของแต่ละ Task ไปยัง Backend
  - `_on_http_request_completed(...)`: รับค่าตอบกลับจาก FastAPI (`assigned_cluster`, `adaptive_hint_enabled`, `difficulty_multiplier`)
  - `adaptive_gameplay_updated (Signal)`: ส่งสัญญาณปรับ Dynamic Gameplay ไปยังแต่ละ Scene