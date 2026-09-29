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
```tree
|-งานกลุ่มล้านแปด/
	|-Report_Final.docx
	|-Network_Diagram.png
	|-Research_Data.xlsx
	|-Presentation.pptx
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

Cutscene ไปที่ Notebook เก่าสีดำลายเต่า

**มาร์ช:** "นั่น ทำไมไม่เอาไปคืน"

**เมย์:** ".."

**มาร์ช:** "มาเช็คสภาพกันก่อน"

interface ภายใน : `Settings`, `Recycle bin`, `Autopsy`, `FTK Image`, `HxD Hex Editor`

> - [ ] **Task 5: เช็คสภาพเต่าดำ**
> - [ ] Wi‑Fi ปิดอยู่
> - [ ] ไม่เสียบสาย LAN
> - [ ] ไม่มีเชื่อมต่อบัญชีหรืออีเมลส่วนตัว
> - [ ] ไม่มีไฟล์งานสำคัญ

---

## Scene 4: Tracking Footprints

เมษาดูบันทึกเหตุการณ์ที่เก็บได้จากเครื่องหลัก โดยข้อมูลถูกสลับลำดับ

```text
21:23:08 | README_TO_RECOVER_FILES.txt created
19:03:16 | User selected Enable Content
21:22:39 | Report_Final.docx renamed to Report_Final.docx.locked
19:02:10 | WINWORD.EXE opened Final_Report_Revision_v4.docx
19:05:11 | New activity associated with WINWORD.EXE detected
19:05:32 | New logon item created: Office_Update_Helper
21:21:50 | Office_Update_Helper started
```

**มาร์ช:** "เริ่มจากดูว่าเกิดอะไรขึ้นก่อน"

> - [ ] **Task 6: ลำดับเหตุการณ์ที่เกิดขึ้น**  เริ่ม Analytics
ให้ผู้เล่นเรียงลำดับเหตุการณ์ตามช่วงเวลา
Trigger: เหตุการณ์ทั้งหมดถูกเรียงอย่างถูกต้อง

**มาร์ช:** "มีไฟล์ถูกสร้างขึ้นมาใหม่ด้วย ควรจะจำชื่อเอาไว้"

> - [ ] **Task 7: Log ต้องสงสัย**
ให้ผู้เล่นคลิ๊กชื่อโปรเซสที่น่าสงสัย
Trigger: `Office_Update_Helper` ถูกคลิ๊ก
action: `Office_Update_Helper` ถูกจดลงในโน็ตข้างๆ + (เสียงเขียนดินสอ)

**เมษา:** “ปัญหาไม่ได้เกิดตอนเปิด Word ทันที”

**มาร์ช**“ใช่ เอกสารอาจเป็นจุดเริ่ม แต่ต้องหาเพิ่มว่าอะไรที่ทำงานต่อหลังปิด Word”

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

> - [ ] **Task 8: เมษาโซฮอต**
ให้ผู้เล่นหาว่าไฟล์ตัวไหนที่ผิดปกติ
Trigger: `Report_Final.docx` ถูกคลิ๊ก
action: `Report_Final.docx` ถูกจดลงในโน็ตข้างๆ + (เสียงเขียนดินสอ)

hint: **มาร์ช**“โดนเมษาโซฮอตแอตยูนิเวิร์สหลอกซะแล้ว”

**เมย์:** “..”

**เมย์:** “เมษาไม่ได้ส่งไฟล์นี้มาหรอเนี้ย”

**มาร์ช**“มาดูกันว่าไฟล์นี้มี macro ได้ยังไงทั้งที่ไม่ใช่ `.docm`”

> - [ ] **Task 9: เปิดโปงสปาย**
ให้ผู้เล่นใช้โปรแกรมเปิดเอกสารแบบ Read-only
Trigger: `Report_Final.docx` ถูกเปิดผ่านโปรแกรม `FTK Image`

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