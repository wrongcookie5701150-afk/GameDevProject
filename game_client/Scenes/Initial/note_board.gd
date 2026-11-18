class_name NoteBoardUI
extends Control

## หน้าต่าง UI แสดงกระดานเบาะแส & องค์ความรู้
## (Knowledge Notes & Investigation Clues NoteBoard)

signal closed()

@onready var close_button: Button = get_node_or_null("BoardArea/CloseButton")
@onready var pin_notes_button: Button = get_node_or_null("BoardArea/PinNotesButton")
@onready var title_label: Label = get_node_or_null("BoardArea/TitleLabel")

# Inspect Modal
@onready var inspect_modal: Panel = get_node_or_null("InspectModal")
@onready var modal_title_label: Label = get_node_or_null("InspectModal/ModalVBox/ModalHeader/ModalTitleLabel")
@onready var modal_content_label: Label = get_node_or_null("InspectModal/ModalVBox/ModalScroll/ModalContentLabel")
@onready var modal_close_top_btn: Button = get_node_or_null("InspectModal/ModalVBox/ModalHeader/ModalCloseTopBtn")
@onready var modal_confirm_btn: Button = get_node_or_null("InspectModal/ModalVBox/ModalFooter/ModalConfirmBtn")

# Post-it buttons and labels (8 sheets)
var postit_buttons: Array[Button] = []
var postit_labels: Array[Label] = []

const POSTITS: Array[Dictionary] = [
	{
		"required_note": "note_forensic_prep",
		"panel_title": "1. Forensic Image",
		"panel_preview": "สำเนาหลักฐาน\n- Read-only ไดรฟ์แยก\n- Chain of Custody\n[คลิกเพื่อ Inspect 🔍]",
		"detail_title": "📌 แผ่นที่ 1: Forensic Image & Chain of Custody",
		"detail_content": "• Forensic Image คืออะไร?\nการทำสำเนาข้อมูลแบบ Bit-by-Bit จากดิสก์ต้นฉบับ โดยไม่เปิดไฟล์หรือแก้ไขข้อมูลบนเครื่องที่ติดมัลแวร์โดยตรง\n\n• เหตุผลที่ต้องใช้ไดรฟ์แยก (EV-DRIVE):\nป้องกันไม่ให้มัลแวร์เขียนทับข้อมูลหรือแพร่กระจาย และรักษา Chain of Custody (ห่วงโซ่การครอบครองพยานหลักฐานดิจิทัล) ให้มีความสมบูรณ์ถูกต้องตามหลักนิติวิทยาศาสตร์\n\n• ข้อควรระวัง:\nเครื่องที่ถูกโจมตีต้องตัดการเชื่อมต่อเครือข่ายทันที เพื่อไม่ให้ CloudSync ซิงค์ไฟล์ที่เสียหายขึ้นไประบบคลาวด์",
		"bg_color": Color(0.99, 0.93, 0.65) # Pastel Yellow
	},
	{
		"required_note": "note_isolation_logs",
		"panel_title": "2. เต่าดำ (Isolated)",
		"panel_preview": "ระบบแยกส่วน\n- ไม่ต่อเน็ต / ออฟไลน์\n- ป้องกันมัลแวร์แพร่\n[คลิกเพื่อ Inspect 🔍]",
		"detail_title": "📌 แผ่นที่ 2: Isolated Environment (เต่าดำ)",
		"detail_content": "• ทำไมต้องใช้ 'เต่าดำ'?\nเป็นเครื่องโน้ตบุ๊กสำรองที่ไม่ต่ออินเทอร์เน็ต (Air-Gapped/Offline), ไม่ผูกบัญชีส่วนตัว และไม่มีไฟล์สำคัญ ทำให้มัลแวร์ไม่สามารถติดต่อ C2 Server หรือขโมยข้อมูลออกไปได้\n\n• หลักการ Sandbox / Isolation:\nการตรวจหลักฐานดิจิทัลต้องทำในระบบปิดที่ควบคุมได้ เพื่อความปลอดภัยสูงสุดของผู้ตรวจพิสูจน์และเครือข่าย",
		"bg_color": Color(0.85, 0.94, 0.99) # Pastel Blue
	},
	{
		"required_note": "note_isolation_logs",
		"panel_title": "3. MD5 Integrity",
		"panel_preview": "ลายนิ้วมือดิจิทัล\n- เทียบ Evidence Manifest\n- ยืนยันไฟล์แท้ 100%\n[คลิกเพื่อ Inspect 🔍]",
		"detail_title": "📌 แผ่นที่ 3: MD5 Hash Integrity",
		"detail_content": "• ค่า Hash คืออะไร?\nเสมือน 'ลายนิ้วมือดิจิทัล' ของไฟล์ คำนวณด้วยฟังก์ชันคณิตศาสตร์ (เช่น MD5, SHA-256) ซึ่งหากข้อมูลในไฟล์เปลี่ยนไปแม้แต่บิตเดียว ค่า Hash จะเปลี่ยนไปทันที\n\n• การยืนยันความสมบูรณ์ (Integrity):\nนำค่า MD5 ที่คำนวณได้จากไฟล์บน EV-DRIVE ไปเทียบกับค่าใน Evidence_Manifest.txt หากตรงกัน แสดงว่าหลักฐานไม่ถูกดัดแปลงหรือเสียหายระหว่างนำส่ง",
		"bg_color": Color(0.85, 0.94, 0.99) # Pastel Blue
	},
	{
		"required_note": "note_isolation_logs",
		"panel_title": "4. Event Log & Typo",
		"panel_preview": "วิเคราะห์ไทม์ไลน์\n- 19:02:10 WINWORD\n- @universcity ปลอม\n[คลิกเพื่อ Inspect 🔍]",
		"detail_title": "📌 แผ่นที่ 4: Event Log & Typosquatting",
		"detail_content": "• วิเคราะห์ Windows Event Log:\nEvent ID 4688 บันทึกเวลา 19:02:10 ที่ WINWORD.EXE ถูกเปิด และ 19:03:16 ที่ผู้ใช้กดยอมรับ 'Enable Content' จากนั้น 21:21:50 โปรเซสผิดปกติเริ่มทำงาน\n\n• เทคนิค Typosquatting:\nคนร้ายสะกดชื่อโดเมนให้คล้ายของจริงเพื่อหลอกเหยื่อ:\n- ของคนร้าย: @universcity.example (มีตัว 'c' เกินมา)\n- ของจริง: @university.example\nดังนั้นต้องสังเกตและตรวจเช็คการสะกดของอีเมลผู้ส่งทุกครั้ง!",
		"bg_color": Color(0.85, 0.94, 0.99) # Pastel Blue
	},
	{
		"required_note": "note_malware_payload",
		"panel_title": "5. Word Macro",
		"panel_preview": "โครงสร้างเอกสาร\n- โฟลเดอร์ word/\n- vbaProject.bin แฝง\n[คลิกเพื่อ Inspect 🔍]",
		"detail_title": "📌 แผ่นที่ 5: Word Macro (vbaProject.bin)",
		"detail_content": "• ไฟล์ .docx คือ ZIP Archive:\nสามารถแตกไฟล์ออกมาดูโครงสร้างภายในได้\n\n• vbaProject.bin:\nไฟล์ไบนารีในโฟลเดอร์ word/ ซึ่งเป็นที่เก็บโค้ด VBA Macro ที่ทำงานอัตโนมัติเมื่อกด Enable Content\n\n• ข้อควรระวัง:\nห้ามกด 'Enable Content' หรือ 'Enable Editing' ในเอกสารที่ได้รับจากแหล่งที่ไม่น่าเชื่อถือเด็ดขาด!",
		"bg_color": Color(0.99, 0.88, 0.88) # Pastel Red/Pink
	},
	{
		"required_note": "note_malware_payload",
		"panel_title": "6. Obfuscation",
		"panel_preview": "ถอดรหัสพรางโค้ด\n- Office_Update_Helper\n- โหมด FILE_WIPE\n[คลิกเพื่อ Inspect 🔍]",
		"detail_title": "📌 แผ่นที่ 6: Obfuscation (Base64/Hex) & FILE_WIPE",
		"detail_content": "• เทคนิค Obfuscation (การพรางโค้ด):\nคนร้ายซ่อนชื่อโปรเซสและคำสั่งด้วยการเข้ารหัส:\n- Base64: T2ZmaWNlX1VwZGF0ZV9IZWxwZXI= ถอดรหัสได้ 'Office_Update_Helper'\n- Hex: 46494C455F57495045 ถอดรหัสได้ 'FILE_WIPE'\n\n• พฤติกรรมของมัลแวร์:\nมัลแวร์จะเปลี่ยนนามสกุลไฟล์เป็น .locked และเขียนทับข้อมูลเพื่อขู่กรรโชก (Ransomware/Wiper)",
		"bg_color": Color(0.99, 0.88, 0.88) # Pastel Red/Pink
	},
	{
		"required_note": "note_persistence_stop",
		"panel_title": "7. ตัด Persistence",
		"panel_preview": "ลำดับ Safe Mode\n- ปิด Task & Registry\n- ลบ Helper.dat 7 ขั้น\n[คลิกเพื่อ Inspect 🔍]",
		"detail_title": "📌 แผ่นที่ 7: 7-Step Persistence Containment",
		"detail_content": "• ทำไมต้องมีขั้นตอนที่ถูกต้อง?\nหากไม่ตัดวงจรฝังตัวก่อน มัลแวร์จะทำงานซ้ำเมื่อเปิดเครื่องใหม่\n\n• ลำดับ 7 ขั้นตอนมาตรฐาน:\n1. บูตเข้า Safe Mode (ป้องกันเซอร์วิสแปลกปลอมรันอัตโนมัติ)\n2. สั่งหยุด Process มัลแวร์ (Office_Update_Helper)\n3. ปิด Scheduled Task ใน Task Scheduler\n4. ลบ Startup Registry Key (Run / RunOnce)\n5. ปิด Service มัลแวร์ใน msconfig / services.msc\n6. ลบไฟล์ไบนารีมัลแวร์ (Helper.dat)\n7. ตรวจสอบสถานะการเชื่อมต่อ Network และคงการ Isolate ไว้อยู่",
		"bg_color": Color(0.99, 0.92, 0.80) # Pastel Orange
	},
	{
		"required_note": "note_backup_recovery",
		"panel_title": "8. 3-2-1 Safe Backup",
		"panel_preview": "กฎสำรองข้อมูล\n- จุดกู้คืน 18:55\n- ปิด Cloud Sync ก่อน\n[คลิกเพื่อ Inspect 🔍]",
		"detail_title": "📌 แผ่นที่ 8: 3-2-1 Backup & Safe Recovery",
		"detail_content": "• กฎสำรองข้อมูล 3-2-1:\n- สำเนาข้อมูลอย่างน้อย 3 ชุด\n- เก็บในสื่อบันทึกข้อมูลต่างชนิดกันอย่างน้อย 2 แบบ (เช่น SSD และ Cloud)\n- เก็บสำเนาไว้นอกสถานที่ (Off-site / Cloud) อย่างน้อย 1 แห่ง\n\n• จุดเวลากู้คืน (Recovery Point):\nต้องเลือกจุดเวลาก่อนที่มัลแวร์จะเริ่มทำงาน (เช่น 18:55 น. ก่อนเปิดไฟล์เวลา 19:02 น.)\n\n• ปิด Cloud Sync ชั่วคราว:\nก่อนกู้คืนต้องปิด Cloud Sync เพื่อไม่ให้ไฟล์ .locked บนเครื่องไปซิงค์ทับไฟล์ดีบน Cloud!",
		"bg_color": Color(0.88, 0.96, 0.88) # Pastel Green
	}
]

var _opened_frame: int = -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if close_button and not close_button.pressed.is_connected(close_board):
		close_button.pressed.connect(close_board)
	
	if pin_notes_button and not pin_notes_button.pressed.is_connected(_on_pin_notes_pressed):
		pin_notes_button.pressed.connect(_on_pin_notes_pressed)
	
	if modal_close_top_btn and not modal_close_top_btn.pressed.is_connected(close_inspect_modal):
		modal_close_top_btn.pressed.connect(close_inspect_modal)
	
	if modal_confirm_btn and not modal_confirm_btn.pressed.is_connected(close_inspect_modal):
		modal_confirm_btn.pressed.connect(close_inspect_modal)
	
	_collect_postit_nodes()
	_connect_postits()
	refresh_board_notes()

func _collect_postit_nodes() -> void:
	postit_buttons.clear()
	postit_labels.clear()
	for i in range(8):
		var btn = get_node_or_null("BoardArea/NoteArea/PostIt_%d" % i) as Button
		if not btn:
			# Fallback if named differently
			btn = find_child("PostIt_%d" % i, true, false) as Button
		if btn:
			postit_buttons.append(btn)
			var lbl = btn.get_node_or_null("Label") as Label
			if not lbl:
				lbl = btn.find_child("Label", true, false) as Label
			postit_labels.append(lbl)

func _connect_postits() -> void:
	for i in range(postit_buttons.size()):
		var btn: Button = postit_buttons[i]
		var idx: int = i
		if btn and not btn.pressed.is_connected(_on_postit_clicked.bind(idx)):
			btn.pressed.connect(_on_postit_clicked.bind(idx))

func is_postit_unlocked(index: int) -> bool:
	if index < 0 or index >= POSTITS.size():
		return false
	var required: String = POSTITS[index]["required_note"]
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and "pinned_notes" in inv:
		return inv.pinned_notes.has(required)
	return false

func refresh_board_notes() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	var pinned_list: Array = []
	if inv and "pinned_notes" in inv:
		pinned_list = inv.pinned_notes

	# Update Pin button visibility / state
	if pin_notes_button:
		var has_inventory_notes: bool = false
		if inv and "slots" in inv:
			for s: Dictionary in inv.slots:
				if not s.is_empty() and String(s.get("id", "")).begins_with("note_"):
					has_inventory_notes = true
					break
		pin_notes_button.visible = has_inventory_notes

	for i in range(POSTITS.size()):
		if i >= postit_buttons.size() or i >= postit_labels.size():
			continue
		var btn: Button = postit_buttons[i]
		var lbl: Label = postit_labels[i]
		if not btn or not lbl:
			continue

		var postit_data: Dictionary = POSTITS[i]
		var is_unlocked: bool = pinned_list.has(postit_data["required_note"])

		if is_unlocked:
			# Apply active pastel sticky note style
			var style: StyleBoxFlat = StyleBoxFlat.new()
			style.bg_color = postit_data["bg_color"]
			style.border_color = Color(0.42, 0.35, 0.25, 0.85)
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
			style.corner_radius_top_left = 3
			style.corner_radius_top_right = 3
			style.corner_radius_bottom_right = 3
			style.corner_radius_bottom_left = 3
			style.shadow_color = Color(0, 0, 0, 0.3)
			style.shadow_size = 2
			style.content_margin_left = 4.0
			style.content_margin_top = 3.0
			style.content_margin_right = 4.0
			style.content_margin_bottom = 3.0
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_stylebox_override("hover", style)
			btn.add_theme_stylebox_override("pressed", style)

			lbl.text = "📌 %s\n%s" % [postit_data["panel_title"], postit_data["panel_preview"]]
			lbl.add_theme_color_override("font_color", Color(0.12, 0.08, 0.04, 1.0))
			btn.tooltip_text = "คลิกเพื่อเปิดอ่านสรุปองค์ความรู้ละเอียด"
		else:
			# Faded / Locked placeholder
			var style: StyleBoxFlat = StyleBoxFlat.new()
			style.bg_color = Color(0.55, 0.50, 0.42, 0.35)
			style.border_color = Color(0.45, 0.40, 0.32, 0.5)
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
			style.corner_radius_top_left = 3
			style.corner_radius_top_right = 3
			style.corner_radius_bottom_right = 3
			style.corner_radius_bottom_left = 3
			style.content_margin_left = 4.0
			style.content_margin_top = 3.0
			style.content_margin_right = 4.0
			style.content_margin_bottom = 3.0
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_stylebox_override("hover", style)
			btn.add_theme_stylebox_override("pressed", style)

			lbl.text = "[ ช่องว่างแปะโน้ต ]\n\n(สืบสวนหาหลักฐาน\nเพื่อปลดล็อก)"
			lbl.add_theme_color_override("font_color", Color(0.35, 0.28, 0.22, 0.6))
			btn.tooltip_text = "ยังไม่มีโน้ตแปะในช่องนี้ (สืบสวนเพื่อรวบรวมโน้ต)"

func _on_postit_clicked(index: int) -> void:
	if not is_postit_unlocked(index):
		return
	var postit_data: Dictionary = POSTITS[index]
	open_inspect_modal(postit_data["detail_title"], postit_data["detail_content"])

func open_inspect_modal(title_text: String, content_text: String) -> void:
	if not inspect_modal:
		return
	if modal_title_label:
		modal_title_label.text = title_text
	if modal_content_label:
		modal_content_label.text = content_text
	inspect_modal.show()

func close_inspect_modal() -> void:
	if inspect_modal:
		inspect_modal.hide()

func _on_pin_notes_pressed() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("pin_all_inventory_notes_to_board"):
		inv.pin_all_inventory_notes_to_board()
	refresh_board_notes()

func open_board() -> void:
	_opened_frame = Engine.get_process_frames()
	
	# Automatically pin any knowledge notes held in inventory upon opening board!
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("pin_all_inventory_notes_to_board"):
		inv.pin_all_inventory_notes_to_board()
	
	close_inspect_modal()
	refresh_board_notes()
	show()
	
	# Stop player movement while reviewing board
	var player = get_tree().root.find_child("Player", true, false)
	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(false)

func close_board() -> void:
	close_inspect_modal()
	hide()
	var player = get_tree().root.find_child("Player", true, false)
	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(true)
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if Engine.get_process_frames() == _opened_frame:
		return

	# Handle Inspect Modal dismissal first
	if inspect_modal and inspect_modal.visible:
		if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_Q or event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
			close_inspect_modal()
			get_viewport().set_input_as_handled()
			return

	# Handle board closing
	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_Q or event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
		close_board()
		get_viewport().set_input_as_handled()
