# Git Bash Guide for Collaborators

คู่มือการทำงานกับ GitHub Repository สำหรับ Collaborators โดยใช้ Git Bash เป็นหลัก

## Workflow

```text
Open Git Bash
    ↓
1. Clone Repository
    ↓
2. cd to Work Directory
    ↓
3. Pull main
    ↓
4. Open Issue
    ↓
5. Create Branch
    ↓
6. Add File / Edit Code
    ↓
7. Commit
    ↓
8. Push to Branch
    ↓
9. Create Pull Request
```

---

## 0. เปิด Git Bash

เปิด folder งาน -> คลิกขวา(win 11 เลือก **Show more options** ก่อน) เลือก **Open Git Bash here** 

ตรวจสอบ Git:

```bash
git --version
```

---

## 1. Clone Repository

Clone Repository จาก GitHub ลงเครื่อง กด code แล้วคัดลอก HTTPS มา

```bash
git clone [link HTTPS ที่คัดลอกมา]
```

ตัวอย่าง:

```bash
git clone https://github.com/wrongcookie5701150-afk/GameDevProject.git
```

> **หมายเหตุ:** ต้องมีสิทธิ์เข้าถึง Repository ก่อนจึงจะ Clone ได้

---

## 2. cd to Work Directory

เข้าไปยัง Folder ของ Repository ตรวจสอบว่าอยู่ถูก Folder:

```bash
pwd
```

และตรวจสอบ Git ว่ามีไฟล์อยู่ state ไหนบ้าง:

```bash
git status
```

---

## 3. Pull Main

ก่อนเริ่มงานทุกครั้ง ให้ดึง `main` ล่าสุดก่อน

```bash
git switch main
git pull origin main
```

เพื่อให้แน่ใจว่า Branch `main` ในเครื่องเป็นเวอร์ชันล่าสุดจาก GitHub

---

## 4. Open Issue

ไปที่ GitHub Repository แล้วสร้าง **Issue** สำหรับงานที่ต้องการทำ

ตัวอย่าง:

```text
Issue #25
Title:
Create Login System
```

รายละเอียด:

```text
- Create login form
- Validate username
- Validate password
- Display error message
```

จำหมายเลข Issue เช่น:

```text
#25
```

เพื่อนำไปเชื่อมกับ Branch และ Pull Request

---

## 5. Create Branch

กลับมาที่ Git Bash

สร้าง Branch สำหรับ Issue:

```bash
git switch -c feature/25-login
```

ตรวจสอบ Branch:

```bash
git branch
```

ผลลัพธ์:

```text
  main
* feature/25-login
```

`*` หมายถึง Branch ที่กำลังทำงานอยู่

### รูปแบบชื่อ Branch ที่แนะนำ

```text
feature/25-login
feature/26-pretest

fix/27-login-error

docs/28-documentation
```

---

## 6. Add File / Edit Code

สร้างหรือแก้ไขไฟล์ใน Work Directory ตามงานของ Issue

ตรวจสอบไฟล์ที่เปลี่ยน:

```bash
git status
```

ตัวอย่าง:

```text
modified: src/login.js
new file: src/login.css
```

ตรวจสอบรายละเอียดการแก้ (press q for quit):

```bash
git diff
```

เมื่อทำงานเสร็จ ให้เพิ่มไฟล์เข้า Staging Area:

```bash
git add .
```

ตรวจสอบอีกครั้ง:

```bash
git status
```

---

## 7. Commit

บันทึกการเปลี่ยนแปลงไว้ใน Local Repository โดยอ้างอิง Issue:

```bash
git commit -m "feat: add login system (#25)"
```

หากต้องการให้ GitHub ปิด Issue เมื่อ PR ถูก Merge สามารถใช้:

```bash
git commit -m "feat: add login system, closes #25"
```

ถ้าแค่อัพเดตไม่ต้องใส่ `closes`

> **Commit ยังไม่ได้ส่งขึ้น GitHub**

ตอนนี้งานอยู่ใน:

```text
Local Repository
```

---

## 8. Push to Branch

ส่ง Branch และ Commit ขึ้น GitHub

**ครั้งแรก**ที่ Push Branch:

```bash
git push -u origin feature/25-login
```

หลังจากนั้น หากมี Commit เพิ่ม:

```bash
git push
```

---

## 9. Send Pull Request

ไปที่ GitHub Repository

เลือก:

```text
Pull requests
    ↓
New pull request
```

เลือก:

```text
base: main
compare: feature/25-login
```

หรือ:

```text
feature/25-login → main
```

เขียนรายละเอียด Pull Request เช่น:

```text
## Changes

- Added login form
- Added username validation
- Added password validation
- Added error handling

## Related Issue

Closes #25
```

จากนั้นกด:

```text
Create pull request
```

---

# หลังจากส่ง Pull Request

status จะยังไม่เปลี่ยนจนกว่าจะถูก Approve

```text
Pull Request
     ↓
Code Review
     ↓
Approved
     ↓
Merge → main
```

หากต้องมีการแก้ไข:

```bash
# แก้ไฟล์

git add .

git commit -m "fix: update login validation"

git push
```

ไม่ต้องสร้าง Pull Request ใหม่

Commit ใหม่จะเข้า Pull Request เดิมโดยอัตโนมัติ

---

# หลัง Pull Request ถูก Merge

เมื่อ PR ถูก Merge เข้า `main`:

```text
feature/25-login
       ↓
    Pull Request
       ↓
      Merge
       ↓
      main
```

หาก Pull Request มี:

```text
Closes #25
```

GitHub จะปิด Issue #25 หลัง Merge

จากนั้นกลับมาอัปเดต `main` ในเครื่อง:

```bash
git switch main
git pull origin main
```

สามารถลบ Branch ที่ทำงานเสร็จแล้ว:

```bash
git branch -d feature/25-login
```

---

# Quick Reference

สำหรับงานหนึ่ง Issue ใช้คำสั่งหลักดังนี้:

```bash
# 1. Clone — ทำครั้งแรกเท่านั้น
git clone https://github.com/USERNAME/REPOSITORY.git

# 2. เข้า Repository
cd REPOSITORY

# 3. Update main
git switch main
git pull origin main

# 4. สร้าง Branch
git switch -c feature/25-login

# 5. ทำงาน / แก้ไขไฟล์

# 6. Stage
git add .

# 7. Commit
git commit -m "feat: add login system"

# 8. Push
git push -u origin feature/25-login

# 9. ไป GitHub → Create Pull Request
# feature/25-login → main
```

---

# จำง่าย ๆ

```text
CLONE
เอา Repository ลงเครื่อง
        ↓
CD
เข้า Folder
        ↓
PULL
เอา main ล่าสุด
        ↓
ISSUE
กำหนดว่าจะทำอะไร
        ↓
BRANCH
สร้างพื้นที่ทำงาน
        ↓
ADD
เตรียมไฟล์
        ↓
COMMIT
บันทึก Version
        ↓
PUSH
ส่ง Branch ขึ้น GitHub
        ↓
PULL REQUEST
ขอรวมงานเข้า main
        ↓
MERGE
รวมงาน
```

## คำสั่งที่ต้องจำ

```bash
git clone <repo-url>

cd <repo-folder>

git switch main
git pull origin main

git switch -c feature/<issue-number>-<name>

git add .

git commit -m "feat: <description>"

git push -u origin feature/<branch-name>
```

จากนั้นทำ **Pull Request บน GitHub**:

```text
feature/<branch-name>
        ↓
       main
```