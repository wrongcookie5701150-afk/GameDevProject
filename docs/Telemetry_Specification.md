# แผนแม่บทระบบประเมินผู้เล่นและ Game Telemetry Specification (CyberSecurityGame)

เอกสารนี้ระบุรายละเอียดโครงสร้างข้อมูลและพารามิเตอร์ทั้งหมดที่ระบบทำการเก็บรวบรวม (Telemetry Ingestion) จาก Godot Engine เข้าสู่ Backend (FastAPI / Azure Cloud) เพื่อใช้ในการวิเคราะห์พฤติกรรม ประเมินทักษะความรู้ (Skill/Competency Evaluation) และการปรับระดับการช่วยเหลือในเกม (Dynamic Difficulty & Adaptive Hints)

---

## 1. มิติการประเมินผู้เล่น (Evaluation Dimensions)

เพื่อประเมินศักยภาพของผู้เล่นอย่างครอบคลุม ระบบจะจัดกลุ่มการวัดผลออกเป็น **4 แกนหลัก**:

```
                              ┌──────────────────────────────────┐
                              │     Player Evaluation Matrix     │
                              └────────────────┬─────────────────┘
                                               │
         ┌───────────────────────┬─────────────┴───────────┬───────────────────────┐
         ▼                       ▼                         ▼                       ▼
  [1. Knowledge & Skill]  [2. Cognitive Process]   [3. Emotional & Risk]   [4. Engagement & Time]
  - ความถูกต้องของคำตอบ     - ลำดับขั้นตอนการสืบสวน      - ความระมัดระวัง/ความมั่นใจ   - Total Session Time
  - ความแม่นยำ (Accuracy)  - การใช้คำใบ้ (Hint Rely)   - พฤติกรรมเดาสุ่ม (Brute)    - Puzzle Bottleneck
  - ทักษะการวิเคราะห์ Log    - Critical Thinking Path  - ความตื่นตระหนก/รีบกด      - Heartbeat Playtime
```

### 1.1 ความรู้และทักษะเชิงเทคนิค (Technical Knowledge & Skills)
* **Incident Analysis**: ความสามารถในการจับผิด Windows Event Log (Logon Type 3, Event ID 4624/4625), การตรวจสอบ Malicious Domain/Typosquatting
* **Data Integrity**: ความเข้าใจเรื่อง Hashing (SHA-256 vs MD5) และการตรวจสอบความถูกต้องของไฟล์
* **Forensic & Decoding**: ทักษะการถอดรหัส Base64, Hexadecimal และการตรวจจับ Shellcode / Persistence
* **Remediation & Recovery**: ความเข้าใจหลักการสำรองข้อมูล 3-2-1 Rule และขั้นตอน Incident Response Sequence

### 1.2 กระบวนการคิดและพฤติกรรมแก้ปัญหา (Cognitive & Problem Solving)
* **First-Attempt Accuracy**: ตอบถูกตั้งแต่รอบแรกโดยไม่ลองสุ่ม หรือต้องลองผิดลองถูก
* **Critical Thinking Path**: ตรวจสอบลำดับการกดดูข้อมูล ว่าผู้เล่นหาหลักฐานก่อนตอบ หรือตอบก่อนหาข้อมูล
* **Hint Reliance Index**: สัดส่วนการพึ่งพาคำใบ้ (ขอ Hint ทันที vs พยายามวิเคราะห์ก่อนขอ Hint)
* **Trial Strategy**: การเปลี่ยนคำตอบในแต่ละ Attempt มีทิศทางที่สอดคล้องกับเบาะแสหรือไม่

### 1.3 ความระมัดระวังและการจัดการความเสี่ยง (Behavioral & Risk Awareness)
* **Phishing/Social Engineering Resistance**: วัดจากตัวเลือกที่ผู้เล่นกดเปิดในมินิเกมอีเมล เช่น ตรวจทาน Domain Header ก่อนกดเปิด Attachment
* **Brute-Force / Panic Detection**: ตรวจจับการกดรัวๆ ซ้ำๆ ภายในเวลาสั้นผิดปกติ (เช่น ลองส่งคำตอบเกิน 5 ครั้งใน 10 วินาที)
* **Verification Habit**: พฤติกรรมการเช็กความปลอดภัยซ้ำ (Double-checking) ก่อนยืนยันผลการตัดสินใจ

### 1.4 การจัดสรรเวลาและการมีส่วนร่วม (Time Management & Engagement)
* **Total Playtime (Active vs Idle)**: เวลาที่ใช้เล่นจริง ผ่านระบบ Heartbeat ไม่นับรวมเวลาที่พับหน้าจอทิ้งไว้
* **Puzzle Latency**: เวลาในการแก้ปัญหาแต่ละ Task เทียบกับเวลาเฉลี่ย (Baseline)
* **Hesitation Time (Thinking Delay)**: เวลาตั้งแต่เปิดหน้าต่างปริศนาจนถึงการขยับ/คลิกแรก (First Action Latency)

---

## 2. รายละเอียดตัวแปรที่เก็บ (Telemetry Data Dictionary)

### 2.1 ข้อมูลระดับ Session & System (Common Event Schema)

| Field Name | Type | Description | ตัวอย่างข้อมูล |
| :--- | :--- | :--- | :--- |
| `session_id` | String (UUID) | รหัสประจำรอบการเล่น (รีเซ็ตเมื่อเริ่มเกมใหม่) | `"550e8400-e29b-41d4-a716-446655440000"` |
| `player_id` | String | รหัสผู้เล่น / รหัสนักศึกษา | `"player_std_640101"` |
| `scene_id` | String | ฉากปัจจุบันในเกม | `"Scene_02"`, `"Scene_04"`, `"Scene_05"`, `"Scene_06"` |
| `task_id` | String | รหัสภารกิจที่กำลังทำ | `"Task_04"`, `"Task_06"`, `"Task_08"` |
| `event_type` | String | ประเภทของเหตุการณ์ | `"session_start"`, `"heartbeat"`, `"puzzle_submitted"`, `"hint_requested"` |
| `timestamp` | DateTime (UTC) | วันและเวลาสากลที่เกิดเหตุการณ์ | `"2026-10-31T14:00:00Z"` |
| `duration_seconds` | Float | เวลาที่ใช้ใน Task นั้นๆ (วินาที) | `24.5` |
| `is_correct` | Boolean / Null | ผลลัพธ์ความถูกต้อง (ถ้าเป็นภารกิจ) | `true`, `false`, `null` |
| `attempt_count` | Integer | จำนวนครั้งที่พยายามส่งคำตอบ | `1`, `2`, `3` |
| `hint_used` | Boolean | มีการเปิดดูคำใบ้ใน Task นี้หรือไม่ | `true`, `false` |
| `metrics` | Object (JSON) | พารามิเตอร์เฉพาะทางของแต่ละ Task | `{ "wpm": 54.0, ... }` |

---

### 2.2 ข้อมูลเจาะลึกเฉพาะแต่ละภารกิจ (`metrics` Payload)

| Task ID | ชื่อภารกิจ / ฉาก | พารามิเตอร์ใน `metrics` | ตัววัดและสิ่งที่นำไปประเมิน |
| :--- | :--- | :--- | :--- |
| **Task_04** / `T04` | มินิเกมพิมพ์งาน (Scene 2) | `wpm` (Float), `accuracy` (Float), `backspace_count` (Int) | ทักษะความเร็วและความแม่นยำในการพิมพ์ (Typing proficiency) |
| **Task_06** / `T06` | Windows Event Log (Scene 4) | `selected_timestamp` (String), `log_filter_used` (Array), `inspected_rows_count` (Int) | ทักษะการอ่าน Log ไทม์ไลน์ และความสามารถในการคัดกรอง Event ID |
| **Task_07** / `T07` | Email & Drive History (Scene 4) | `selected_email` (String), `domain_checked` (Boolean), `hover_duration_link` (Float) | ความตระหนักรู้ภัย Phishing และ Typosquatting (มีการตรวจโดเมนก่อนคลิกหรือไม่) |
| **Task_08** / `T08` | EV Drive Hash Integrity (Scene 5) | `hash_algorithm` (String), `match_status` (Boolean), `compare_attempts` (Int) | ความเข้าใจเรื่อง Cryptographic Hash Verification |
| **Task_11** / `T11` | Base64 Decoder (Scene 5) | `decoded_output` (String), `raw_input_length` (Int) | ทักษะการวิเคราะห์และถอดรหัส Payload เบื้องต้น |
| **Task_13** / `T13` | Hex & Base64 Decoder (Scene 5) | `decoded_target` (String), `decoded_mode` (String), `syntax_errors` (Int) | ทักษะการแปลง Multi-encoding ของ Malware |
| **Task_14** / `T14` | Persistence Stop Sequence (Scene 5) | `sequence_steps` (Array[String]), `misordered_count` (Int) | ความเข้าใจขั้นตอนการตัดการเชื่อมต่อและทำลายกลไก Persistence ของมัลแวร์ |
| **Task_15** / `T15` | 3-2-1 Safe Backup Recovery (Scene 6) | `recovery_point` (String), `isolated_sync` (Boolean), `media_types_selected` (Array) | ความเข้าใจเรื่องกลยุทธ์การกู้คืนระบบแบบปลอดภัย ป้องกัน Ransomware ติดซ้ำ |
| **Task_16** / `T16` | Final Incident Report (Scene 6) | `conclusions_score` (Float), `executive_summary_answers` (Dict) | ความสามารถในการสรุปบทเรียนและวิเคราะห์ภาพรวมการโจมตี (Executive Synthesis) |
| **Task_15** (KSA) / `T15` | การประเมินสมรรถนะรวม (Scene 6) | `knowledge_score` (Float), `skills_score` (Float), `attitude_score` (Float) | เกณฑ์การวัดผล KSA (Knowledge, Skills, Attitude) รวม |

---

### 2.3 เหตุการณ์ระดับพฤติกรรมผู้เล่น (Behavioral & Session Telemetry)

นอกเหนือจาก `puzzle_submitted` ระบบยังรองรับ Event เหล่านี้:
1. `session_start`: บันทึกเมื่อผู้เล่นเปิดเกม พร้อมข้อมูลเวอร์ชันและ Session UUID
2. `heartbeat`: ยิงทุก 30 วินาที พร้อมส่ง `idle_time` เพื่อคำนวณ Active Playtime ที่แท้จริง
3. `hint_requested`: บันทึกเวลาที่ขอ Hint, ระดับ Hint ที่เปิดดู (Level 1/2/3) เพื่อประเมินความพึ่งพาคำใบ้
4. `evidence_inspected`: บันทึกเมื่อผู้เล่นเปิดอ่านโน้ต เอกสาร หรือหลักฐานในเกม
5. `session_end`: สรุปเวลารวมและสถิติทั้งหมดก่อนปิดเกม

---

## 3. สูตรการคำนวณและเกณฑ์การจำแนกผู้เล่น (Dynamic Adaptation)

Backend มีระบบจัดกลุ่มผู้เล่นอัตโนมัติ (Player Clustering):

* **กลุ่มผู้เชี่ยวชาญ (Expert Cluster):**
  * เงื่อนไข: `duration_seconds < 20.0` **และ** `hint_used == false` **และ** `is_correct == true`
  * ผลลัพธ์: `difficulty_multiplier = 1.2`, ปิดคำใบ้อัตโนมัติ (`adaptive_hint_enabled = false`)
* **กลุ่มผู้เริ่มต้น (Beginner Cluster):**
  * เงื่อนไข: ใช้เวลาทำนาน, มีการขอคำใบ้, หรือตอบผิดในรอบแรก
  * ผลลัพธ์: `difficulty_multiplier = 1.0`, เปิดใช้งานระบบช่วยเหลือและคำใบ้เพิ่มเติม (`adaptive_hint_enabled = true`)
