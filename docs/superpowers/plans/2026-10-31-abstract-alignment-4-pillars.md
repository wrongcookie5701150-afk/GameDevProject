# Abstract Alignment 4 Pillars Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** พัฒนาและปรับปรุง 4 ฟีเจอร์หลักในเกมให้สอดคล้องกับบทคัดย่องานวิจัย (Abstract) ได้แก่:
1. ระบบช่วยเหลือในเกมที่ปรับตามระดับทักษะ (In-Game Adaptive Scaffolding Tier 1-3)
2. ระบบแก้ปัญหาแบบลองผิดลองถูกพร้อมผลลัพธ์จำลองใน Scenario 3 (Trial-and-Error Simulation)
3. หน้าต่างสรุปองค์ความรู้ 4 ด้านและปรับปรุงผลประเมินใน Scenario 4 (Key Knowledge Summary & Competencies)
4. การแยกจับเวลาวิเคราะห์ (Analysis) และตัดสินใจ (Decision-Making) พร้อมบันทึก Game Logs ราย Scenario ลงเครื่อง (Offline JSON/CSV)

**Architecture & Guardrails:**
- ห้ามแก้ไข `game_client/ui/os_simulation/notebook_screen.tscn` (STRICTLY LOCKED)
- ต้องรักษาความเข้ากันได้กับสัญญา Telemetry (`tests/test_analytics_contract.py`) 100%
- ใช้ lowercase paths ใน GDScript (`res://scenes/...`, `res://ui/...`)
- การปรับ UI ให้ทำผ่าน GDScript หรือ surgical property edits ไม่รื้อถอน Hierarchy ของ `.tscn`

---

### Task 1: ระบบจับเวลาแยกส่วน Analysis vs Decision & Game Logs Export ราย Scenario (Pillar 4)

- [x] **1.1 อัปเดต `game_client/autoload/TelemetryManager.gd`**:
  - เพิ่มพจนานุกรมการแมป Scenario:
    `SCENARIO_MAPPING = {"T01": "Scenario_1", "T02": "Scenario_1", "T03": "Scenario_1", "T04": "Scenario_1", "T05": "Scenario_1", "T06": "Scenario_2", "T07": "Scenario_2", "T08": "Scenario_2", "T09": "Scenario_2", "T10": "Scenario_2", "T11": "Scenario_2", "T12": "Scenario_3", "T13": "Scenario_3", "T14": "Scenario_4", "T15": "Scenario_4"}`
  - เพิ่มเมธอด `get_scenario_for_task(task_id: String) -> String`
  - เพิ่มระบบบันทึกไฟล์ออฟไลน์: `user://scenario_game_logs.json` และ `user://scenario_game_summary.csv` ทุกครั้งที่มีการส่ง Event
  - เมธอด `export_game_logs_summary() -> Dictionary`
- [x] **1.2 อัปเดต `game_client/ui/base_classes/BasePuzzleUI.gd`**:
  - เพิ่มตัวแปรจับเวลา:
    `var _analysis_start_time: float = 0.0`
    `var _decision_start_time: float = 0.0`
    `var _first_interaction_recorded: bool = false`
    `var decision_history: Array[Dictionary] = []`
  - เพิ่มเมธอด `mark_decision_started()` เพื่อบันทึกจังหวะที่ผู้เล่นเริ่มมีปฏิสัมพันธ์กับ Input/Selection
  - คำนวณ `analysis_duration_seconds` และ `decision_duration_seconds` ส่งต่อใน `metrics`
- [x] **1.3 ตรวจสอบ Contract Tests**:
  - รัน `pytest tests/test_analytics_contract.py` ให้ผ่าน 100%

---

### Task 2: ระบบ Adaptive In-Game Scaffolding 3 ระดับ (Pillar 1)

- [x] **2.1 เพิ่มฟังก์ชัน Scaffolding ใน `game_client/ui/base_classes/BasePuzzleUI.gd`**:
  - ตัวแปร:
    `@export var hint_tier_1: String = ""`
    `@export var hint_tier_2: String = ""`
    `@export var hint_tier_3: String = ""`
    `var current_hint_tier: int = 0`
  - เมธอด `get_adaptive_hint_tier() -> int` (คำนวณจาก `TelemetryManager.current_player_cluster`, `attempt_count`, และเวลาที่ใช้)
  - เมธอด `request_scaffolding_hint() -> String` คืนค่าข้อความคำใบ้ตามระดับ Tier และตั้ง `hint_used = true`
  - เมธอด `_setup_scaffolding_ui()` สร้างปุ่ม `💡 Hint [H]` และ Banner/Label แสดงคำใบ้แบบ dynamic สไตล์ Cyberpunk
  - รองรับชอร์ตคัตคีย์บอร์ด `[H]` เพื่อเปิดคำใบ้
- [x] **2.2 ติดตั้งคำใบ้ 3 ระดับให้ครบทั้ง 5 ปริศนา**:
  - `game_client/ui/puzzles/event_log_puzzle.gd` (`T06`)
  - `game_client/ui/puzzles/drive_history_puzzle.gd` (`T07`)
  - `game_client/ui/puzzles/persistence_order_puzzle.gd` (`T12`)
  - `game_client/ui/puzzles/backup_recovery_puzzle.gd` (`T13`)
  - `game_client/ui/puzzles/incident_report_puzzle.gd` (`T14`)
- [x] **2.3 ตรวจสอบ Contract Tests**:
  - รัน `pytest tests/test_analytics_contract.py` ให้ผ่าน 100%

---

### Task 3: ระบบจำลองผลลัพธ์การลองผิดลองถูกใน Scenario 3 (Pillar 2)

- [x] **3.1 ปรับปรุง `game_client/ui/puzzles/persistence_order_puzzle.gd` (`T12`)**:
  - เมื่อ Submit ลำดับขั้นตอนที่ไม่ถูกต้อง ให้จำลองผลลัพธ์ตามจุดผิดจริง:
    - ถ้า `restore_backup` อยู่ก่อน `disable_task` / `quarantine_helper` -> จำลองเหตุการณ์ว่าโปรเซส `Office_Update_Helper` ทำงานซ้ำและลบไฟล์ที่เพิ่งกู้คืน
    - ถ้าไม่เข้า `safe_mode` ก่อน -> แจ้งเตือนว่าโปรเซสมัลแวร์ที่กำลังรันอยู่ขัดขวางไม่ให้กักกันไฟล์
    - ถ้ากู้คืนก่อน `pause_cloud_sync` -> แจ้งเตือนว่าไฟล์เสียหายถูกซิงค์กลับไปทับคลาวด์
  - บันทึกการลองผิดลองถูกลงใน `decision_history`
- [x] **3.2 ปรับปรุง `game_client/ui/puzzles/backup_recovery_puzzle.gd` (`T13`)**:
  - เมื่อ Submit การตั้งค่าที่ไม่ถูกต้อง ให้จำลองผลลัพธ์ตามตัวเลือก:
    - ถ้าเลือก Version `infected_1905` หรือ `infected_1910` -> จำลองผลว่าไฟล์สำรองติดมัลแวร์ซ้ำ
    - ถ้าเลือกปลายทางเป็น `original_drive` -> จำลองผลว่าระบบเดิมยังมีความเสี่ยง
    - ถ้าไม่ปิด `cloud_sync` -> จำลองผลว่าไฟล์ `.locked` ถูกซิงค์ลงมาทับไฟล์สะอาด
  - บันทึกประวัติการเลือกใน `decision_history`
- [x] **3.3 ตรวจสอบ Contract Tests**:
  - รัน `pytest tests/test_analytics_contract.py` ให้ผ่าน 100%

---

### Task 4: หน้าต่างสรุปองค์ความรู้และแบบประเมินทักษะใน Scenario 4 (Pillar 3)

- [x] **4.1 เพิ่มหน้าต่างสรุปองค์ความรู้ 4 ด้านใน `game_client/scenes/scene_07_recovery/Scene_07_Recovery.gd`**:
  - สร้าง `KeyKnowledgeSummaryPanel` แสดงองค์ความรู้สำคัญ 4 ด้านก่อนเข้าสู่แบบประเมิน KSA:
    1. Isolation & Forensic Readiness
    2. Digital Evidence Analysis (Event Logs, Drive History, Hash Integrity)
    3. Persistence Removal & 3-2-1 Backup Strategy
    4. Ransomware Prevention & Macro Security
- [x] **4.2 ปรับปรุงการคำนวณและแสดงผลใน `game_client/ui/puzzles/ksa_evaluation.gd`**:
  - แสดงผล 3 ด้านตรงตาม Abstract:
    1. ความสามารถในการวิเคราะห์สาเหตุ (Cause Analysis Score)
    2. ความสามารถในการแก้ปัญหา (Problem Solving Score)
    3. ความสามารถในการป้องกันแรนซัมแวร์ (Ransomware Prevention Ability / KSA Score)
  - ส่งข้อมูลไปยัง `TelemetryManager` ตามสัญญา `knowledge_score`, `skills_score`, `attitude_score` ครบถ้วน
- [x] **4.3 ตรวจสอบ Contract Tests**:
  - รัน `pytest tests/test_analytics_contract.py` ให้ผ่าน 100%

---

### Task 5: Final Verification & Integration Test

- [ ] รันการตรวจสอบ GDScript syntax ของทุกไฟล์ที่แก้ไข
- [ ] รัน `pytest tests/test_analytics_contract.py` (ต้องผ่าน 11/11 tests 100%)
- [ ] ตรวจสอบความปลอดภัยของ `notebook_screen.tscn` ว่าไม่มีการแก้ไข
