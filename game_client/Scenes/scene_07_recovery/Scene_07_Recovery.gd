extends Control

const MAIN_MENU_PATH: String = "res://ui/menus/MainMenu.tscn"

@onready var desktop_screen: Control = $CanvasLayer/DesktopScreen
@onready var stage_label: Label = $CanvasLayer/StageBanner/StageLabel
@onready var backup_puzzle: BackupRecoveryPuzzle = $CanvasLayer/Puzzle_321_Backup
@onready var report_puzzle: IncidentReportPuzzle = $CanvasLayer/Puzzle_Last_Boss_Summary
@onready var evaluation_ui: KsaEvaluation = $CanvasLayer/KSA_Evaluation_UI

var knowledge_panel: PanelContainer = null

func _ready() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("hide_inventory"):
		inv.hide_inventory()

	if desktop_screen:
		desktop_screen.set_process_unhandled_input(false)
		desktop_screen.set_process_input(false)
		if desktop_screen.has_method("set_wifi_connected"):
			desktop_screen.call("set_wifi_connected", false)
		var clock_lbl: Label = desktop_screen.find_child("ClockLabel", true, false) as Label
		if clock_lbl:
			clock_lbl.text = "22:15"
		var leave_btn: Button = desktop_screen.find_child("LeavePCButton", true, false) as Button
		if leave_btn:
			leave_btn.hide()
		var start_leave_btn: Button = desktop_screen.find_child("StartMenuLeaveBtn", true, false) as Button
		if start_leave_btn:
			start_leave_btn.hide()
		var icons_box: Control = desktop_screen.find_child("IconsContainer", true, false) as Control
		if icons_box:
			icons_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			for child in icons_box.find_children("*", "Button", true, false):
				if child is Button:
					(child as Button).disabled = true
					(child as Button).mouse_filter = Control.MOUSE_FILTER_IGNORE

	report_puzzle.hide()
	evaluation_ui.hide()
	backup_puzzle.show()
	backup_puzzle.start_puzzle()

	backup_puzzle.puzzle_resolved.connect(_on_backup_recovered)
	report_puzzle.puzzle_resolved.connect(_on_report_submitted)
	evaluation_ui.puzzle_resolved.connect(_on_evaluation_acknowledged)
	stage_label.text = "💻 เครื่อง PC ของเมย์: ขั้นตอนที่ 1/2 - กู้คืนข้อมูลจาก 3-2-1 Backup (เลือกเวลาก่อนติดมัลแวร์ 19:02)"

func _on_backup_recovered() -> void:
	backup_puzzle.hide()
	report_puzzle.show()
	report_puzzle.start_puzzle()
	stage_label.text = "📝 เครื่อง PC ของเมย์: ขั้นตอนที่ 2/2 - กู้คืนข้อมูลสำเร็จ! นั่งทำรายงานสรุปเหตุการณ์ให้เสร็จ"

func _on_report_submitted() -> void:
	report_puzzle.hide()
	_show_key_knowledge_summary()

func _show_key_knowledge_summary() -> void:
	if not knowledge_panel:
		knowledge_panel = PanelContainer.new()
		knowledge_panel.name = "KeyKnowledgeSummaryPanel"
		knowledge_panel.z_index = 60

		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.06, 0.09, 0.15, 0.98)
		panel_style.border_color = Color(0.3, 0.7, 1.0, 0.95)
		panel_style.border_width_left = 1
		panel_style.border_width_top = 2
		panel_style.border_width_right = 1
		panel_style.border_width_bottom = 1
		panel_style.corner_radius_top_left = 6
		panel_style.corner_radius_top_right = 6
		panel_style.corner_radius_bottom_right = 6
		panel_style.corner_radius_bottom_left = 6
		panel_style.content_margin_left = 12
		panel_style.content_margin_top = 8
		panel_style.content_margin_right = 12
		panel_style.content_margin_bottom = 8
		knowledge_panel.add_theme_stylebox_override("panel", panel_style)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 5)
		knowledge_panel.add_child(vbox)

		var title := Label.new()
		title.text = "📚 สรุปองค์ความรู้สำคัญ 4 สถานการณ์ (Key Knowledge Summary)"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1.0))
		title.add_theme_font_size_override("font_size", 9)
		vbox.add_child(title)

		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(380, 130)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		vbox.add_child(scroll)

		var body := Label.new()
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_theme_font_size_override("font_size", 7)
		body.text = """[Scenario 1: การเตรียมสภาพแวดล้อมสืบสวน (Isolation & Forensic Image)]
• ตัดการเชื่อมต่อ Wi-Fi และถอดสาย LAN ทันทีเพื่อป้องกันมัลแวร์แพร่กระจายไปยังเครื่องอื่น
• ทำ Forensic Image ลงแฟลชไดรฟ์แยกต่างหากเพื่อรักษาความสมบูรณ์ของหลักฐาน (Data Integrity)
• ตรวจสอบเครื่องวิเคราะห์ (เต่าดำ) ให้มั่นใจว่าไม่ล็อกอินบัญชีส่วนตัวและไม่มีไฟล์สำคัญ

[Scenario 2: การสืบสวนหลักฐานดิจิทัล (Digital Forensics Investigation)]
• ตรวจสอบ Windows Event Log เพื่อหาไทม์ไลน์ที่โปรเซสมัลแวร์เริ่มรัน (19:02)
• สังเกตเทคนิค Typosquatting (เช่น mesasohot.sukj@universcity.example มีตัวสะกดหลอก)
• ตรวจสอบค่า MD5 Hash กับ Manifest เพื่อยืนยันว่าหลักฐานไม่ถูกแก้ไข
• ตรวจสอบโครงสร้างไฟล์ Macro (.docx / vbaProject.bin) และถอดรหัส Base64/Hex เพื่อค้นหา Process มัลแวร์

[Scenario 3: การลองผิดลองถูกและกู้คืนระบบ (Trial-and-Error & Recovery)]
• การตัดวงจร Persistence ต้องเข้า Safe Mode ก่อน เพื่อบล็อกโปรเซสไม่ให้รันในหน่วยความจำ
• ปิด Scheduled Task และกักกันไฟล์มัลแวร์ก่อนกู้คืนไฟล์ มิเช่นนั้นมัลแวร์จะทำงานซ้ำและลบไฟล์ทันที
• กู้คืนข้อมูลสำรองตามกฎ 3-2-1 โดยเลือกจุดเวลาก่อนเกิดเหตุ (18:55) ลงไดรฟ์แยก และปิด Cloud Sync

[Scenario 4: การสรุปรายงานและป้องกันเชิงรุก (Ransomware Prevention)]
• ห้ามกด 'Enable Content' หรือเปิดใช้งาน Macro บนไฟล์เอกสารที่ไม่ทราบแหล่งที่มาชัดเจน
• ปฏิบัติตามนโยบายความปลอดภัยและตรวจสอบความถูกต้องของอีเมลผู้ส่งทุกครั้ง"""
		scroll.add_child(body)

		var next_btn := Button.new()
		next_btn.text = "ดูผลการประเมินทักษะ (Proceed to Skill Assessment) →"
		next_btn.custom_minimum_size = Vector2(0, 20)
		next_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		next_btn.add_theme_font_size_override("font_size", 8)
		next_btn.pressed.connect(_on_knowledge_summary_proceed)
		vbox.add_child(next_btn)

		var canvas = get_node_or_null("CanvasLayer")
		if canvas:
			canvas.add_child(knowledge_panel)
		else:
			add_child(knowledge_panel)

		knowledge_panel.set_anchors_preset(Control.PRESET_CENTER)
		knowledge_panel.offset_left = -200
		knowledge_panel.offset_right = 200
		knowledge_panel.offset_top = -95
		knowledge_panel.offset_bottom = 95

	knowledge_panel.show()
	stage_label.text = "📚 สรุปองค์ความรู้สำคัญ 4 ด้าน (Key Knowledge Summary) จากการรับมือ Ransomware"

func _on_knowledge_summary_proceed() -> void:
	if knowledge_panel:
		knowledge_panel.hide()
	evaluation_ui.show()
	evaluation_ui.start_puzzle()
	stage_label.text = "🎉 ทำรายงานเสร็จสมบูรณ์! สรุปผลการประเมินทักษะ (KSA Evaluation)"

func _on_evaluation_acknowledged() -> void:
	TelemetryManager.active_timers.clear()
	var result: Error = get_tree().change_scene_to_file(MAIN_MENU_PATH)
	if result != OK:
		push_error("Unable to return to the main menu: %s" % result)
