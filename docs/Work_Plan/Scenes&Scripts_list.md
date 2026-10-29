# Scene & Script Structure (7-Scene Linear Flow)

เอกสารนี้สรุปลำดับฉากทั้ง 7 ซีนของเกมที่จัดระเบียบใหม่ โดยแยกฉากเดินสำรวจในห้องนอนและโทรศัพท์มือถือ (`Bedroom & Phone`) ออกจากฉากหน้าจอคอมพิวเตอร์ของเมย์ (`PC / DesktopScreen`) และฉากโน้ตบุ๊กเต่าดำ (`TaoDam / NotebookScreen`) อย่างชัดเจน

---

### **Scene 1: Intro Cutscene (`res://scenes/scene_01_intro/Scene_01_Intro.tscn`)**
ฉาก Cutscene เปิดเรื่องเวลา 19:02 น. เมย์อยู่ในห้องนอนและมีสายเรียกเข้าจากเมษาโทรมาทวงงานรายงานกลุ่ม

- **ไฟล์หลัก:**
  - `Scene_01_Intro.tscn`
  - `cutscene_01_intro.gd`
- **การทำงานหลัก:**
  - แสดงบทสนทนาสายเรียกเข้าจากเมษา
  - เมื่อจบบทสนทนา (หรือกด Skip) จะเปลี่ยนฉากไปยัง `Scene_02_Tutorial.tscn`

---

### **Scene 2: Bedroom & Phone Tutorial (`res://scenes/world_scenes/scene_02_tutorial/Scene_02_Tutorial.tscn`)**
ฉากห้องนอนฝึกเดิน (`WASD`) และเปิดมือถืออ่านข้อความจากเมษา ก่อนเดินไปเปิดเครื่องคอมพิวเตอร์ PC

- **ไฟล์หลัก:**
  - `Scene_02_Tutorial.tscn` (สืบทอดจาก `BaseWorldScene.gd`)
  - `scene_02_tutorial.gd`
  - `Playground` (`res://scenes/initial/playground.tscn`)
  - `PhonePanel` (`res://ui/os_simulation/phone_panel.tscn` + `phone_panel.gd`)
- **ลำดับการเล่น:**
  1. กด `[P]` (หรือปุ่มมุมขวาล่าง) เพื่อเปิดมือถืออ่านข้อความจากเมษา (`T01`)
  2. เดินไปที่โต๊ะคอมพิวเตอร์ (`computer` / `desktop`) แล้วกด `[Spacebar]` (`T02`) -> เปลี่ยนฉากเข้าสู่ **Scene 3 (`Scene_03_Incident.tscn`)**

---

### **Scene 3: May's PC — Typing Game & Ransomware Incident (`res://scenes/scene_03_incident/Scene_03_Incident.tscn`)**
ฉากหน้าจอเดสก์ท็อปจำลองบนเครื่อง PC ของเมย์ รวมตั้งแต่การดาวน์โหลดไฟล์งานกลุ่ม พิมพ์รายงาน จนถึงเหตุการณ์ติดมัลแวร์

- **ไฟล์หลัก:**
  - `Scene_03_Incident.tscn` (สืบทอดโครงสร้างจาก `desktop_screen.tscn`)
  - `Scene_03_Incident.gd` (สืบทอดจาก `DesktopScreenController` ใน `desktop_screen.gd`)
  - `Puzzle_Typing_Game.tscn` (`typing_game.gd` ภายในหน้าต่าง `MsWord`)
- **ลำดับการเล่น:**
  1. **Phase A (Interactive PC)**:
     - เปิดแอป `GG Disk` บนหน้าจอแล้วกดดาวน์โหลดโฟลเดอร์ `งานกลุ่ม` ลง Desktop
     - เปิดโฟลเดอร์ `งานกลุ่ม` (`DownloadedFolder`) แล้วคลิกเปิดไฟล์ `Report.docx`
     - หน้าต่าง `MsWord` เปิดขึ้นมาพร้อมแถบเตือน Macro สีเหลือง -> กดปุ่ม `Enable` (`T03`)
     - เล่นมินิเกมพิมพ์รายงาน `Puzzle_Typing_Game` (`T04` / `P00`) จนเสร็จ
  2. **Phase B (Incident Cutscene)**:
     - เมื่อพิมพ์เสร็จ ระบบเข้าสู่โหมด Timelapse (`19:30` -> `21:23`) ไหลข้อความรายงานพร้อมป๊อปอัปแจ้งเตือน (`Office_Update_Helper`, `CloudSync`) และมีปุ่ม `⏩ Skip Cutscene`
     - เมื่อพิมพ์ครบ ระบบให้ผู้เล่นกดปุ่ม `Save` บนหน้าต่าง Word
     - เกิดเอฟเฟกต์หน้าจอกระพริบสีแดง (`GlitchOverlay`) ไฟล์ทั้ง 4 ในโฟลเดอร์งานกลุ่มกลายเป็นนามสกุล `.locked` และเด้งหน้าต่าง `RansomNote` (`README_TO_RECOVER_FILES.txt`)
     - ปิดหน้าต่างข่มขู่ -> เด้งแจ้งเตือน Discord จากพี่มาร์ช -> กดปุ่ม `ออก (Exit)` ที่มุมขวาล่างของ Taskbar เพื่อลุกออกจากคอมไปยัง **Scene 4 (`Scene_04_Investigation_Intro.tscn`)**

---

### **Scene 4: Bedroom & Phone — Prep TaoDam & Forensic Image (`res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn`)**
ฉากห้องนอนหลังเกิดเหตุ เมย์คุยโทรศัพท์ขอคำแนะนำจากพี่มาร์ช เตรียมเครื่องเต่าดำ และนำแฟลชไดรฟ์ไปทำ Forensic Image

- **ไฟล์หลัก:**
  - `Scene_04_Investigation_Intro.tscn` (สืบทอดจาก `BaseWorldScene.gd`)
  - `scene_04_investigation_intro.gd`
  - `PhonePanel` (`res://ui/os_simulation/phone_panel_investigation.tscn` + `phone_panel_investigation.gd`)
  - `EVDrivePanel` (หน้าต่างแจ้งผลการสร้าง Forensic Image ลงแฟลชไดรฟ์)
- **ลำดับการเล่น:**
  1. กด `[P]` เปิดมือถือคุยแชทและรับสายพี่มาร์ชจนจบ (`march_chat_completed`)
  2. เดินไปสำรวจ/วางโน้ตบุ๊ก **เต่าดำ (`taodam`)** บนโต๊ะ และเดินไปที่ชั้นหนังสือเพื่อกด `[Spacebar]` หยิบแฟลชไดรฟ์ **`EV-DRIVE`** เข้ากระเป๋า (`InventoryManager`)
  3. นำแฟลชไดรฟ์ไปที่เครื่อง PC ของเมย์ (`computer` / `desktop`) แล้วกด `[Spacebar]` เพื่อสร้าง **Forensic Image** (คัดลอก `Report_Final.docx`, `Windows_Event_Log.txt`, `Drive_Activity.log`, และ `Evidence_Manifest.txt` ลง `EV-DRIVE`)
  4. เดินไปที่โน้ตบุ๊ก **เต่าดำ (`taodam`)** บนโต๊ะแล้วกด `[Spacebar]` -> เปลี่ยนฉากเข้าสู่ **Scene 5 (`Scene_05_TaoDam_Desktop.tscn`)**

---

### **Scene 5: TaoDam Notebook — Isolation Verification (`res://scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn`)**
ฉากหน้าจอโน้ตบุ๊กเต่าดำ เพื่อตรวจสอบคุณสมบัติการแยกตัวจากเครือข่าย (Isolation Check) ก่อนเสียบแฟลชไดรฟ์หลักฐาน

- **ไฟล์หลัก:**
  - `Scene_05_TaoDam_Desktop.tscn`
  - `Scene_05_TaoDam_Desktop.gd`
  - `NotebookScreen` (`res://ui/os_simulation/notebook_screen.tscn` — *ไฟล์ล็อก ห้ามแก้ไขโดยตรง*)
  - `Checklist_UI.tscn` (`checklist_ui.gd` — `T05`)
  - `AppLoginWindow` และ `FileExplorerWindow` (หน้าต่างย่อยตรวจสอบสถานะบัญชีและไฟล์ในเครื่อง)
- **ลำดับการเล่น:**
  1. คลิกปุ่ม `Wi-Fi` มุมขวาล่างบน Taskbar ของเต่าดำเพื่อตัดการเชื่อมต่อ Wi-Fi และสาย LAN (`wifi_disabled`, `lan_unplugged`)
  2. กดปุ่ม `Start` -> เปิด `Discord` หรือ `GG Disk` เพื่อตรวจยืนยันว่าไม่มีบัญชีส่วนตัวล็อกอินค้างไว้ (`personal_accounts_unlinked`)
  3. กดปุ่ม `Start` -> เปิด `Files` เพื่อตรวจยืนยันว่าไม่มีไฟล์งานสำคัญอยู่ในเครื่องเต่าดำ (`no_important_files`)
  4. เมื่อครบทั้ง 4 ข้อ หน้าต่าง `CompletionPanel` จะปรากฏขึ้น -> กดปุ่มเพื่อเสียบแฟลชไดรฟ์ `EV-DRIVE` และเข้าสู่ **Scene 6 (`Scene_06_TaoDam_Investigation.tscn`)**

---

### **Scene 6: TaoDam Notebook — Full Forensic Investigation (`res://scenes/scene_06_taodam_investigation/Scene_06_TaoDam_Investigation.tscn`)**
ฉากสืบสวนหลักฐานเชิงลึกบนโน้ตบุ๊กเต่าดำหลังเสียบแฟลชไดรฟ์ `EV-DRIVE (E:)` พร้อมแถบเครื่องมือ `ForensicToolbar`

- **ไฟล์หลัก:**
  - `Scene_06_TaoDam_Investigation.tscn`
  - `Scene_06_TaoDam_Investigation.gd`
  - แอปจำลองบนเต่าดำ: `EvFolder` (`ev_folder.gd`), `InspectorApp` (`inspector_app.gd`), `DecoderApp` (`decoder_app.gd`)
- **ลำดับการสืบสวน 6 ขั้นตอน (เรียงตามปุ่มบน `ForensicToolbar`):**
  1. **`1.Hash(T08)` (`Puzzle_Hash_Verify.tscn`)**: เลือกไฟล์หลักฐานเพื่อคำนวณและเทียบค่า MD5 Hash กับ `Evidence_Manifest.txt`
  2. **`2.EventLog(T06)` (`Puzzle_Event_Log.tscn`)**: เปิดอ่าน `Windows_Event_Log.txt` ที่อิมเมจมาในแฟลชไดรฟ์ แล้วคลิกเลือกเวลาที่ `WINWORD.EXE` เปิดไฟล์ `Report_Final.docx` (`19:02:10`)
  3. **`3.DriveLog(T07)` (`Puzzle_Drive_History.tscn`)**: ตรวจ `Drive_Activity.log` เพื่อหาผู้ส่งที่ปลอมแปลงโดเมน (`mesasohot.sukj@universcity.example`)
  4. **`4.Macro(T09)` (`Puzzle_File_Structure.tscn`)**: ใช้เครื่องมือ `olevba` ตรวจโครงสร้างไฟล์ `.docx` และระบุโค้ดฝังตัว `word/vbaProject.bin`
  5. **`5.Decode(T10-11)` (`Puzzle_Decoder.tscn`)**: ถอดรหัส Base64 ได้ชื่อไฟล์ `Office_Update_Helper` (`T10`) และถอดรหัส Hex ซ้อน Base64 ได้โหมดทำลายไฟล์ `FILE_WIPE` (`T11`)
  6. **`6.StopTask(T12)` (`Puzzle_Persistence_Order.tscn`)**: เรียงลำดับขั้นตอนการหยุด Persistence และ Scheduled Task ทั้ง 7 ขั้นตอนอย่างปลอดภัย
  - เมื่อครบทั้ง 6 ขั้นตอน หน้าต่างสรุปผลการสืบสวนจะแสดงขึ้น -> กดปุ่มเพื่อกลับไปยังเครื่อง PC ของเมย์ใน **Scene 7 (`Scene_07_Recovery.tscn`)**

---

### **Scene 7: May's PC — 3-2-1 Backup Recovery, Final Report & KSA (`res://scenes/scene_07_recovery/Scene_07_Recovery.tscn`)**
ฉากกลับมาที่หน้าจอเครื่อง PC ของเมย์ เพื่อกู้คืนข้อมูลจาก Backup ให้ถูกเวลา นั่งทำรายงานสรุปส่งอาจารย์ และรับผลประเมิน K-S-A

- **ไฟล์หลัก:**
  - `Scene_07_Recovery.tscn`
  - `Scene_07_Recovery.gd`
  - `DesktopScreen` (`res://ui/os_simulation/desktop_screen.tscn`)
  - `Puzzle_321_Backup.tscn` (`backup_recovery_puzzle.gd` — `T13`)
  - `Puzzle_Last_Boss_Summary.tscn` (`incident_report_puzzle.gd` — `T14`)
  - `KSA_Evaluation_UI.tscn` (`ksa_evaluation.gd` — `T15`)
- **ลำดับการเล่น:**
  1. **กู้คืนข้อมูล (`Puzzle_321_Backup` - `T13`)**: เลือก Version History ก่อนเกิดเหตุ (`18:55 (verified clean point)` ก่อนเวลา `19:02`), เลือกปลายทางแยกต่างหาก (`Separate external recovery drive`), และปิด Cloud Sync ระหว่างกู้คืน (`Disable cloud sync during restoration`)
  2. **ทำรายงานสรุป (`Puzzle_Last_Boss_Summary` - `T14`)**: สรุปช่องทางโจมตีเริ่มต้น (`Macro-enabled Word document`), ชนิดมัลแวร์ (`Ransomware / wiper`), และวิธีรับมือ (`Isolated the affected network`)
  3. **สรุปผลคะแนน (`KSA_Evaluation_UI` - `T15`)**: แสดงคะแนน Knowledge, Skills, Attitude และสถิติการทำภารกิจ -> กดยืนยันเพื่อกลับสู่หน้า `MainMenu.tscn`
