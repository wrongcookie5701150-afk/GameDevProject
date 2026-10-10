# 🛡️ โครงการพัฒนาเกมเนื้อเรื่อง 2D ด้านความปลอดภัยไซเบอร์ (Cybersecurity Educational Game)

โปรเจกต์เกมการศึกษาความปลอดภัยทางไซเบอร์แบบ 2D พัฒนาด้วย **Godot Engine 4.x** เชื่อมต่อระบบวิเคราะห์พฤติกรรมผู้เล่นแบบ Real-time ด้วย **FastAPI** และตรวจสอบความถูกต้องของสัญญาข้อมูล (Data Contract) ผ่าน **GitHub Actions CI Pipeline**[cite: 2]

---

## 📌 สถาปัตยกรรมระบบ (Architecture Overview)

* **Client (Godot Engine):** นำเสนอเนื้อเรื่อง 6 ฉาก และควบคุมการแก้ปัญหา Cyber Investigation (Task 01–16 / Puzzle 01–08) มี Singleton `TelemetryManager.gd` คอยดักจับ Event Logs และเวลาการแก้ปัญหาเพื่อส่งข้อมูลผ่าน HTTP POST[cite: 1, 2]
* **Backend Gateway (FastAPI):** ตรวจสอบ Data Validation ของแต่ละ Task ผ่าน Pydantic Schema และคำนวณการจัดกลุ่มผู้เล่นเบื้องต้น (Beginner / Expert) ตอบกลับไปยังตัวเกมเพื่อปรับเกมเพลย์แบบไดนามิก [Dynamic Gameplay](cite: 2)
* **Quality Assurance (GitHub Actions CI):** บังคับตรวจความถูกต้องของ Schema และ Metrics ก่อนรวมโค้ดผ่าน Pytest[cite: 2]
* **Data & Analytics (Pipeline ในอนาคต):** จัดเก็บ Logs ลง SQL Server เพื่อนำไปเทรน Machine Learning (Scikit-Learn) และแสดงผลสถิติบน Power BI Dashboard[cite: 2]

---

## 📂 โครงสร้างโฟลเดอร์ของโปรเจกต์ (Project Structure)

```text
GameDevProject/
├── .github/
│   └── workflows/
│       └── analytics_validation.yml # CI Workflow ตรวจสอบ Schema อัตโนมัติเมื่อเปิด PR
├── backend_api/                     # ระบบ API หลังบ้าน (FastAPI)
│   ├── __init__.py
│   ├── main.py                      # Endpoint รับ Telemetry Logs และส่งค่า Dynamic Gameplay
│   └── requirements.txt             # รายชื่อแพ็กเกจ Python พร้อมล็อกเวอร์ชัน
├── game-client/                     # โฟลเดอร์โปรเจกต์เกม (Godot Engine 4.x)
│   ├── scenes/                      # ไฟล์ฉากย่อย (Scene_01 ถึง Scene_06)
│   ├── scripts/                     # สคริปต์ควบคุมเกมและ TelemetryManager.gd
│   └── assets/                      # ทรัพยากรเกม (Sprite, UI, เสียง)
├── tests/
│   └── test_analytics_contract.py   # TestClient ตรวจสอบ Data Contract ของแต่ละ Task
├── docs/                            # เอกสารการออกแบบเกมและสถาปัตยกรรม
│   ├── Story Content.md             # สตอรี่บอร์ดเนื้อเรื่องและปริศนา (Tasks 1-16)
│   └── Function & Scene.md          # ข้อกำหนดฟังก์ชันและโหนดในแต่ละ Scene
├── pytest.ini                       # การตั้งค่า Pytest และ Markers
└── README.md

```

---

## 🚀 การติดตั้งและรันระบบเบื้องต้น (Getting Started)

### 1. ฝั่ง Backend API & Testing (Python 3.10+)

```bash
# สร้างและเปิดใช้งาน Virtual Environment
python -m venv .venv
# บน Windows:
.venv\Scripts\activate

# ติดตั้ง Dependencies
pip install -r backend_api/requirements.txt

# รัน Backend API ในโหมด Development
uvicorn backend_api.main:app --reload

# รัน Contract Test ตรวจสอบสัญญาระบบ
pytest tests/test_analytics_contract.py -v

```

### 2. ฝั่ง Client (Godot 4.x)

1. เปิดโปรแกรม **Godot Engine 4.x**
2. เลือก Import แล้วชี้ไปที่โฟลเดอร์ `game-client/project.godot`
3. ตรวจสอบว่า `TelemetryManager.gd` ถูกตั้งค่าเป็น **Autoload Singleton** ใน Project Settings

---

## 📋 กติกาการส่งงานของทีม (Branch, PR & CI Workflow)

เพื่อไม่ให้โค้ดของแต่ละคนที่แบ่งกันทำคนละ Scene ทับซ้อนกัน :

### 1. การแบ่งงานและสร้าง Branch

* ห้าม Push โค้ดตรงเข้า `main` หรือ `develop` โดยเด็ดขาด
* แตก Branch แยกตาม Task หรือ Scene ที่รับผิดชอบ เช่น:
  * `feat/scene-02-task-task-04`
  * `feat/scene-04-task-06`
  * `feat/scene-05-task-08`

### 2. การเชื่อมต่อ Telemetry ในแต่ละ Scene

เมื่อทำ Puzzle หรือ Task ใน Scene ตัวเองเสร็จ ให้เรียกใช้ `TelemetryManager.track_event()` และส่งค่า Metrics บังคับให้ครบถ้วน:

| Scene | Task ID | พารามิเตอร์บังคับใน `metrics` |
| --- | --- | --- |
| **Scene 02** | `Task_04` | `wpm`, `accuracy` |
| **Scene 04** | `Task_06` | `selected_timestamp` |
| **Scene 04** | `Task_07` | `selected_email`, `domain_checked` |
| **Scene 05** | `Task_08` | `hash_algorithm`, `match_status` |
| **Scene 05** | `Task_11` | `decoded_output` |
| **Scene 05** | `Task_13` | `decoded_target`, `decoded_mode` |
| **Scene 05** | `Task_14` | `sequence_steps` |
| **Scene 06** | `Task_15` | `recovery_point`, `isolated_sync` |
| **Scene 06** | `Task_16` | `conclusions_score` |

### 3. การเปิด Pull Request (PR) และปิด Issue อัตโนมัติ

1. ตรวจสอบการรันเทสต์ในเครื่องตัวเองให้ผ่านก่อน Push:

    ```bash
    pytest tests/test_analytics_contract.py -v
    ```

1. Push ขึ้น Branch ของตัวเอง แล้วสร้าง **Pull Request** ไปยัง `main`
1. ในคำอธิบายของ PR ให้พิมพ์คีย์เวิร์ดผูกกับ Issue เช่น:

    ```text
    Closes #IssueNumber
    ```

1. **Branch Protection:** ระบบ GitHub Actions CI จะรันตรวจสอบโค้ดอัตโนมัติ หาก Test ผ่านเป็นสีเขียว (✅) ปุ่ม Merge จึงจะเปิดให้รวมโค้ด และ Issue จะถูกปิดอัตโนมัติทันที

---

## 📚 เอกสารประกอบและการร่วมพัฒนา (Documentation & Guidelines)

สำหรับสมาชิกในทีม กรุณาศึกษาแนวทางการทำงานและรายละเอียดงานจากเอกสารดังต่อไปนี้:

* 📖 **คู่มือการใช้งาน GitHub และขั้นตอนการส่งงาน (Git Workflow):**
  👉 [คลิกเพื่อดูคู่มือ Git Tutorial](<docs/Git Tutorial.md>)
  *(อธิบายขั้นตอนการแตก Branch, การตั้งชื่อ Commit, การเปิด Pull Request และการผูกคำสั่งปิด Issue อัตโนมัติ)*

* 📋 **รายการงาน Scene และ Script ที่ต้องพัฒนา (Work Plan):**
  👉 [คลิกเพื่อดูรายละเอียด Scenes & Scripts List](<docs/Work_Plan/Scenes&Scripts_list.md>)
  *(รายละเอียดโหนด, ฟังก์ชัน GDScript, และขอบเขตการทำงานของแต่ละ Scene และ Task)*

---
