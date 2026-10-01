# Story Board

## ตัวละคร
1. เมย์ - (ตัวหลัก) นักศึกษาปี2 ในสาขาคอมพิวเตอร์
2. เมษา - ตัวทวงงาน
3. มาร์ช - (ตัวช่วย) นักศึกษาใกล้จบ พี่ในชมรม CYBER

## เนื้อเรื่อง

### Scene 1: Cutscene เวลา 19.02 น.

เมย์กำลังใช้มือถือ เสียบหูฟังนอน และเปิดฟังเพลงผ่านลำโพง

! มีสายจากเมษาโทรเข้ามา
**เมษา** : “เมย์ เธอยังไม่ได้ส่งงานเลยนะ พรุ่งนี้จะเดดไลน์แล้ว”

**เมย์** : “โอ๊ะ !”

**เมษา** : “ฉันส่งข้อความไปบอกตั้งเยอะ เปิดอ่านด้วยละกัน”

**เมย์** : “เดี๋ยวส่งไป~”

---
### Scene 2 : Game Tutorial

เมย์ยืนข้างเตียง + (เสียงถอนหายใจ), notification <font color="#ff0000">+4 </font>

**เมย์** : "จริงๆ แล้วฉันยังไม่ได้เริ่มแก้อะไรนั่นเลย"

>- [ ] **Task 1: อ่านข้อความจากเมษา**
สอนผู้เล่นใช้มือถือ [p] = เรียกหน้ามือถือขึ้นมา และ Notification จะขึ้นที่มุมจอเสมอถ้ามีข้อความ ใช้กดแทน [p] ได้}
Trigger action: อ่านข้อความจากเมษา

! {Notification+4}
```text 
(today)
14:33 | Mesasohot131415: "เมย์"
14:33 | Mesasohot131415: "การบ้านเธอจำทำส่วนไหน"
17:47 | Mesasohot131415: "ฉันทำหมดแล้วล่ะ เหลือส่วนของรายงาน"
18:48 | Mesasohot131415: "ฮาโหลลลลลล มีใครอยู่มั้ย"
```

**เมย์** : "เมษาเป็นคนตลกนะ แต่ฉันทำงานไม่เสร็จก่อนวันพรุ่งนี้ เธอคงกลายเป็น IT"

>- [ ] **Task 2: ไปที่โต๊ะคอม และเข้าใช้งาน**
สอน player ควบคุมตัวละคร [W S A D]= move , [spacebar] = interact with object, 
[p] = เรียกหน้ามือถือขึ้นมา {Notification จะขึ้นที่มุมจอเสมอถ้ามีข้อความ ใช้กดแทน [p] ได้}
Trigger action: เดินไปใช้งานคอมพิวเตอร์ที่เปิดอยู่

แสดงหน้าจอคอมเปล่า มีไอคอนแอป (`GG Disk`, `text editor`,  `Recycle bin`, `Settings`)

> - [ ] **Task 3: เปิดไฟล์งาน**
สอนใช้เมาส์ interact กับ interface ในหน้าจอคอมพิวเตอร์ 
Trigger action: เปิดอ่านไฟล์งานใน `GG Disk` 

! กดเข้า `GG Disk`
**เมย์** : มีไฟล์รายงานงานอยู่ด้วย เพิ่งแก้ไม่ไปนานเลย เมษาคงรอไหว"

! กดโหลดและเปิดงาน + มีข้อความเตือนให้กด Enable Content
**เมย์** : "งานเก่าฉันคือสร้างไวรัสรึป่าวนะ XD"

เนื้อหาในไฟล์เป็นสรุปเรื่อง "ความปลอดภัยไซเบอร์" แวร์ต่างๆ การเข้ารหัส เนื้อหาคร่าวๆ เกี่ยวกับความรู้ในเกม

> - [ ] **Task 4: ทำรายงานต่อ**
(อาจขึ้นข้อความคล้าย type training)
แสดง cursor กระพริบที่บรรทัดสุดท้ายของรายงาน ให้ผู้เล่นกดมั่วๆ 
Trigger: พิมพ์เนื้อในรายงานเพิ่ม 300 คำ

---
### Scene 3: Cutscene เวลา 21.23 น.
(ไทม์แลป) เมย์กำลังพิมพ์เนื้อหารายงานเพิ่ม ในขณะที่มุมขวาล่างจอมีการแจ้งเตือนขึ้นมาแล้วก็หายไป
- ข่าวด่วนเรื่องอากาศร้อน
- การแจ้งเตือนจากเบราว์เซอร์เรื่อง “อัปเดตโปรแกรม”
- ป๊อปอัปจากโปรแกรมป้องกันไวรัสที่บอกว่า “ไม่พบภัยคุกคาม”

ตัดมาที่หน้ารวมไฟล์รายงานที่เมล์ทำเสร็จแล้ว 4 ไฟล์
```text
งานกลุ่มล้านแปด/
├── Report_Final.docx
├── Network_Diagram.png
├── Research_Data.xlsx
├── Presentation.pptx
```

**เมย์:** "เหลือแค่ upload files กลับก็เสร็จแล้ว"

หน้าต่าง Folder เป็นสีเทาพักหนึ่ง จากนั้นไฟล์งานที่ทำต่อท้ายด้วย `.locked`

! `README_TO_RECOVER_FILES.txt` เปิดขึ้นมากลางจอ 

```text
YOUR FILES HAVE BEEN ENCRYPTED.  
DO NOT MODIFY OR DELETE FILES.  
WAIT FOR FURTHER INSTRUCTIONS.
```

**เมย์:** "ท่าทางรายงานที่ฉันทำ จะปลอดภัยจริงๆ ...จากตัวฉันด้วย"

! ลองเปิดไฟล์ หน้าต่างโฟล์เดอร์จะเป็นสีเทาแล้วกลับมาที่ไฟล์ `.txt`

**เมย์:** "ท่าทางฉันคงต้องหาคนช่วย"

! {Notification+1}

```text
(today)
21:25 | M4rchupikchu_inw101: "Roblox ป่าวน้อง"
```

**เมย์:** "ทักมาได้จังหวะเหมาะมาก"

---
### Scene 4: เข้าสู่วิถีไซเบอร์

```text
(today)
21:25 | M4rchupikchu_inw101: "Roblox ป่าวน้อง"
21:26 | Mayicomeinpls: "พี่มาร์ชคะ คอมเปิดไฟล์ไม่ได้ค่ะ"
21:28 | M4rchupikchu_inw101: "ไฟล์อะไร"
21:28 | Mayicomeinpls: "ไฟล์ docx แล้ว .locked ค่ะ"
21:28 | M4rchupikchu_inw101: "ยังไงนะ ถ่ายรูปมาหน่อย"
21:29 | Mayicomeinpls: send a picture
21:30 | M4rchupikchu_inw101: "อืมม ตัดเน็ตคอมพิวเตอร์ก่อน"
```

! มือถือสายเข้าจากมาร์ช

**มาร์ช:** "ยังมีเต่าดำอยู่ใช่มั้ย"

**เมย์:** "ยังอยู่ค่ะ"

(Cutscene) ไปที่ Notebook เก่าสีดำลายเต่า

**มาร์ช:** "นั่น ทำไมไม่เอาไปคืน"

**เมย์:** ".."

**มาร์ช:** "มาเช็คสภาพกันก่อน"

interface ภายใน : `Settings`, `Recycle bin`, `Autopsy`, `FTK Image`, `HxD Hex Editor`ม `olevba`

> - [ ] **Task 5: เช็คสภาพเต่าดำ**
> - [ ] Wi‑Fi ปิดอยู่
> - [ ] ไม่เสียบสาย LAN
> - [ ] ไม่มีเชื่อมต่อบัญชีหรืออีเมลส่วนตัว
> - [ ] ไม่มีไฟล์งานสำคัญ

เมย์เปิดดูบันทึกเหตุการณ์ใน Event log

```text
## Windows Event Log

18:31:04 | explorer.exe started
18:34:19 | CloudSync.exe started
18:47:53 | SearchIndexer.exe started

18:58:07 | Report_Final.docx appeared in shared folder
18:58:07 | Shared by: kim.studygroup@university.example
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

**มาร์ช:** "มีเหตุการณ์ถูกบันทึกไว้เยอะมาก พอจำได้มั้ยว่าทำอะไรก่อนไฟล์จะล็อกไป"

> - [ ] **Task 7: ขีดเส้นแบ่งเวลา**
> - ให้ผู้เล่นคลิ๊กโปรเซสที่เป็นจุดเริ่มต้นจนถึงจุดที่เกิดเหตุการณ์
> - Trigger: `19:02:10` ถูกคลิ๊ก
> - Hint (wait 5sec.): **เมย์:** “บางทีฉันอาจลองเช็คจากเวลาโทรของเมษาได้”
> - action: เวลาถูกจดลงในโน็ตข้างๆ + (เสียงเขียนดินสอ)

**เมย์:** “เริ่มต้นจากไฟล์ Report_Final.docx เมษาแก้เค้นฉันที่ไม่ทำงานรรึป่าวนะ”

**มาร์ช:**“ลองเช็คที่มาของไฟล์กันก่อน”

```text
## Drive Activity History

18:54 | `Network_Diagram.png` appeared in shared folder  
18:54 | Shared by: mesa.sukj@university.example  
18:54 | Owner: Mesa Sukjai  
18:54 | File type verified: PNG image  
18:54 | Status: Normal file activity  

18:56 | `Research_Data.xlsx` appeared in shared folder  
18:56 | Shared by: mesa.sukj@university.example  
18:56 | Owner: Mesa Sukjai  
18:56 | File type verified: Microsoft Excel Workbook  
18:56 | Status: Normal file activity  

18:57 | `Presentation.pptx` appeared in shared folder  
18:57 | Shared by: mesa.sukj@university.example  
18:57 | Owner: Mesa Sukjai  
18:57 | File type verified: Microsoft PowerPoint Presentation  
18:57 | Status: Normal file activity  

18:58 | `Report_Final.docx` appeared in shared folder  
18:58 | Shared by: mesasohot.sukj@universcity.example  
18:58 | Owner: External collaborator  
18:58 | File type displayed: Microsoft Word Document  
18:58 | Internal file inspection: Macro-enabled content detected  
18:58 | Status: Suspicious file activity  

19:02 | `Report_Final.docx` opened by: May  
19:03 | Active Content enabled by: May  
```

> - [ ] **Task 8: คนร้ายนั้นก็คือ..**
> - ให้ผู้เล่นเปิดประวัติบน `GG Disk` เพื่ออ่านรายการเปลี่ยนแปลง
> - Trigger: `Report_Final.docx` ถูกคลิ๊ก
> - hint (wait 6 sec.): **มาร์ช**“โดนเมษาโซฮอตแอตยูนิเวิร์สหลอกซะแล้ว”
> - action: `Report_Final.docx` ถูกจดลงในโน็ตข้างๆ + (เสียงเขียนดินสอ)

**เมย์:** “เธอไม่ได้ส่งไฟล์นี้มาหรอเนี้ย”

**มาร์ช:**“เอาล่ะได้เวลาวิเคราะห์หลักฐานแล้ว ยังมี `EV Drive` มั้ย”

! เดินไปหา `EV Drive` จากชั้นหนังสือ แล้วมา Interact กับ คอมพิวเตอร์

---
### Scene 5: วิเคราะห์หลักฐาน
*Timelapse Cutscene:* เมย์กำลังสร้างสำเนาไฟล์หลักฐาน (Forensic)
(ตัดฉาก) เมย์ยืนข้างโต๊ะคอมพิวเตอร์

**เมย์:** “ทำสำเนาเสร็จเรียบร้อยแล้ว”

! ใช้ `EV Drive` interact กับ เต่าดำ

ไฟล์ EV ที่เมย์ทำมา
```text
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

> - [ ] **Task 9: เปิดโปงสปาย**
> - ให้ผู้เล่นใช้โปรแกรมเปิดเอกสารแบบ Read-only
> - Trigger: `Report_Final.docx` ถูกเปิดผ่านโปรแกรม `FTK Image`

ภายในไฟล์
```text
ชื่อไฟล์:
Final_Report_Revision_v4.docx

ชนิดไฟล์ที่ตรวจพบ:
Word Macro-Enabled Document

รายการภายใน:
word/document.xml
word/vbaProject.bin
word/_rels/document.xml.rels
```

**เมย์:** “มันชื่อ `.docx` แต่ข้างในมี `vbaProject.bin`”

**มาร์ช**“มาแกะดูข้างในกันดีกว่า” /ใช้ `olavba` เปิดอ่านไฟล์ VBA

```text
Macro project found
Module: OfficeUpdate
Trigger: Document_Open
Encoded value: T2ZmaWNlX1VwZGF0ZV9IZWxwZXI=
```

**มาร์ช**“ลองดูรายละเอียดพวกนี้ว่าแต่ละอันคืออะไร”

> - [ ] **Task 10: จับคู่ไฟล์กับราะละเอียด**
> - แสดงหน้าต่างจับคู่ขึ้นมา(กระดาษทดของเมย์) 3-3
> - Trigger: รายการทั้งหมดถูกจับคู่ได้ถูกต้อง

**เมย์:** “มีรหัสอะไรสักอย่างด้วยถูกเข้ารหัสไว้”

> - [ ] **Task 11: ถอดรหัส Base64**
> - ให้ผู้เล่นใช้เครื่องมือถอดรหัสเลขฐาน (decoder)
> - Trigger: section ถอดรหัสของโปรแกรมได้รับรหัส Base64 มา
> - Hint (wait 4 sec.): **มาร์ช**“มี `=` ต่อท้าย ดูเหมือนจะเป็น Base64 นะ ”
> - action: ส่งคำแปลออกไป `Office_Update_Helper` จดลงโน็ต

**เมย์:** “คือไฟล์ที่ถูกสร้างหลังจาก Enable Content ”

**มาร์ช**“เบื้องหลังงของไฟล์คงมีคำตอบอยู่”

> - [ ] **Task 12: เปิดหลักฐาน**
> - ให้ผู้เล่นเปิดไฟล์ `Office_Update_Helper.dat` ผ่าน inspector
> - Trigger: inspector ได้รับไฟล์ `Office_Update_Helper.dat` 
> - Hint (wait 4 sec.): **เมย์:**“ตัว inspector อยู่ตรง.. ”
> - action: ส่งหน้า file `Office_Update_Helper.txt`

```text
## Office_Update_Helper.dat

TARGET: UHJvamVjdF9Gb2xkZXI= //Project_Folder
MODE: 526B6C4D5256395853564246 //FILE_WIPE
STATUS: ACTIVE
```

> - [ ] **Task 12: ถอดรหัส**
> - ให้ผู้เล่นถอดรหัส TARGAT, MODE ผ่าน decoder
> - Trigger: inspector ได้รับไฟล์ รหัสครบทั้งสองชุด
> - Hint (wait 4 sec.): **เมย์:**“ตัว decoder อยู่ตรง.. ”
> - action: ส่งคำแปลแต่ละตัวกลับคืน

! ตรสจไฟล์ที่ถูกเปลี่ยนชื่อ

```text
## File Inspector

Filename: Report_Final.docx.locked
File size: 0 KB
File signature: Not found
Office document structure: Not found
Recoverable content: Not found
```

**เมย์:**“ถึงว่าเปิดไฟล์ไม่ได้ ”

**มาร์ช**“ตอนนี้คงเราไม่ต้องหาคีย์มาปลดแล้ว แค่ต้องหยุดการทำลายไฟล์”

```text
## Task Details

Task Name: Office_Update_Helper
Created by: WINWORD.EXE
Location: Temp\Office_Update_Helper.dat

Triggers:
- User logon
- User idle for 15 minutes
- Network connection available

Action:
- Start Office_Update_Helper
```

```text
## Event Log
20:59:12 | User idle detected
21:21:50 | Office_Update_Helper started
21:22:04 | Project files modified
21:23:21 | CloudSync.exe queued 3 changed files

```

> - [ ] **Task 13: การหยุด macro**
> - ให้ผู้เล่นเรียงลำดับขัั้นตอนหยุดยั้งการทำงานของไฟล์มาโคร โดยพิจารณาจาก `Task_Details.txt` เทียบกับ `Event_log`
> - Trigger: ผู้เล่นเรียงลำดับได้ถูกต้อง
> - Hint (wait 4 sec.): **เมย์:**“นึกเหตุการณ์และพึมพำ ”
> - ใช้เงื่อนไขเพื่อ activate คำใบ้ไปเรื่อยๆ
> - action: **มาร์ช**“เท่านี้ก็เพียงพอจะไม่ Trigger เงื่อนไขขึ้นมาแล้ว”

### Scene 6: วิเคราะห์หลักฐาน
*Timelapse Cutscene:* เมย์ลุกขึ้นกลับไป Settings ที่คอมพิวเตอร์หลัก
(ตัดฉาก) หน้าจอรายงานที่ว่างเปล่า

**เมย์:**“ถ้าต้องทำใหม่ตั้งแต่ต้น คงมีตกหล่นไปบ้างแน่ๆ”

**มาร์ช**“ไฟส่วนล์ที่เสียหาย ถ้าจำไม่ผิด `GG Disk` น่าจะ Backup ตามช่วงเวลาไว้อยู่”

```text
## Project Folder Version History

18:40 | Report_Final.docx | Normal version
18:54 | Network_Diagram.png | Normal version
18:56 | Research_Data.xlsx | Normal version
18:57 | Presentation.pptx | Normal version

21:22 | Report_Final.docx.locked | Suspicious change
21:22 | Research_Data.xlsx.locked | Suspicious change
21:22 | Presentation.pptx.locked | Suspicious change
```

> - [ ] **Task 14: Safe Backup**
> - ให้ผู้เล่นทำเลือกการตั้งค่าเพื่อ backup ข้อมูลอย่างปลอดภัย
> - Trigger: ผู้เล่นเรียงลำดับได้ถูกต้อง
> - Hint (wait 4 sec.): **เมย์:**“นึกเหตุการณ์และพึมพำ ”
> - ใช้เงื่อนไขเพื่อ activate คำใบ้ไปเรื่อยๆ
> - action: **มาร์ช**“เท่านี้ก็เพียงพอจะไม่ Trigger เงื่อนไขขึ้นมาแล้ว”

```text
Recovery point:
[✓] ก่อน 19:02
[ ] หลัง 21:22

Recovery destination:
[✓] โฟลเดอร์ใหม่
[ ] โฟลเดอร์เดิมทันที

Cloud Sync:
[ ] เปิด
```

**เมย์:**“ก็ยังดีกว่าเริ่มใหม่”

> - [ ] **Task 15: The Last Boss**
> - ให้ผู้เล่นช่วยเมย์เติมคำลงในรายงาน
> - Trigger: การกด save
> - action: **เมย์:**“ได้นอนสักที”


## รวม Puzzle

| Puzzle | ผู้เล่นทำอะไร                    | สิ่งที่เรียนรู้                          |
| ------ | -------------------------------- | ---------------------------------------- |
| 1      | ตรวจ Drive History               | ตรวจผู้ส่งและไฟล์ปลอม                    |
| 2      | อ่าน Windows Event Log           | หา Timeline, process ต้องสงสัย และ Scope |
| 3      | ตรวจโครงสร้างไฟล์                | พบ Macro ที่ซ่อนในเอกสาร                 |
| 4      | ถอด Base64 จาก Macro             | เชื่อม Macro กับ `Office_Update_Helper`  |
| 5      | ถอด Hex และ Base64 จาก Helper    | รู้ว่าไฟล์ถูกล้าง ไม่ใช่เข้ารหัส         |
| 6      | ปิด persistence และหยุด Sync     | กำจัดต้นเหตุก่อนกู้ข้อมูล                |
| 7      | เลือก Version History ที่ปลอดภัย | กู้ข้อมูลโดยไม่ถูกทำลายซ้ำ               |