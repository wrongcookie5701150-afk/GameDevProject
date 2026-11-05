# แผนงานพัฒนาฟีเจอร์เพิ่มเติมเพื่อให้สอดคล้องกับบทคัดย่อ (Abstract Alignment Plan)

เอกสารนี้สรุปโครงสร้างและรายการงานที่ต้องพัฒนาเพิ่มเติมในโปรเจกต์ **CyberSecurityGame** เพื่อให้ระบบเกม เนื้อหาทั้ง 4 สถานการณ์ (Scenarios) ระบบช่วยเหลือตามระดับทักษะ (In-game Scaffolding) ระบบบันทึกพฤติกรรม (Game Logs) และระบบประเมินผลในเกม (In-game Assessment) สอดคล้องกับกรอบแนวคิดในบทคัดย่ออย่างสมบูรณ์

---

## 1. สาระสำคัญจากบทคัดย่อ (Key Requirements from Abstract)

* **ชื่อเรื่อง**: *Developing Cyber Threat Prevention Ability through a Scenario-Based Cybersecurity Game for Undergraduate Students*
* **แนวคิดหลัก**: เกมซีเรียส (Serious Game) บน **Godot Engine** ที่บูรณาการการเรียนรู้โดยใช้สถานการณ์เป็นฐาน (**Scenario-Based Learning**) เพื่อพัฒนาความสามารถในการป้องกันภัยคุกคามไซเบอร์ (โดยเฉพาะ **Ransomware**) สำหรับนักศึกษาระดับปริญญาตรี
* **บทบาทผู้เล่น**: นักศึกษาที่ต้องเผชิญกับเหตุการณ์โจมตีด้วยแรนซัมแวร์ ต้องวิเคราะห์สถานการณ์และแก้ปัญหาทางไซเบอร์ โดยมี **ระบบช่วยเหลือในเกมที่ปรับตามระดับทักษะ (In-game scaffolding tailored to their skill levels)**
* **โครงสร้าง 4 สถานการณ์ (4 Core Scenarios)**:
  1. **Scenario 1**: การเตรียมสภาพแวดล้อมคอมพิวเตอร์เพื่อสืบสวนและระบุสาเหตุของภัยคุกคาม (*Prepare the computer environment to investigate and identify the cause of the threat*)
  2. **Scenario 2**: การสืบสวนทางนิติวิทยาศาสตร์ดิจิทัล โดยค้นหาต้นตอของปัญหาจากการตรวจสอบหลักฐานดิจิทัล เช่น Windows Event Logs และประวัติการใช้งานไดรฟ์ (*Forensic investigation: uncover the root problem by examining digital evidence such as Windows Event Logs and drive history*)
  3. **Scenario 3**: การเลือกและทดสอบวิธีแก้ปัญหาผ่านการลองผิดลองถูกจนกว่าจะแก้ไขปัญหาได้สำเร็จ (*Select and test solutions through trial and error until the issue is resolved*)
  4. **Scenario 4**: การสรุปองค์ความรู้สำคัญ (*Summarizes the key knowledge*) และการประเมินทักษะในเกม (*In-game assessment of cyber threat prevention skills focusing on ransomware*)
* **เครื่องมือเก็บข้อมูลและวัดผล (Research Instruments & Behavioral Tracking)**:
  * **Game Logs จากแต่ละ Scenario**: บันทึกพฤติกรรมการตัดสินใจของผู้เล่น (*Decision-making behaviors*) โดยแสดง **เวลาที่ใช้ในการวิเคราะห์ (Time spent on analysis)** และ **เวลาที่ใช้ในการตัดสินใจ (Time spent on decision-making)**
  * **In-game Assessment**: แบบประเมินทักษะการป้องกันภัยคุกคามไซเบอร์ที่มุ่งเน้นเรื่องแรนซัมแวร์ การวิเคราะห์สาเหตุ และการแก้ปัญหาในตัวเกม

---

## 2. การจับคู่ 4 Scenarios เข้ากับโครงสร้าง 7 Scenes ปัจจุบัน

| Scenario ในบทคัดย่อ | เป้าหมายการเรียนรู้ | ฉากในโปรเจกต์ปัจจุบัน (`game_client/scenes/`) | ภารกิจ / ปริศนาที่เกี่ยวข้อง (`Task ID`) |
| :--- | :--- | :--- | :--- |
| **Scenario 1**<br>Environment Preparation & Threat Identification | เผชิญเหตุแรนซัมแวร์ เตรียมสภาพแวดล้อมการสืบสวน ทำสำเนาหลักฐาน (Forensic Image) และตรวจสอบการแยกเครื่อง (Isolation) | - `Scene_01_Intro.tscn`<br>- `Scene_02_Tutorial.tscn`<br>- `Scene_03_Incident.tscn`<br>- `Scene_04_Investigation_Intro.tscn`<br>- `Scene_05_TaoDam_Desktop.tscn` | `T01` อ่านแชทแจ้งงาน<br>`T02` เข้าใช้งานคอมพิวเตอร์<br>`T03`–`T04` เหตุการณ์ติด Ransomware จาก Macro<br>`T05` ตรวจสอบการ Isolate โน้ตบุ๊กเต่าดำ (`Checklist_UI.tscn`) |
| **Scenario 2**<br>Digital Forensics Investigation | สืบสวนหาสาเหตุที่แท้จริงของแรนซัมแวร์จากหลักฐานดิจิทัล (`Windows Event Logs`, `Drive History`, ค่า Hash, โครงสร้างไฟล์ Macro และการถอดรหัส Payload) | - `Scene_06_TaoDam_Investigation.tscn` (ส่วนการตรวจพิสูจน์หลักฐานผ่าน `InspectorApp`, `EvFolder`, `DecoderApp`) | `T08` ตรวจสอบความถูกต้องของหลักฐาน (`Puzzle_Hash_Verify.tscn`)<br>`T06` วิเคราะห์ `Windows_Event_Log.txt` (`Puzzle_Event_Log.tscn`)<br>`T07` วิเคราะห์ `Drive_Activity.log` (`Puzzle_Drive_History.tscn`)<br>`T09` ตรวจโครงสร้าง Macro (`Puzzle_File_Structure.tscn`)<br>`T10`–`T11` ถอดรหัสชื่อโปรเซสและโหมดทำลายไฟล์ (`Puzzle_Decoder.tscn`) |
| **Scenario 3**<br>Trial-and-Error Solution Testing & Recovery | เลือกและทดสอบขั้นตอนการยับยั้งการฝังตัวของมัลแวร์ (Persistence) และทดสอบการกู้คืนข้อมูลจากระบบสำรองข้อมูลจนสำเร็จ | - `Scene_06_TaoDam_Investigation.tscn` (ส่วนการวางแผนหยุด Persistence)<br>- `Scene_07_Recovery.tscn` (ส่วนการกู้คืนข้อมูลสำรอง) | `T12` เรียงลำดับขั้นตอนหยุด Persistence (`Puzzle_Persistence_Order.tscn`)<br>`T13` ทดสอบการตั้งค่ากู้คืนข้อมูลสำรอง 3-2-1 (`Puzzle_321_Backup.tscn`) |
| **Scenario 4**<br>Key Knowledge Summary & In-Game Assessment | สรุปองค์ความรู้สำคัญจากการสืบสวนและประเมินความสามารถในการป้องกันภัยคุกคามแรนซัมแวร์ | - `Scene_07_Recovery.tscn` (ส่วนสรุปรายงานและประเมินผล) | `T14` สรุปรายงานอุบัติการณ์ (`Puzzle_Last_Boss_Summary.tscn`)<br>`T15` ประเมินทักษะ KSA และสรุปบทเรียน (`KSA_Evaluation_UI.tscn`) |

---

## 3. รายการงานที่ต้องพัฒนาเพิ่ม (Tasks to Add & Enhance)

### งานส่วนที่ 1: ระบบช่วยเหลือในเกมที่ปรับตามระดับทักษะ (Adaptive In-Game Scaffolding)

> **อ้างอิงบทคัดย่อ**: *"supported by in-game scaffolding tailored to their skill levels"*

**สถานะปัจจุบัน**:
* `TelemetryManager.gd` และ `backend_api/main.py` มีการจำแนกกลุ่มผู้เล่น (`current_player_cluster`: `"Beginner"` / `"Expert"`) และตัวแปร `is_adaptive_hint_enabled` แล้ว
* แต่ `BasePuzzleUI.gd` และหน้าต่างปริศนาส่วนใหญ่ยังไม่ได้นำค่าดังกล่าวมาปรับระดับคำใบ้อัตโนมัติ และบางปริศนา (`T06`, `T07`, `T12`, `T13`, `T14`) ยังไม่มีปุ่มหรือข้อความ Scaffolding

**งานที่ต้องเพิ่ม**:
- [ ] **1.1 พัฒนาระบบคำใบ้ 3 ระดับ (3-Tier Adaptive Scaffolding) ใน `BasePuzzleUI.gd`**:
  - **Tier 1 (Nudge / ชี้จุดสังเกต)**: แสดงคำแนะนำเบื้องต้นเมื่อผู้เล่นใช้เวลาวิเคราะห์นานเกินเกณฑ์ (`hint_delay_seconds`) หรือตอบผิดครั้งที่ 1
  - **Tier 2 (Analytical Guidance / แนะแนวทางการวิเคราะห์)**: อธิบายความเชื่อมโยงของหลักฐานเมื่อผู้เล่นตอบผิดครั้งที่ 2 หรือเมื่อ `TelemetryManager.is_adaptive_hint_enabled == true` (สำหรับกลุ่ม `Beginner`)
  - **Tier 3 (Explicit Scaffolding / ชี้เป้าคำตอบพร้อมเหตุผล)**: แสดงคำอธิบายทีละขั้นตอนเมื่อผู้เล่นตอบผิดตั้งแต่ 3 ครั้งขึ้นไป เพื่อให้ผู้เล่นทุกคนสามารถเรียนรู้และผ่านสถานการณ์ไปได้
- [ ] **1.2 เพิ่ม UI แสดง Scaffolding ให้ครบทุกภารกิจ**:
  - เพิ่มการแสดงคำใบ้แบบปรับระดับใน `Puzzle_Event_Log.tscn` (`T06`), `Puzzle_Drive_History.tscn` (`T07`), `Puzzle_Persistence_Order.tscn` (`T12`), `Puzzle_321_Backup.tscn` (`T13`), และ `Puzzle_Last_Boss_Summary.tscn` (`T14`)

---

### งานส่วนที่ 2: การปรับปรุงการเรียนรู้ในทั้ง 4 Scenarios ให้ครบถ้วนตามบทคัดย่อ

#### Scenario 1: การเตรียมสภาพแวดล้อมและการระบุสาเหตุเบื้องต้น (`Scene_01` – `Scene_05`)
> **อ้างอิงบทคัดย่อ**: *"In Scenario 1, players prepare the computer environment to investigate and identify the cause of the threat."*

- [ ] **2.1 เพิ่มการยืนยันขั้นตอนเตรียมสภาพแวดล้อมใน `Scene_04_Investigation_Intro.gd` และ `Scene_05_TaoDam_Desktop.gd`**:
  - แสดงแถบสถานะของ **Scenario 1** ให้ชัดเจนว่าผู้เล่นกำลังทำภารกิจ "เตรียมสภาพแวดล้อมเพื่อการสืบสวนอย่างปลอดภัย (Environment Preparation)" ได้แก่:
    1. การสำรองหลักฐานดิจิทัลลงแฟลชไดรฟ์ (`Forensic Image` บน `EV-DRIVE`)
    2. การตรวจสอบความพร้อมของเครื่องวิเคราะห์แยกส่วน (`Checklist_UI` — ตัดการเชื่อมต่อเครือข่าย, ไม่ล็อกอินบัญชี Cloud/Discord ค้างไว้, และไม่มีข้อมูลสำคัญในเครื่อง)
  - ส่งข้อมูล Telemetry เมื่อทำสำเร็จในแต่ละหัวข้อของ `Checklist_UI.tscn` (`T05`)

#### Scenario 2: การสืบสวนหลักฐานดิจิทัล (`Scene_06_TaoDam_Investigation.tscn`)
> **อ้างอิงบทคัดย่อ**: *"Scenario 2 focuses on forensic investigation, where players uncover the root problem by examining digital evidence such as Windows Event Logs and drive history."*

- [ ] **2.2 เชื่อมโยงการเปิดอ่านหลักฐานใน `InspectorApp` / `EvFolder` เข้ากับปริศนา `T06`–`T11`**:
  - บันทึกเหตุการณ์เมื่อผู้เล่นเปิดดูไฟล์หลักฐานแต่ละชิ้นใน `InspectorApp` (เช่น `Windows_Event_Log.txt`, `Drive_Activity.log`, `Report_Final.docx`, `Office_Update_Helper.dat`)
  - เพิ่มคำอธิบายประกอบใน `Puzzle_Event_Log.tscn` (`T06`) และ `Puzzle_Drive_History.tscn` (`T07`) ที่อ้างอิงข้อมูลตรงจากหน้าต่าง `InspectorApp` เพื่อกระตุ้นให้ผู้เล่นเปิดอ่านหลักฐานจริงควบคู่กับการตอบคำถาม

#### Scenario 3: การเลือกและทดสอบวิธีแก้ปัญหาแบบลองผิดลองถูก (`T12` & `T13`)
> **อ้างอิงบทคัดย่อ**: *"Scenario 3 allows players to select and test solutions through trial and error until the issue is resolved."*

- [ ] **2.3 เพิ่มระบบจำลองผลการทดสอบวิธีแก้ปัญหา (Interactive Trial-and-Error Simulation Feedback)**:
  - **ใน `Puzzle_Persistence_Order.tscn` (`T12`)**: เมื่อผู้เล่นกดทดสอบลำดับขั้นตอน (Submit) หากลำดับยังไม่ถูกต้อง ให้แสดง **"ผลการจำลองการแก้ปัญหา (Test Result)"** ตามจุดที่ผิดจริง แทนการแจ้งว่าผิดเพียงอย่างเดียว เช่น:
    - *หากกู้คืนไฟล์ (`restore_backup`) ก่อนปิด Scheduled Task (`disable_task`)*: แจ้งเตือนว่า `"ผลการทดสอบล้มเหลว: ทันทีที่กู้คืนไฟล์ โปรเซส Office_Update_Helper ที่ยังฝังตัวอยู่ใน Scheduled Task ได้ทำงานซ้ำและลบไฟล์ที่เพิ่งกู้คืนทั้งหมด!"`
    - *หากไม่เข้า Safe Mode ก่อน*: แจ้งเตือนว่า `"ผลการทดสอบล้มเหลว: โปรเซสของมัลแวร์กำลังรันอยู่เบื้องหลัง ทำให้ไม่สามารถปิดบริการหรือกักกันไฟล์ได้"`
  - **ใน `Puzzle_321_Backup.tscn` (`T13`)**: เมื่อผู้เล่นเลือกจุดเวลาสำรองข้อมูลหรือการตั้งค่า Cloud Sync แล้วกดทดสอบ ให้แสดงผลลัพธ์จำลองของแต่ละตัวเลือก เช่น:
    - *หากเลือก Backup เวลา `19:05` หรือ `19:10`*: แจ้งเตือนว่า `"ผลการทดสอบล้มเหลว: ไฟล์สำรอง ณ เวลาดังกล่าวถูกสร้างหลังเปิดใช้งาน Macro (19:02) ทำให้มีโค้ดมัลแวร์ติดมาด้วย!"`
    - *หากเปิด Cloud Sync ค้างไว้ระหว่างกู้คืน*: แจ้งเตือนว่า `"ผลการทดสอบล้มเหลว: ระบบ Cloud Sync ซิงค์ไฟล์ .locked จากคลาวด์ลงมาทับไฟล์สะอาดที่เพิ่งกู้คืน!"`

#### Scenario 4: การสรุปองค์ความรู้สำคัญและการประเมินผลในเกม (`Scene_07_Recovery.tscn`)
> **อ้างอิงบทคัดย่อ**: *"Finally, Scenario 4 summarizes the key knowledge... and an in-game assessment of cyber threat prevention skills focusing on ransomware."*

- [ ] **2.4 เพิ่มหน้าต่างสรุปองค์ความรู้สำคัญ (Key Knowledge Summary Panel) ใน Scenario 4**:
  - หลังจากผู้เล่นทำรายงานสรุปเหตุการณ์ (`Puzzle_Last_Boss_Summary.tscn` - `T14`) เสร็จสิ้น ให้แสดงสรุปบทเรียนสำคัญครบทั้ง 4 ด้านก่อนเข้าสู่หน้าคะแนนประเมินผล:
    1. **การเตรียมสภาพแวดล้อมและแยกเครื่อง (Isolation & Forensic Readiness)**: เหตุผลที่ต้องตัดเครือข่ายและใช้เครื่องแยกในการวิเคราะห์หลักฐาน
    2. **การตรวจพิสูจน์หลักฐานดิจิทัล (Event Logs, Drive History & Hash Integrity)**: วิธีสังเกตอีเมลปลอมแปลง (Typosquatting) และการไล่ไทม์ไลน์จาก Event Log
    3. **การยับยั้งการฝังตัวและการกู้คืนข้อมูล (Persistence Removal & 3-2-1 Backup)**: การหยุด Scheduled Task ใน Safe Mode และการกู้คืนจากจุดเวลาก่อนเกิดเหตุโดยปิด Cloud Sync
    4. **แนวทางการป้องกันแรนซัมแวร์ (Ransomware Prevention)**: การไม่เปิดใช้งาน Macro จากแหล่งที่ไม่น่าเชื่อถือ และการตรวจสอบโดเมนผู้ส่งเสมอ
- [ ] **2.5 ยกระดับแบบประเมินทักษะในเกม (`Puzzle_Last_Boss_Summary.tscn` & `KSA_Evaluation_UI.tscn`)**:
  - แสดงผลคะแนนแยกตามสมรรถนะที่ระบุในบทคัดย่ออย่างชัดเจน ได้แก่:
    - **การวิเคราะห์สาเหตุของภัยคุกคาม (Cause Analysis Score)** — คำนวณจากผลลัพธ์ใน Scenario 1 & 2 (`T05`–`T11`)
    - **การแก้ปัญหาและกู้คืนระบบ (Problem-Solving & Recovery Score)** — คำนวณจากการลองผิดลองถูกใน Scenario 3 (`T12`–`T13`)
    - **ความสามารถในการป้องกันแรนซัมแวร์ (Ransomware Prevention Ability / KSA Score)** — คำนวณรวมกับแบบประเมินสรุปใน Scenario 4 (`T14`–`T15`)

---

### งานส่วนที่ 3: ระบบบันทึกพฤติกรรมการตัดสินใจและเวลาวิเคราะห์แยกตาม Scenario (Game Logs & Behavioral Analytics)

> **อ้างอิงบทคัดย่อ**: *"The research instruments included game logs from each scenario and an in-game assessment of cyber threat prevention skills focusing on ransomware... Additionally, the game recorded students' decision-making behaviors, showing the time spent on analysis and decision-making."*

**สถานะปัจจุบัน**:
* `TelemetryManager.gd` จับเวลารวมเพียงค่าเดียวคือ `duration_seconds` ต่อหนึ่ง `task_id`
* ยังไม่ได้แยกเวลาที่ใช้ในการ **วิเคราะห์หลักฐาน (Analysis Time)** ออกจากเวลาที่ใช้ในการ **ตัดสินใจเลือกคำตอบ (Decision-Making Time)**
* ข้อมูลถูกส่งผ่าน HTTP ไปยัง Backend เท่านั้น หากเครื่องผู้เล่นไม่ได้รันเซิร์ฟเวอร์ Backend ไว้ ข้อมูลการเล่นจะไม่ถูกบันทึกลงไฟล์ในเครื่อง

**งานที่ต้องเพิ่ม**:
- [ ] **3.1 เพิ่มการระบุ `scenario_id` (`Scenario_1` ถึง `Scenario_4`) ในระบบ Telemetry**:
  - แมป `scene_id` และ `task_id` เข้ากับ `Scenario_1`, `Scenario_2`, `Scenario_3`, และ `Scenario_4` โดยอัตโนมัติใน `TelemetryManager.gd` และ `BaseTelemetryParam.gd`
- [ ] **3.2 แยกการจับเวลา "การวิเคราะห์ (Analysis Time)" และ "การตัดสินใจ (Decision-Making Time)"**:
  - **`analysis_duration_seconds`**: เวลาตั้งแต่เริ่มเปิดโจทย์/เปิดดูหลักฐานใน `InspectorApp` หรืออ่านข้อมูล จนถึงจังหวะที่ผู้เล่นเริ่มโต้ตอบกับตัวเลือกคำตอบครั้งแรก
  - **`decision_duration_seconds`**: เวลาตั้งแต่ผู้เล่นเริ่มเลือก/จัดลำดับ/กรอกคำตอบและทดลองส่งคำตอบ (Trial-and-error) จนกระทั่งส่งคำตอบสำเร็จ
  - **`total_duration_seconds`**: เวลารวมทั้งหมดในภารกิจนั้น
- [ ] **3.3 บันทึกประวัติการตัดสินใจและการลองผิดลองถูก (`decision_behaviors`)**:
  - เก็บลำดับตัวเลือกที่ผู้เล่นกดทดสอบในแต่ละครั้ง (`tested_options_history`), จำนวนครั้งที่ลองผิดลองถูก (`attempt_count`), และระดับคำใบ้ที่ได้รับ (`scaffolding_tier_reached`)
- [ ] **3.4 เพิ่มระบบส่งออกไฟล์ Game Log ลงเครื่องและฝั่ง Backend (`JSON` / `CSV` Export)**:
  - ใน `TelemetryManager.gd`: บันทึกทุก Event และสรุปผลราย Scenario ลงไฟล์ `user://cyber_game_logs.json` และ `user://cyber_game_summary.csv` อัตโนมัติ เพื่อให้ผู้สอนสามารถนำไฟล์ Log จากเครื่องผู้เรียนไปวิเคราะห์ผลได้ทันทีแม้ใช้งานแบบ Offline
  - ใน `backend_api/main.py`: เพิ่ม Endpoint สำหรับดึงข้อมูลสรุป Game Logs รายบุคคลและราย Scenario (`GET /api/v1/telemetry/logs` และ `GET /api/v1/telemetry/summary`) เพื่อใช้ในการวิเคราะห์ข้อมูลการเรียนรู้ของผู้เรียน

---

## 4. ลำดับความสำคัญในการดำเนินงาน (Implementation Roadmap)

1. **เฟสที่ 1 — ระบบบันทึกเวลาวิเคราะห์/การตัดสินใจ และการแบ่ง 4 Scenarios (`TelemetryManager.gd`, `BasePuzzleUI.gd`, `backend_api/main.py`)**
   - เพิ่ม `scenario_id`, การแยก `analysis_duration_seconds` / `decision_duration_seconds`, และการบันทึกไฟล์ Log (`JSON`/`CSV`)
2. **เฟสที่ 2 — ระบบ Adaptive In-Game Scaffolding (`BasePuzzleUI.gd` และฉาก Puzzle ทั้งหมด)**
   - เพิ่มคำใบ้ 3 ระดับตามทักษะผู้เล่นและจำนวนครั้งที่ตอบผิดในทุกปริศนา
3. **เฟสที่ 3 — ระบบจำลองผลการลองผิดลองถูกใน Scenario 3 (`persistence_order_puzzle.gd`, `backup_recovery_puzzle.gd`)**
   - เพิ่มข้อความจำลองผลกระทบตามตัวเลือกที่ผู้เล่นทดสอบผิดพลาด เพื่อให้เกิดการเรียนรู้แบบ Trial-and-Error อย่างแท้จริง
4. **เฟสที่ 4 — หน้าจอสรุปองค์ความรู้และประเมินทักษะใน Scenario 4 (`incident_report_puzzle.gd`, `ksa_evaluation.gd`, `Scene_07_Recovery.gd`)**
   - เพิ่มการสรุปองค์ความรู้ทั้ง 4 สถานการณ์ และการแสดงผลคะแนนแยกตามด้าน (การวิเคราะห์สาเหตุ, การแก้ปัญหา, และการป้องกันแรนซัมแวร์)
