# Story Board

## ตัวละคร

1. **เมย์** - (ตัวหลัก) นักศึกษาปี 2 สาขาคอมพิวเตอร์

2. **เมษา** - (เพื่อน) ตัวทวงงาน

3. **มาร์ช** - (ตัวช่วย) นักศึกษาใกล้จบ พี่ในชมรม CYBER

## เนื้อเรื่อง

### Scene 1: Cutscene เวลา 19.02 น

เมย์กำลังใช้มือถือ เสียบหูฟังนอน และเปิดฟังเพลงผ่านลำโพง

_(มีสายจากเมษาโทรเข้ามา)_

**เมษา** : “เมย์ เธอยังไม่ได้ส่งงานเลยนะ พรุ่งนี้จะเดดไลน์แล้ว”

**เมย์** : “โอ๊ะ !”

**เมษา** : “ฉันส่งข้อความไปบอกตั้งเยอะ เปิดอ่านด้วยละกัน”

**เมย์** : “เดี๋ยวส่งไป~”

### Scene 2: Game Tutorial

เมย์ยืนข้างเตียง _(เสียงถอนหายใจ)_, ไอคอนแจ้งเตือน +4

**เมย์** : "จริงๆ แล้วฉันยังไม่ได้เริ่มแก้อะไรนั่นเลย"

> - [ ] **Task 1: อ่านข้อความจากเมษา**
>     _(สอนผู้เล่นใช้มือถือ `[p]` = เรียกหน้ามือถือขึ้นมา และ Notification จะขึ้นที่มุมจอเสมอถ้ามีข้อความ ใช้กดแทน `[p]` ได้)_
>     Trigger action: อ่านข้อความจากเมษา

_(Notification +4)_

Plaintext

```
(today)
14:33 | Mesasohot131415: "เมย์"
14:33 | Mesasohot131415: "การบ้านเธอจะทำส่วนไหน"
17:47 | Mesasohot131415: "ฉันทำหมดแล้วล่ะ เหลือส่วนของรายงาน"
18:48 | Mesasohot131415: "ฮาโหลลลลลล มีใครอยู่มั้ย"
```

**เมย์** : "เมษาเป็นคนตลกนะ แต่ถ้าฉันทำงานไม่เสร็จก่อนวันพรุ่งนี้ เธอคงกลายร่างเป็นผีไอทีแน่ๆ"

> - [ ] **Task 2: ไปที่โต๊ะคอม และเข้าใช้งาน**
>     _(สอน player ควบคุมตัวละคร `[W S A D]` = move, `[Spacebar]` = interact with object)_
>     Trigger action: เดินไปใช้งานคอมพิวเตอร์ที่เปิดอยู่

แสดงหน้าจอคอมเปล่า มีไอคอนแอป: `GG Disk`, `Text Editor`, `Recycle Bin`, `Settings`

> - [ ] **Task 3: เปิดไฟล์งาน**
>     _(สอนใช้เมาส์ interact กับ interface ในหน้าจอคอมพิวเตอร์)_
>     Trigger action: เปิดอ่านไฟล์งานใน `GG Disk`

_(กดเข้า `GG Disk`)_

**เมย์** : "มีไฟล์รายงานอยู่ด้วย เพิ่งแก้ไปไม่นานเลย เมษาคงรอไหว"

_(กดโหลดและเปิดงาน + มีข้อความเตือนให้กด Enable Content)_

**เมย์** : "งานเก่าฉันคือสร้างไวรัสรึเปล่านะ XD"

_(เนื้อหาในไฟล์เป็นสรุปเรื่อง "ความปลอดภัยไซเบอร์" มัลแวร์ต่างๆ การเข้ารหัส ซึ่งเป็นเนื้อหาความรู้ในเกม)_

> - [ ] **Task 4: ทำรายงานต่อ**
>
>     _(มินิเกมคล้าย Type Training)_
>
>     แสดง Cursor กะพริบที่บรรทัดสุดท้ายของรายงาน ให้ผู้เล่นกดแป้นพิมพ์เพื่อจำลองการพิมพ์
>
>     Trigger action: พิมพ์เนื้อหาในรายงานเพิ่ม 300 คำ

### Scene 3: Cutscene เวลา 21.23 น

_(ไทม์แลปส์)_ เมย์กำลังพิมพ์เนื้อหารายงานเพิ่ม ในขณะที่มุมขวาล่างจอมีการแจ้งเตือนขึ้นมาแล้วก็หายไป:

- ข่าวด่วนเรื่องอากาศร้อน

- การแจ้งเตือนจากเบราว์เซอร์เรื่อง “อัปเดตโปรแกรม”

- ป๊อปอัปจากโปรแกรมป้องกันไวรัสที่บอกว่า “ไม่พบภัยคุกคาม”

ตัดมาที่หน้ารวมไฟล์รายงานที่เมย์ทำเสร็จแล้ว 4 ไฟล์

Plaintext

```
งานกลุ่มล้านแปด/
├── Report_Final.docx
├── Network_Diagram.png
├── Research_Data.xlsx
└── Presentation.pptx
```

**เมย์:** "เหลือแค่ Upload files กลับก็เสร็จแล้ว"

หน้าต่าง Folder กลายเป็นสีเทาพักหนึ่ง จากนั้นไฟล์งานทั้งหมดถูกเปลี่ยนนามสกุลต่อท้ายด้วย `.locked`

ไฟล์ `README_TO_RECOVER_FILES.txt` เด้งเปิดขึ้นมากลางจอ

Plaintext

```
YOUR FILES HAVE BEEN ENCRYPTED.
DO NOT MODIFY OR DELETE FILES.
WAIT FOR FURTHER INSTRUCTIONS.
```

**เมย์:** "ท่าทางรายงานที่ฉันทำจะปลอดภัยมาก... ปลอดภัยจากตัวฉันเองด้วย"

_(ลองเปิดไฟล์ หน้าต่างโฟลเดอร์จะเป็นสีเทาแล้วเด้งกลับมาที่ไฟล์ `.txt`)_

**เมย์:** "ฉันคงต้องหาคนช่วยแล้ว"

_(Notification +1)_

Plaintext

```
(today)
21:25 | M4rchupikchu_inw101: "Roblox ป่าวน้อง"
```

**เมย์:** "ทักมาได้จังหวะเหมาะมาก"

### Scene 4: เข้าสู่วิถีไซเบอร์

Plaintext

```
(today)
21:25 | M4rchupikchu_inw101: "Roblox ป่าวน้อง"
21:26 | Mayicomeinpls: "พี่มาร์ชคะ คอมเปิดไฟล์ไม่ได้ค่ะ"
21:28 | M4rchupikchu_inw101: "ไฟล์อะไร"
21:28 | Mayicomeinpls: "ไฟล์ docx แล้วติด .locked ค่ะ"
21:28 | M4rchupikchu_inw101: "ยังไงนะ ถ่ายรูปมาดูหน่อย"
21:29 | Mayicomeinpls: (Send a picture)
21:30 | M4rchupikchu_inw101: "อืมม ตัดเน็ตคอมพิวเตอร์ก่อนเลยด่วนๆ!"
```

_(มือถือสายเข้าจากมาร์ช)_

**มาร์ช:** "ยังมีเต่าดำอยู่ใช่มั้ย"

**เมย์:** "ยังอยู่ค่ะ"

_(Cutscene: เดินไปที่ Notebook เก่าสีดำลายเต่า)_

**มาร์ช:** "นั่น ทำไมไม่เอาไปคืน"

**เมย์:** "..."

**มาร์ช:** "ช่างเถอะ มาเช็กสภาพเต่าดำกันก่อน"

Interface ภายในเต่าดำ: `Settings`, `Recycle bin`, `Autopsy`, `FTK Imager`, `HxD Hex Editor`, `olevba`

> - [ ] **Task 5: เช็กสภาพเต่าดำ (Isolated Environment)**
>
>
>
> - [ ] Wi‑Fi ปิดอยู่
>
>
>
> - [ ] ไม่เสียบสาย LAN
>
>
>
> - [ ] ไม่มีเชื่อมต่อบัญชีหรืออีเมลส่วนตัว
>
>
>
> - [ ] ไม่มีไฟล์งานสำคัญ
>
>
>

เมย์เปิดดูบันทึกเหตุการณ์ใน Event Log

Plaintext

```
## Windows Event Log

18:31:04 | explorer.exe started
18:34:19 | CloudSync.exe started
18:47:53 | SearchIndexer.exe started

18:58:07 | Report_Final.docx appeared in shared folder
18:58:07 | Shared by: mesasohot.sukj@universcity.example // ปรับแก้อีเมลให้ตรงกับคนร้ายในระบบ Drive (Typosquatting)
18:58:07 | Owner: External collaborator

19:02:10 | WINWORD.EXE opened Report_Final.docx
19:03:16 | User selected Enable Content

19:05:11 | New activity associated with WINWORD.EXE detected
19:05:19 | Office_Update_Helper.dat created in Temp folder
19:05:32 | New logon item created: Office_Update_Helper

19:06:04 | WindowsUpdate.exe checked for updates
20:12:45 | CloudSync.exe completed normal sync
20:59:12 | User idle detected

21:21:50 | Office_Update_Helper started
21:22:04 | Report_Final.docx modified
21:22:39 | Report_Final.docx renamed to Report_Final.docx.locked
21:22:47 | Research_Data.xlsx renamed to Research_Data.xlsx.locked
21:22:55 | Presentation.pptx renamed to Presentation.pptx.locked
21:23:08 | README_TO_RECOVER_FILES.txt created

21:23:21 | CloudSync.exe queued 3 changed files
21:23:54 | Wi-Fi disconnected by user
21:24:03 | CloudSync.exe paused
```

**มาร์ช:** "มีเหตุการณ์ถูกบันทึกไว้เยอะมาก พอจำได้มั้ยว่าทำอะไรก่อนไฟล์จะล็อก"

> - [ ] **Task 6: ขีดเส้นแบ่งเวลา** _(เดิม Task 7: แก้ไขเลขลำดับ)_
> - ให้ผู้เล่นคลิกโปรเซสที่เป็นจุดเริ่มต้นจนถึงจุดที่เกิดเหตุการณ์
> - Trigger: `19:02:10` ถูกคลิก
> - Hint (Wait 5 sec.): **เมย์:** “บางทีฉันอาจลองเช็กจากเวลาที่เมษาโทรมาได้”
> - Action: เวลาถูกจดลงในสมุดโน้ตข้างๆ + _(เสียงเขียนดินสอ)_

**เมย์:** “เริ่มต้นจากไฟล์ `Report_Final.docx` เมษาแกล้งฉันที่ไม่ทำงานรึเปล่านะ”

**มาร์ช:** “ลองเช็กที่มาของไฟล์กันก่อน”

Plaintext

```
## Drive Activity History

18:54 | Network_Diagram.png appeared in shared folder
18:54 | Shared by: mesa.sukj@university.example
18:54 | Owner: Mesa Sukjai
18:54 | Status: Normal file activity

18:56 | Research_Data.xlsx appeared in shared folder
18:56 | Shared by: mesa.sukj@university.example
18:56 | Owner: Mesa Sukjai
18:56 | Status: Normal file activity

18:58 | Report_Final.docx appeared in shared folder
18:58 | Shared by: mesasohot.sukj@universcity.example
18:58 | Owner: External collaborator
18:58 | Internal file inspection: Macro-enabled content detected
18:58 | Status: Suspicious file activity

19:02 | Report_Final.docx opened by: May
19:03 | Active Content enabled by: May
```

> - [ ] **Task 7: คนร้ายนั้นก็คือ..** _(เดิม Task 8)_
> - ให้ผู้เล่นเปิดประวัติบน `GG Disk` เพื่ออ่านรายการเปลี่ยนแปลง
> - Trigger: `Report_Final.docx` ถูกคลิก
> - Hint (Wait 6 sec.): **มาร์ช:** “สังเกตอีเมลดีๆ โดนอีเมลปลอมหลอกซะแล้ว”
> - Action: `Report_Final.docx` ถูกจดลงในสมุดโน้ตข้างๆ + _(เสียงเขียนดินสอ)_

**เมย์:** “เธอไม่ได้ส่งไฟล์นี้มาหรอกเหรอเนี่ย โดเมนสะกดผิดด้วย (`universcity.example`)”

**มาร์ช:** “เอาล่ะ ได้เวลาวิเคราะห์หลักฐานแล้ว หยิบทัมบ์ไดรฟ์เปล่ามา เดี๋ยวพี่ส่งสคริปต์ก๊อป Log ให้” // เพิ่มบทสนทนาให้มาร์ชเป็นคนไกด์เมย์ เพื่อความสมเหตุสมผล

_(เดินไปหา `EV Drive` จากชั้นหนังสือ แล้วนำมา Interact กับคอมพิวเตอร์หลักที่ติดไวรัส)_

### Scene 5: วิเคราะห์หลักฐาน

_(Timelapse Cutscene)_ เมย์ใช้สคริปต์ของมาร์ชสร้างสำเนาไฟล์หลักฐาน (Forensic Copy) ลงใน `EV Drive`

_(ตัดฉาก)_ เมย์นำ `EV Drive` มาเสียบที่เต่าดำ

**เมย์:** “ทำสำเนาเสร็จเรียบร้อยแล้ว”

ไฟล์ใน EV Drive ที่คัดลอกมา:

Plaintext

```
CASE_Evidence/
├── Report_Final.docx
├── Office_Update_Helper.dat
├── Windows_Event_Log.txt
├── File_Activity.log
├── Task_Details.txt
├── Drive_Activity_History.md
├── README_TO_RECOVER_FILES.txt
└── Evidence_Manifest.txt
```

> - [ ] **Task 8: ยืนยันความถูกต้องของหลักฐาน (Hash Verification)** // เพิ่ม Task ใหม่ ปูความรู้เรื่อง Integrity
> - ให้ผู้เล่นใช้เครื่องมือเช็กค่า MD5 ของไฟล์ใน EV Drive เทียบกับ Manifest
> - Trigger: ค่า Hash ตรงกันทั้งหมด ระบบขึ้นสถานะ "Evidence Verified"

> - [ ] **Task 9: เปิดโปงสปาย**
> - ให้ผู้เล่นใช้โปรแกรมเปิดเอกสารแบบ Read-only
> - Trigger: `Report_Final.docx` ถูกเปิดผ่านโปรแกรม `FTK Imager`

ภายในไฟล์

Plaintext

```
ชื่อไฟล์: Final_Report_Revision_v4.docx
ชนิดไฟล์ที่ตรวจพบ: Word Macro-Enabled Document

รายการภายใน:
word/document.xml
word/vbaProject.bin
word/_rels/document.xml.rels
```

**เมย์:** “มันชื่อ `.docx` แต่ข้างในมี `vbaProject.bin` ซ่อนอยู่”

**มาร์ช:** “มาแกะดูข้างในกันดีกว่า” _(ใช้ `olevba` เปิดอ่านไฟล์ VBA)_ // แก้คำผิดจาก olavba เป็น olevba

Plaintext

```
Macro project found
Module: OfficeUpdate
Trigger: Document_Open
Encoded value: T2ZmaWNlX1VwZGF0ZV9IZWxwZXI=
```

**มาร์ช:** “ลองจับคู่ดูว่ารายละเอียดพวกนี้คืออะไร”

> - [ ] **Task 10: จับคู่ไฟล์กับรายละเอียด**
> - แสดงหน้าต่างจับคู่ (กระดาษทดของเมย์) แบบ 3 คู่
> - Trigger: รายการทั้งหมดถูกจับคู่ถูกต้อง

**เมย์:** “มีรหัสอะไรสักอย่างถูกเข้ารหัสไว้ด้วย”

> - [ ] **Task 11: ถอดรหัส Base64**
> - ให้ผู้เล่นใช้เครื่องมือถอดรหัสเลขฐาน (Decoder)
> - Trigger: นำค่า Encoded value ไปถอดรหัสผ่าน Base64
> - Hint (Wait 4 sec.): **มาร์ช:** “มี `=` ต่อท้าย ดูเหมือนจะเป็น Base64 นะ”
> - Action: ถอดรหัสได้คำว่า `Office_Update_Helper` และถูกจดลงโน้ต

**เมย์:** “นี่คือไฟล์ที่ถูกสร้างหลังจากฉันกด Enable Content สินะ”

**มาร์ช:** “เบื้องหลังของไฟล์นี้คงมีคำตอบอยู่”

> - [ ] **Task 12: เปิดหลักฐาน**
> - ให้ผู้เล่นเปิดไฟล์ `Office_Update_Helper.dat` ผ่าน Inspector
> - Trigger: Inspector โหลดไฟล์ `Office_Update_Helper.dat`
> - Hint (Wait 4 sec.): **เมย์:** “ตัว Inspector อยู่ตรงไหนนะ...”
> - Action: แสดงเนื้อหาไฟล์ `Office_Update_Helper.txt`

Plaintext

```
## Office_Update_Helper.dat

TARGET: UHJvamVjdF9Gb2xkZXI= //Project_Folder
MODE: 526B6C4D5256395853564246 //FILE_WIPE
STATUS: ACTIVE
```

> - [ ] **Task 13: ถอดรหัสเป้าหมาย** _(แก้ตัวเลข Task ที่ซ้ำกัน)_
> - ให้ผู้เล่นถอดรหัส `TARGET` (Base64) และ `MODE` (Hex) ผ่าน Decoder
> - Trigger: ถอดรหัสครบทั้งสองชุด
> - Action: ทราบว่าเป้าหมายคือ Project Folder และโหมดคือ FILE_WIPE

_(ตรวจสอบไฟล์ที่ถูกเปลี่ยนชื่อ)_

Plaintext

```
## File Inspector

Filename: Report_Final.docx.locked
File size: 0 KB
File signature: Not found
Recoverable content: Not found
```

**เมย์:** “ไฟล์เหลือ 0 KB ถึงว่าเปิดไฟล์ไม่ได้เลย”

**มาร์ช:** “มันคือ Wiper (มัลแวร์ทำลายข้อมูล) ที่หลอกว่าเป็น Ransomware ตอนนี้เราไม่ต้องหาคีย์มาปลดแล้ว แค่ต้องหยุดการทำงานของมันก่อน”

Plaintext

```
## Task Details
Task Name: Office_Update_Helper
Created by: WINWORD.EXE
Location: Temp\Office_Update_Helper.dat

Triggers:
- User logon
- User idle for 15 minutes
- Network connection available
```

> - [ ] **Task 14: การหยุด Macro และ Persistence** _(เดิม Task 13)_
> - ให้ผู้เล่นเรียงลำดับขั้นตอนหยุดยั้งการทำงาน (เช่น เข้า Safe Mode -> Kill Process -> ลบ Task Scheduler) โดยพิจารณาจาก `Task_Details.txt` เทียบกับ `Event_Log` // เพิ่มขั้นตอน Safe mode/Kill process ก่อนการกู้ไฟล์ เพื่อความสมจริง
> - Trigger: ผู้เล่นเรียงลำดับได้ถูกต้อง
> - Action: **มาร์ช:** “เท่านี้ก็เคลียร์โปรเซสอันตรายออกไปได้แล้ว”

```
## Stop Persistance Step

1. Preserve task details as evidence
2. Disable Office_Update_Helper task
3. Quarantine Office_Update_Helper.dat
4. Check for related persistence entries
5. Confirm Office_Update_Helper is no longer running
6. Pause CloudSync for the project folder
7. Restore files from backup
```

### Scene 6: กำจัดภัยคุกคามและกู้คืนข้อมูล

_(Timelapse Cutscene)_ เมย์จัดการลบโปรเซสไวรัสในคอมพิวเตอร์หลักเสร็จสิ้น

_(ตัดฉาก)_ หน้าจอเปิดโฟลเดอร์รายงานที่ว่างเปล่า

**เมย์:** “ถ้าต้องพิมพ์ใหม่ตั้งแต่ต้น คงมีตกหล่นไปบ้างแน่ๆ”

**มาร์ช:** “ไฟล์ส่วนที่เสียหาย ถ้าจำไม่ผิด `GG Disk` น่าจะ Backup ตามช่วงเวลาไว้อยู่”

Plaintext

```
## Project Folder Version History

18:40 | Report_Final.docx | Normal version
18:54 | Network_Diagram.png | Normal version
18:56 | Research_Data.xlsx | Normal version
18:57 | Presentation.pptx | Normal version

21:22 | Report_Final.docx.locked | Suspicious change
21:22 | Research_Data.xlsx.locked | Suspicious change
21:22 | Presentation.pptx.locked | Suspicious change
```

> - [ ] **Task 15: Safe Backup (3-2-1 Rule)** _(เดิม Task 14)_
> - ให้ผู้เล่นเลือกการตั้งค่าเพื่อกู้คืนและ Backup ข้อมูลอย่างปลอดภัย
> - Action: **มาร์ช:** “กู้ไฟล์เสร็จ อย่าลืมโหลดเก็บไว้ใน External Drive ด้วยล่ะ กฎ 3-2-1 สำคัญเสมอ” // เพิ่มคอนเซปต์ 3-2-1 Backup (เก็บออฟไลน์ 1 ชุด)

Plaintext

```
Recovery point:
[✓] ก่อน 19:02
[ ] หลัง 21:22

Recovery destination:
[✓] โฟลเดอร์ใหม่ (เพื่อไม่ให้ปะปนกับไฟล์ที่อาจติดเชื้อซ่อนอยู่)
[ ] โฟลเดอร์เดิมทันที

Cloud Sync:
[✓] ปิดชั่วคราวก่อนกู้ไฟล์ (กัน Sync ทับไฟล์เดิม)
[ ] เปิด
```

**เมย์:** “เหนื่อยหน่อยแต่ก็ยังดีกว่าเริ่มใหม่ทั้งหมด”

> - [ ] **Task 16: The Last Boss (สรุปบทเรียน)** _(เดิม Task 15)_
> - ให้ผู้เล่นช่วยเมย์เติมคำลงในรายงาน 3-4 ข้อสุดท้าย ซึ่งเป็นข้อสรุปจากสิ่งที่เมย์เพิ่งเจอ (เช่น 1. ตรวจสอบอีเมลผู้ส่งเสมอ 2. อย่ากด Enable Content ซี้ซั้ว 3. แบ็กอัปข้อมูลไว้แบบออฟไลน์ด้วย) // ปรับให้เนื้อหาสุดท้ายคือการทบทวนบทเรียนของผู้เล่น
> - Trigger: พิมพ์เสร็จและกด Save
> - Action: **เมย์:** “ได้นอนสักที!”

## รวม Puzzle

| **Puzzle** | **ผู้เล่นทำอะไร**                         | **สิ่งที่เรียนรู้**                             |
| ---------- | ------------------------------------- | ---------------------------------------- |
| 1          | ตรวจ Drive History                    | ตรวจผู้ส่ง สังเกตอีเมลปลอม (Typosquatting)    |
| 2          | อ่าน Windows Event Log                 | หา Timeline, Process ต้องสงสัย และ Scope   |
| 3          | ตรวจสอบค่า Hash ของหลักฐาน              | ความสมบูรณ์ของหลักฐาน (Integrity)           |
| 4          | ตรวจโครงสร้างไฟล์                       | พบ Macro ที่ซ่อนในเอกสาร (`vbaProject.bin`) |
| 5          | ถอด Base64 จาก Macro                  | เชื่อมโยง Macro กับ `Office_Update_Helper`  |
| 6          | ถอด Hex และ Base64                    | รู้พฤติกรรมว่าไฟล์ถูกล้าง (Wiper) ไม่ใช่เข้ารหัส    |
| 7          | ตัดวงจร Persistence (Kill Process)     | การระงับเหตุ (Containment & Eradication)   |
| 8          | เลือก Version History และ 3-2-1 Backup | การกู้ข้อมูลอย่างปลอดภัย (Safe Recovery)       |

## Learning Outcomes

การกำหนดผลการเรียนรู้ (Learning Outcomes) สำหรับปริศนาแต่ละส่วน สามารถจัดโครงสร้างตามหลักการแบ่งจุดประสงค์การเรียนรู้แบบ K-S-A (Knowledge, Skills, Attitude) เพื่อให้สามารถนำไปใช้วัดผลและประเมินผู้เล่นในเชิงการศึกษาได้อย่างเป็นระบบครับ ดังนี้:

| **Puzzle**                | **K (Knowledge / ความรู้)**                | **S (Skills / ทักษะ)**                    | **A (Attitude / เจตคติ)**                    |
| ------------------------- | ---------------------------------------- | ---------------------------------------- | ------------------------------------------- |
| **1: ตรวจ Drive History** | อธิบายลักษณะ Phishing และ Typosquatting    | ตรวจสอบและแยกแยะโดเมน/อีเมลแอบอ้าง         | ระแวดระวังแหล่งที่มาก่อนเปิดไฟล์เสมอ               |
| **2: อ่าน Event Log**      | เข้าใจโครงสร้างและประโยชน์ของ Event Log     | ค้นหาและสร้าง Timeline ลำดับเหตุการณ์โจมตี      | รอบคอบและไม่ข้ามขั้นตอนการรวบรวมหลักฐาน          |
| **3: ตรวจสอบ Hash**       | เข้าใจการทำงานของ Hash และ Data Integrity  | ใช้เครื่องมือเทียบค่า Hash เพื่อยืนยันความถูกต้องไฟล์ | ให้ความสำคัญกับความน่าเชื่อถือของหลักฐาน (Forensics) |
| **4: ตรวจโครงสร้างไฟล์**    | รู้กลไกการซ่อนโค้ดอันตรายในเอกสาร (Macro)     | แยกแยะความต่างของไฟล์ปกติกับไฟล์ที่มี Macro      | ไม่เพิกเฉยหรือกด Enable Content โดยไม่ตรวจสอบ   |
| **5: ถอดรหัส Base64**      | รู้จักรูปแบบการเข้ารหัสพรางตัวเบื้องต้น            | ใช้ Decoder ถอดรหัสเพื่อหาจุดเชื่อมโยง Payload  | มีความพยายามคิดวิเคราะห์สืบสาวไปถึงต้นตอ           |
| **6: วิเคราะห์ Helper**     | จำแนกความต่างของ Ransomware และ Wiper      | อ่านค่า Hex และแปลพฤติกรรมมัลแวร์จากคอนฟิก     | มีสติ ไม่ตื่นตระหนกต่อคำขู่ มุ่งวิเคราะห์ตามความเป็นจริง   |
| **7: หยุดการทำงาน**         | เข้าใจเทคนิคการฝังตัว (Persistence) ของมัลแวร์ | ลำดับขั้นตอนระงับเหตุและหยุดโปรเซสได้ถูกต้อง       | ปฏิบัติตามขั้นตอน Incident Response อย่างเป็นระบบ  |
| **8: กู้คืนข้อมูล**            | เข้าใจกฎการสำรองข้อมูลแบบ 3-2-1              | เลือกจุดกู้คืน (Version History) ได้อย่างปลอดภัย | ตระหนักว่าการ Backup คือเกราะป้องกันที่สำคัญที่สุด      |

**Puzzle 1: ตรวจ Drive History (สังเกตอีเมลปลอม - Typosquatting)**

- **Knowledge (ความรู้):** ผู้เล่นสามารถอธิบายลักษณะของการโจมตีแบบ Phishing และ Typosquatting ได้
- **Skills (ทักษะ):** ผู้เล่นสามารถตรวจสอบและแยกแยะความผิดปกติของชื่ออีเมลหรือโดเมนที่แอบอ้างบนระบบ Cloud Drive ได้
- **Attitude (เจตคติ):** ตระหนักถึงความสำคัญของการตรวจสอบแหล่งที่มาของผู้ส่งก่อนเปิดไฟล์หรือดาวน์โหลดข้อมูลเสมอ

**Puzzle 2: อ่าน Windows Event Log (หา Timeline และ Process)**

- **Knowledge (ความรู้):** ผู้เล่นเข้าใจโครงสร้างและประโยชน์ของ Windows Event Log ในการบันทึกพฤติกรรมของระบบ

- **Skills (ทักษะ):** ผู้เล่นสามารถคัดกรอง ค้นหา และเรียงลำดับเหตุการณ์ (Timeline) เพื่อหาจุดเริ่มต้นของการโจมตีได้

- **Attitude (เจตคติ):** มีความละเอียดรอบคอบในการรวบรวมหลักฐานทางดิจิทัลโดยไม่ข้ามขั้นตอน

**Puzzle 3: ตรวจสอบค่า Hash ของหลักฐาน (Data Integrity)**

- **Knowledge (ความรู้):** ผู้เล่นเข้าใจหลักการทำงานของฟังก์ชัน Hash (เช่น MD5, SHA-256) และแนวคิดเรื่องความสมบูรณ์ของข้อมูล (Integrity)

- **Skills (ทักษะ):** ผู้เล่นสามารถใช้เครื่องมือตรวจสอบและเปรียบเทียบค่า Hash เพื่อยืนยันความถูกต้องของไฟล์หลักฐานได้

- **Attitude (เจตคติ):** เห็นความสำคัญของการรักษาความน่าเชื่อถือของหลักฐานทางนิติวิทยาศาสตร์ดิจิทัล (Digital Forensics)

**Puzzle 4: ตรวจโครงสร้างไฟล์ (พบ Macro ที่ซ่อนในเอกสาร)**

- **Knowledge (ความรู้):** ผู้เล่นทราบถึงกลไกการซ่อนโค้ดอันตรายในรูปแบบ Macro-enabled Document (`vbaProject.bin`)

- **Skills (ทักษะ):** ผู้เล่นสามารถแยกแยะความแตกต่างระหว่างไฟล์เอกสารธรรมดากับไฟล์ที่มีการฝัง Macro ได้

- **Attitude (เจตคติ):** ระมัดระวังและไม่เพิกเฉยต่อคำเตือน "Enable Content" ในโปรแกรมเปิดเอกสาร

**Puzzle 5: ถอด Base64 จาก Macro (เชื่อมโยง Payload)**

- **Knowledge (ความรู้):** ผู้เล่นรู้จักรูปแบบการเข้ารหัสข้อมูลเบื้องต้น เช่น Base64 ที่มัลแวร์มักใช้ในการพรางตัว

- **Skills (ทักษะ):** ผู้เล่นสามารถใช้เครื่องมือ Decoder ในการถอดรหัสข้อความเพื่อหาจุดเชื่อมโยงไปยังโปรเซสอื่น (เช่น `Office_Update_Helper`) ได้

- **Attitude (เจตคติ):** มีความพยายามในการคิดวิเคราะห์และแก้ปัญหาเพื่อสืบสาวไปถึงต้นตอของภัยคุกคาม

**Puzzle 6: ถอด Hex และ Base64 (วิเคราะห์พฤติกรรมมัลแวร์)**

- **Knowledge (ความรู้):** ผู้เล่นสามารถจำแนกความแตกต่างระหว่าง Ransomware (เข้ารหัสเพื่อเรียกค่าไถ่) และ Wiper (มัลแวร์ทำลายข้อมูล) ได้

- **Skills (ทักษะ):** ผู้เล่นสามารถอ่านค่า Hexadecimal เบื้องต้น และแปลความหมายการทำงานของมัลแวร์จากการตั้งค่าในไฟล์ Configuration ได้

- **Attitude (เจตคติ):** ไม่ตื่นตระหนกต่อข้อความข่มขู่ของมัลแวร์ และมุ่งเน้นที่การวิเคราะห์ตามหลักฐานความเป็นจริง

**Puzzle 7: ตัดวงจร Persistence (ระงับเหตุ - Containment)**

- **Knowledge (ความรู้):** ผู้เล่นเข้าใจเทคนิคที่มัลแวร์ใช้ในการฝังตัว (Persistence) เช่น การสร้าง Scheduled Tasks หรือ Run keys

- **Skills (ทักษะ):** ผู้เล่นสามารถประยุกต์ใช้ข้อมูลจากการวิเคราะห์ เพื่อลำดับขั้นตอนการหยุดการทำงานของโปรเซสอันตรายได้อย่างถูกต้อง (เช่น การเข้า Safe Mode หรือ Kill Process)

- **Attitude (เจตคติ):** มีสติและปฏิบัติตามขั้นตอนการรับมือเหตุการณ์ละเมิดความมั่นคงปลอดภัย (Incident Response) อย่างเป็นระบบ

**Puzzle 8: เลือก Version History และ 3-2-1 Backup (กู้ข้อมูลอย่างปลอดภัย)**

- **Knowledge (ความรู้):** ผู้เล่นเข้าใจหลักการสำรองข้อมูลแบบ 3-2-1 (มีข้อมูล 3 ชุด, เก็บในสื่อ 2 ประเภทที่ต่างกัน, เก็บออฟไซต์ 1 ชุด)

- **Skills (ทักษะ):** ผู้เล่นสามารถเลือกจุดกู้คืน (Recovery Point) จาก Version History ได้อย่างปลอดภัย โดยไม่ทำให้ไฟล์ที่สำรองไว้ติดเชื้อมัลแวร์ซ้ำ

- **Attitude (เจตคติ):** เห็นคุณค่าของการทำ Backup อย่างสม่ำเสมอ และตระหนักว่านี่คือเกราะป้องกันสุดท้ายที่เชื่อถือได้มากที่สุด
