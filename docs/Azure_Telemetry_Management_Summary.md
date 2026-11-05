# สรุปภาพรวมการจัดการระบบ Telemetry & Azure Cloud Deployment
**โปรเจกต์:** CyberSecurityGame (GameDevProject)  
**สาขาการทำงาน (Branch):** `feat/telemetry-azure-playtime` (Local Only - ยังไม่ได้ push ขึ้น Git)  
**วันที่บันทึก:** 31 ตุลาคม 2026  

---

## 1. การจัดการบน Microsoft Azure Cloud (Production Live)

ระบบ Backend API และระบบฐานข้อมูลได้ถูกสร้างและ Deploy ขึ้น Cloud อย่างสมบูรณ์ ภายใต้โควตา **Azure for Students (KMUTT)** โดยใช้ฟรีเทียร์เพื่อประหยัดเครดิต:

### 1.1 ข้อมูล Cloud Resources
* **Resource Group:** `rg-cybergame-telemetry-ea` (Location: `East Asia`)
* **Live API URL:** [https://app-cybergame-telemetry.azurewebsites.net](https://app-cybergame-telemetry.azurewebsites.net)
* **API Documentation (Swagger UI):** [https://app-cybergame-telemetry.azurewebsites.net/docs](https://app-cybergame-telemetry.azurewebsites.net/docs)
* **App Service Plan:** `plan-cybergame` (Linux Free Tier F1 - ไม่มีค่าใช้จ่าย)
* **Storage Account:** `stcybergame8821` (Standard LRS)
  * ตาราง **`telemetryevents`**: จัดเก็บ Event Log แบบละเอียด (Session, Scene, Task, ลำดับการคลิก, การใช้ Hint, คะแนนความถูกต้อง)
  * ตาราง **`gameplaytimes`**: บันทึกเวลาการเล่นสะสมของผู้เล่นแต่ละคน (Playtime Tracking) ป้องกันข้อมูลสูญหายเมื่อเกมหลุด/แครช

---

## 2. การอัปเกรดระบบ Backend API (`backend_api/`)

ได้ทำการพัฒนาและปรับปรุงโค้ดใน [`backend_api/main.py`](../backend_api/main.py) จากเดิมที่เก็บแค่ In-memory สู่ระบบ Cloud-ready:

1. **เชื่อมต่อ Azure Table Storage:**
   * ดึง `AZURE_STORAGE_CONNECTION_STRING` จาก Environment Variables อัตโนมัติ
   * มีระบบ Fallback สู่ In-memory Store หากรันใน Local โดยไม่มีการต่อเน็ต
2. **เพิ่มระบบ Playtime Heartbeat:**
   * เพิ่ม Endpoint `POST /api/v1/telemetry/heartbeat` เพื่อรับสัญญาณ Ping เวลาเล่นจริงจาก Godot
3. **เพิ่มระบบ Player Summary Query:**
   * เพิ่ม Endpoint `GET /api/v1/players/{player_id}/playtime` สำหรับดึงสถิติเวลาเล่นของผู้เล่นรายคน
4. **รักษาความเข้ากันได้ 100% (Backward Compatibility):**
   * ทดสอบผ่าน Unit Tests เดิมของโปรเจกต์ทั้ง 11 ข้อ (`tests/test_analytics_contract.py`) ผ่านฉลุย 100%

---

## 3. เอกสารข้อกำหนดและการประเมินผู้เล่น (Documentation)

ได้สร้างเอกสารแม่บท **[`docs/Telemetry_Specification.md`](./Telemetry_Specification.md)** เพื่อระบุเกณฑ์และมิติการประเมินผู้เล่น 4 แกน:
1. **Technical Knowledge & Skills:** การอ่าน Event Log, Hashing, Base64/Hex Decoding, Backup 3-2-1 Rule
2. **Cognitive & Problem Solving:** ความพึ่งพาคำใบ้ (Hint Reliance), การสืบสวนอย่างเป็นระบบ (Critical Thinking Path)
3. **Behavioral & Risk Awareness:** การตรวจจับความพยายามเดาสุ่ม (Brute-force detection), ความระมัดระวังต่อลิงก์/อีเมลปลอม
4. **Time & Engagement:** เวลาเล่นจริง (Active Playtime) เทียบกับเวลาวางเครื่องทิ้งไว้ (Idle Time)

---

## 4. สถานะ Git & เครื่องมือในเครื่อง (Local Environment)

* **Git Branch:** ปัจจุบันอยู่ที่ `feat/telemetry-azure-playtime` (แยกออกมาจาก `feat/OOP` อย่างปลอดภัย)
* **การป้องกัน:** ทำงานในเครื่องเท่านั้น ไม่มีการ Push โค้ดหรือ Branch ขึ้นสู่ GitHub รีโมต
* **เครื่องมือที่พร้อมใช้งาน:**
  * Python 3.11 + FastAPI + Uvicorn + Pytest (พร้อมใช้งาน)
  * Azure CLI (`az`) 2.91.0 (ติดตั้งและ Login ด้วยเมล KMUTT พร้อมใช้งาน)
  * Godot Engine 4.x (พบไฟล์ติดตั้งบน Desktop `C:\Users\Poschanan\Desktop\Godot_v4.7.2-stable_win64.exe`)

---

## 5. สิ่งที่จะทำต่อในขั้นตอนถัดไป (Next Steps)
1. **Godot Client Update:** อัปเดต `BACKEND_URL` ใน `TelemetryManager.gd` ให้ชี้ไปที่ Azure และเพิ่ม Timer สำหรับส่ง Heartbeat เวลาเล่นอัตโนมัติ
2. **Dashboard / Export:** ทำหน้าดูสรุปคะแนนและเวลาของผู้เรียนสำหรับอาจารย์/ผู้ประเมิน
