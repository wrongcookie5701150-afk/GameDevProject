class_name NoteBoardUI
extends Control

## หน้าต่าง UI แสดงกระดานเบาะแส & คำตอบสำหรับแก้ไข Puzzle
## (Investigation Clues & Puzzle Answers Board)

signal closed()

@onready var close_button: Button = get_node_or_null("BoardArea/CloseButton")
@onready var title_label: Label = get_node_or_null("BoardArea/TitleLabel")

# โน้ตกระดาษแปะเบาะแส 5 แผ่น
@onready var label1: Label = get_node_or_null("BoardArea/NoteArea/Panel/Label")
@onready var label2: Label = get_node_or_null("BoardArea/NoteArea/Panel2/Label")
@onready var label3: Label = get_node_or_null("BoardArea/NoteArea/Panel3/Label")
@onready var label4: Label = get_node_or_null("BoardArea/NoteArea/Panel4/Label")
@onready var label5: Label = get_node_or_null("BoardArea/NoteArea/Panel5/Label")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_notes_content()
	
	if close_button:
		close_button.pressed.connect(close_board)

func _setup_notes_content() -> void:
	# โน้ตที่ 1: ไทม์ไลน์เวลาสำคัญที่เกิดเหตุการณ์
	if label1:
		label1.text = "🕒 ไทม์ไลน์เวลาเกิดเหตุ\n18:58: ไฟล์เข้า Folder\n19:02:10: เปิด Word\n19:03:16: Enable Content\n21:21:50: Helper เริ่มรัน"

	# โน้ตที่ 2: ชื่อไฟล์ตัวปัญหา
	if label2:
		label2.text = "📁 ไฟล์ตัวปัญหา\nชื่อ: Report_Final.docx\nประเภท: Macro Document\nแชร์มาจาก: Google Drive\n(มีโค้ดมัลแวร์แฝงอยู่!)"

	# โน้ตที่ 3: อีเมลและโดเมนคนร้าย (Typosquatting)
	if label3:
		label3.text = "📧 อีเมลคนร้าย (ปลอม)\nmesasohot.sukj@\nuniverscity.example\n*สังเกตตัว 'c' เกิน!\nของจริง: @university.example"

	# โน้ตที่ 4: ชื่อ Helper แฝง และโหมดมัลแวร์ (Decoder)
	if label4:
		label4.text = "🔍 มัลแวร์ที่ฝังตัว\nHelper:\nOffice_Update_Helper\nโหมดรัน: FILE_WIPE\nเป้าหมาย: ลบไฟล์ใน Project"

	# โน้ตที่ 5: หลักฐาน & การกู้คืน (Backup & Forensic)
	if label5:
		label5.text = "🛡️ การสืบสวน & กู้คืน\n- เต่าดำ: โน้ตบุ๊กออฟไลน์\n- EV Drive: แฟลชไดรฟ์หลักฐาน\n- Backup: กฎ 3-2-1\n- Hash: MD5 ยืนยันไฟล์"

func open_board() -> void:
	show()
	# หยุดการเดินของตัวละครขณะเปิดอ่านกระดาน
	var player = get_tree().root.find_child("Player", true, false)
	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(false)

func close_board() -> void:
	hide()
	# คืนการควบคุมให้ตัวละครเดินต่อได้
	var player = get_tree().root.find_child("Player", true, false)
	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(true)
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_Q or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
		close_board()
		get_viewport().set_input_as_handled()
