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

## 🎮 P1 Playable Vertical Slice — Scope Checklist

**Milestone goal:** launch Scene 02, control May in a small tutorial space, interact with one tutorial objective, and reach a clear completion state. Keep existing `res://` paths stable; add base scripts without relocating the existing player files.

### In scope

- [ ] Add `game_client/Scripts/BasePlayer.gd` as the shared `CharacterBody2D` contract.
- [ ] Change `game_client/Scripts/Player.gd` to extend `BasePlayer`; preserve its existing movement and animation behavior.
- [ ] Keep `game_client/Scenes/Initial/player.tscn` and its current resource paths; verify it still attaches the derived `Player` script and its animations/collision work.
- [ ] Add `game_client/Scripts/BaseWorldScene.gd` as the shared `Node2D` world contract.
- [ ] Replace the label-only root in `game_client/Scenes/Scene_02_Tutorial.tscn` with a `Node2D` world, attach `BaseWorldScene.gd` (or a small `TutorialWorld.gd` subclass), and instance the existing player scene.
- [ ] Implement the tutorial loop: movement instructions, movement inside the tutorial space, one interaction objective, and visible completion/next-step feedback.
- [ ] Verify the current intro-to-tutorial route still resolves `res://Scenes/Scene_02_Tutorial.tscn`; remove or correct the stale alternate tutorial path in `cutscene_01_intro.gd`.
- [ ] Smoke-test loading Scene 02 directly and through Scene 01; verify movement, animation, collision/bounds, interaction, and completion.

### Out of scope for P1

- [ ] `BasePuzzle.gd` and puzzle inheritance/subclasses; do not build a generic puzzle framework before a puzzle is selected and specified.
- [ ] Implementing any of the five placeholder puzzle scenes: `Puzzle_Typing_Game`, `Puzzle_Event_Log`, `Puzzle_Drive_History`, `Puzzle_Hash_Verify`, and `Puzzle_321_Backup`.
- [ ] The remaining planned puzzles, world scenes, incident/recovery route, phone/chat/dialogue/checklist/K-S-A overlays, OS base class, and broad directory migration.
- [ ] Telemetry DTO hierarchy, backend configuration changes, save/continue, adaptive gameplay, and analytics dashboards.

### Minimal base contracts

```text
CharacterBody2D
└── BasePlayer.gd                  # New shared contract
    └── Player.gd                  # Existing movement/animation implementation
        └── Initial/player.tscn    # Existing scene with Player.gd attached

Node2D
└── BaseWorldScene.gd              # New shared world contract
    └── Scene_02_Tutorial.tscn     # Tutorial root; instances Initial/player.tscn
```

- `BasePlayer.gd`: expose `movement_enabled`, `set_movement_enabled(enabled: bool)`, an `interaction_requested(player: BasePlayer)` signal, and `interact()`. Do not move the current movement or animation code into the base during P1. `Player.gd` checks the movement gate and calls `interact()` from the chosen input action.
- `BaseWorldScene.gd`: expose `player: BasePlayer`, a `tutorial_completed` signal, `setup_scene()`, `trigger_event(event_id: StringName)`, and `_on_player_interacted(player: BasePlayer)`. `setup_scene()` resolves the player child and connects its interaction signal; the tutorial subclass handles its one objective and emits completion. Keep event handling limited to this tutorial rather than adding a general event system.
- `Scene_02_Tutorial.tscn`: use a `Node2D` root to match the world contract, instance the existing player scene as a child, and add only the minimal tutorial UI/objective nodes needed for this milestone.

### Completion gate

- [ ] P1 can be played from the existing intro route without missing-resource or script errors.
- [ ] Existing player movement and directional animation remain intact.
- [ ] The player can complete the tutorial objective and receives an unambiguous completion state.
- [ ] All added/updated scene and script references resolve after a Godot filesystem rescan; no unrelated `res://` paths were changed.

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
