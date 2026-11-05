# Continue Modal 7 Scenes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ปรับปรุง `ContinueModal.tscn` และ `continue_modal.gd` ใน MainMenu ให้เปลี่ยนจากการเลือกราย Puzzle (9 ข้อ) มาเป็นการเลือกเข้าเล่นเนื้อเรื่องหลักทั้ง 7 Scenes (Chapter / Scene Select) โดยปลดล็อกทุกปุ่มให้เลือกเล่นได้ทันที

**Architecture:**
- `game_client/ui/menus/ContinueModal.tscn`: ปรับ UI ให้มี 7 ปุ่ม (`Scene01Button` ถึง `Scene07Button`) แทนปุ่ม Puzzle 01-09 พร้อมการจัดวางและ Theme สไตล์ Cyberpunk
- `game_client/ui/menus/continue_modal.gd`: ควบคุมการทำงานของปุ่มทั้ง 7 ซีน, การเชื่อมสัญญาณ (Signal), การโหลด Scene ด้วย `get_tree().change_scene_to_file()`, และการรองรับ 2 ภาษา (ไทย/อังกฤษ)

---

### File Changes

- **Modify**: `game_client/ui/menus/ContinueModal.tscn`
  - ปรับ Title เป็น `CONTINUE / CHAPTER SELECT`
  - ปรับ Subtitle เป็น `เลือกฉากที่ต้องการเล่น (Select Scene to Continue)`
  - ปรับปุ่มภายใน `ScrollContainer/PuzzleList` ให้มี 7 ปุ่ม: `Scene01Button` ถึง `Scene07Button`
  - ทุกปุ่มตั้งค่า `disabled = false`, สถานะ `● UNLOCKED` พร้อมตัวหนังสือชื่อฉาก
- **Modify**: `game_client/ui/menus/continue_modal.gd`
  - กำหนดพจนานุกรม `SCENE_ROUTES` สำหรับ 7 ฉากพร้อม `scene_path`, `name_th`, `name_en`
  - เชื่อมปุ่มทั้ง 7 ปุ่มเข้ากับ `_on_scene_button_pressed(idx: int)`
  - ฟังก์ชัน `apply_language(idx: int)` สำหรับแปลภาษาไทย/อังกฤษ

---

### Task 1: Update ContinueModal.tscn for 7 Scenes

- [x] แก้ไข `game_client/ui/menus/ContinueModal.tscn`:
  - ปรับข้อความ `ContinueSubtitle` ให้เป็น `Select a chapter or scene to continue`
  - แทนที่ปุ่มเดิม 9 ปุ่มด้วย 7 ปุ่ม:
    1. `Scene01Button` -> `01 Intro: สายเรียกเข้าจากเมษา (19:02)`
    2. `Scene02Button` -> `02 ห้องนอน & มือถือ: Tutorial (T01-T02)`
    3. `Scene03Button` -> `03 คอมเมย์: Typing & Incident (T03-T04)`
    4. `Scene04Button` -> `04 ห้องนอน: เตรียมเต่าดำ & Forensic Image`
    5. `Scene05Button` -> `05 โน้ตบุ๊กเต่าดำ: ตรวจสอบการตัดเน็ต (T05)`
    6. `Scene06Button` -> `06 โน้ตบุ๊กเต่าดำ: สืบสวนหลักฐาน 6 ขั้นตอน (T06-T12)`
    7. `Scene07Button` -> `07 คอมเมย์: กู้คืน 3-2-1 & สรุปผล KSA (T13-T15)`
  - ทุกปุ่มใช้สไตล์ `StyleBoxFlat_puzzle_unlocked`, `mouse_default_cursor_shape = 2`, สถานะ `● UNLOCKED`
- [x] ตรวจสอบความถูกต้องของโครงสร้าง Scene ด้วย Python script

---

### Task 2: Update continue_modal.gd to Route 7 Scenes

- [x] แก้ไข `game_client/ui/menus/continue_modal.gd`:
  - สร้าง `const SCENE_ROUTES: Dictionary` กำหนดทั้ง 7 Scenes พร้อม path:
    - 1: `res://scenes/scene_01_intro/Scene_01_Intro.tscn`
    - 2: `res://scenes/world_scenes/scene_02_tutorial/Scene_02_Tutorial.tscn`
    - 3: `res://scenes/scene_03_incident/Scene_03_Incident.tscn`
    - 4: `res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn`
    - 5: `res://scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn`
    - 6: `res://scenes/scene_06_taodam_investigation/Scene_06_TaoDam_Investigation.tscn`
    - 7: `res://scenes/scene_07_recovery/Scene_07_Recovery.tscn`
  - ปรับ `_connect_buttons()` ให้ค้นหา `Scene01Button` .. `Scene07Button` และเชื่อมกับ `_on_scene_button_pressed(idx)`
  - ปรับ `open()` ให้โฟกัสที่ `Scene01Button`
  - ปรับ `apply_language(idx: int)` ให้รองรับทั้งภาษาไทยและอังกฤษสำหรับ 7 Scenes

---

### Task 3: Verification & Integration Testing

- [x] รันการตรวจสอบ Scene และ GDScript syntax
- [x] รัน `pytest tests/test_analytics_contract.py`
- [x] ยืนยันว่าไม่มีผลกระทบต่อ `notebook_screen.tscn` หรือ scene locked อื่นๆ
