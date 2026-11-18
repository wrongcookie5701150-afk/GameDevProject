class_name BackupRecoveryPuzzle
extends BasePuzzleUI

const FONT_THAI: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

const CLEAN_VERSION: String = "before_1902"
const SEPARATE_DESTINATION: String = "external_drive"
const CLOUD_SYNC_DISABLED: String = "disabled"
const CLOUD_SYNC_ENABLED: String = "enabled"

@onready var panel_window: Panel = $Panel
@onready var top_header_bar: PanelContainer = $Panel/Content/TopHeaderBar
@onready var auto_sync_status_label: Label = find_child("AutoSyncStatusLabel", true, false) as Label
@onready var auto_sync_toggle_button: Button = find_child("AutoSyncToggleButton", true, false) as Button
@onready var version_list: ItemList = find_child("VersionList", true, false) as ItemList
@onready var version_detail_label: RichTextLabel = find_child("VersionDetailLabel", true, false) as RichTextLabel
@onready var destination_selector: OptionButton = find_child("DestinationSelector", true, false) as OptionButton
@onready var confirm_321_checkbox: CheckBox = find_child("Confirm321CheckBox", true, false) as CheckBox
@onready var restore_progress_bar: ProgressBar = find_child("RestoreProgressBar", true, false) as ProgressBar
@onready var feedback_label: Label = find_child("FeedbackLabel", true, false) as Label
@onready var submit_button: Button = find_child("SubmitButton", true, false) as Button

var _is_auto_sync_active: bool = true
var _sim_panel: PanelContainer = null
var _sim_output: RichTextLabel = null
var _sim_btn_retry: Button = null
var _sim_btn_continue: Button = null
var _is_simulating: bool = false

const VERSION_DATA: Array[Dictionary] = [
	{
		"id": "infected_1910",
		"display": "🔴 v4 | 19:10 น. | Report_Final.docx.locked (48 KB)",
		"detail": "[color=#ff4d4d]🔴 v4 (19:10 น.):[/color] แก้ไขโดย Auto-Sync หลังติด Ransomware! ไฟล์ถูกเข้ารหัส .locked เสียหายหมด หากกู้คืนเวอร์ชันนี้จะไม่ได้ข้อมูลคืน"
	},
	{
		"id": "infected_1905",
		"display": "🔴 v3 | 19:05 น. | Report_Final.docx [Macro Active] (47 KB)",
		"detail": "[color=#ff4d4d]🔴 v3 (19:05 น.):[/color] อัปโหลดโดย mesasohot.sukj@universcity.example มี Macro ไวรัสฝังตัว หากกู้คืนเวอร์ชันนี้ไวรัสจะทำงานซ้ำ"
	},
	{
		"id": "before_1902",
		"display": "🟢 v2 | 18:55 น. | Report_Final.docx [Verified Clean] (42.5 KB)",
		"detail": "[color=#00e676]🟢 v2 (18:55 น.):[/color] อัปโหลดโดย mesa.sukj@university.example ก่อนเกิดเหตุ! ไฟล์สะอาด ปลอดภัย 100% มีเนื้อหารายงานครบถ้วน"
	},
	{
		"id": "draft_outline",
		"display": "⚪ v1 | เมื่อวาน 20:30 น. | Report_Draft_Outline.docx (12 KB)",
		"detail": "[color=#cccccc]⚪ v1 (เมื่อวาน 20:30 น.):[/color] โครงร่างเปล่า Report_Draft_Outline.docx เนื้อหารายงานยังไม่ครบ"
	}
]

func _ready() -> void:
	hint_tier_1 = "ก่อนกู้คืน ต้องกดระงับ Auto-Sync เพื่อไม่ให้ระบบคลาวด์ซิงค์ไฟล์ .locked มาทับไฟล์ดี"
	hint_tier_2 = "เลือกจุดเวลาสะอาด v2 (18:55 น.) ก่อนเปิด Macro (19:02) และกู้คืนลง External Drive แยกต่างหากตามกฎ 3-2-1"
	hint_tier_3 = "กดปุ่ม 'ระงับ Auto-Sync' -> เลือกเวอร์ชัน v2 (18:55) -> เลือกปลายทาง Separate external recovery drive -> ติ๊กถูกกฎ 3-2-1 แล้วเริ่มกู้คืน"
	super._ready()

	# Hook draggable header
	var global_settings = get_node_or_null("/root/GlobalSettings")
	if global_settings and global_settings.has_method("make_window_draggable") and panel_window and top_header_bar:
		global_settings.make_window_draggable(panel_window, top_header_bar)

	_setup_version_list()
	_setup_destination_selector()

	if auto_sync_toggle_button:
		auto_sync_toggle_button.pressed.connect(_toggle_auto_sync)
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)
	if confirm_321_checkbox:
		confirm_321_checkbox.toggled.connect(func(_b: bool) -> void: mark_decision_started())

	_update_auto_sync_ui()

func _setup_version_list() -> void:
	if not version_list:
		return
	version_list.clear()
	for v in VERSION_DATA:
		var idx: int = version_list.add_item(str(v["display"]))
		version_list.set_item_metadata(idx, str(v["id"]))
	version_list.item_selected.connect(_on_version_selected)
	version_list.select(0)
	_on_version_selected(0)

func _setup_destination_selector() -> void:
	if not destination_selector:
		return
	destination_selector.clear()
	destination_selector.add_item("Original system drive (C:\\Users\\May\\Documents)")
	destination_selector.set_item_metadata(0, "original_drive")
	destination_selector.add_item("Separate external recovery drive (D:\\External + C:\\Clean)")
	destination_selector.set_item_metadata(1, SEPARATE_DESTINATION)
	destination_selector.select(0)
	destination_selector.item_selected.connect(func(_idx: int) -> void: mark_decision_started())

func _on_version_selected(index: int) -> void:
	mark_decision_started()
	if index >= 0 and index < VERSION_DATA.size() and version_detail_label:
		version_detail_label.text = str(VERSION_DATA[index]["detail"])

func _toggle_auto_sync() -> void:
	mark_decision_started()
	_is_auto_sync_active = !_is_auto_sync_active
	_update_auto_sync_ui()

func _update_auto_sync_ui() -> void:
	if auto_sync_status_label:
		if _is_auto_sync_active:
			auto_sync_status_label.text = "🔄 Auto-Sync: ACTIVE (เสี่ยงซิงค์ไฟล์เสีย!)"
			auto_sync_status_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
		else:
			auto_sync_status_label.text = "⏸️ Auto-Sync: PAUSED (ปลอดภัย)"
			auto_sync_status_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.55, 1.0))

	if auto_sync_toggle_button:
		if _is_auto_sync_active:
			auto_sync_toggle_button.text = "⏸️ กดเพื่อระงับ Auto-Sync"
		else:
			auto_sync_toggle_button.text = "▶️ เปิด Auto-Sync"

func _get_selected_version() -> String:
	if not version_list or version_list.get_selected_items().is_empty():
		return "infected_1910"
	var sel_idx: int = version_list.get_selected_items()[0]
	return str(version_list.get_item_metadata(sel_idx))

func _get_selected_destination() -> String:
	if not destination_selector or destination_selector.selected < 0:
		return "original_drive"
	return str(destination_selector.get_item_metadata(destination_selector.selected))

func validate_answer(answer: Variant) -> bool:
	if not answer is Dictionary:
		return false
	var selections: Dictionary = answer
	return (
		str(selections.get("version", "")) == CLEAN_VERSION
		and str(selections.get("destination", "")) == SEPARATE_DESTINATION
		and str(selections.get("sync", "")) == CLOUD_SYNC_DISABLED
	)

func get_submission_metrics() -> Dictionary:
	var ver: String = _get_selected_version()
	var dest: String = _get_selected_destination()
	var sync_val: String = CLOUD_SYNC_DISABLED if not _is_auto_sync_active else CLOUD_SYNC_ENABLED
	return {
		"selected_version": ver,
		"selected_destination": dest,
		"cloud_sync": sync_val,
		"recovery_point": ver,
		"isolated_sync": sync_val == CLOUD_SYNC_DISABLED
	}

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: RecoveryTelemetryParam = RecoveryTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "puzzle_submitted"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.metrics = metrics.duplicate(true)
	param.selected_version = str(metrics.get("selected_version", ""))
	param.separate_destination = str(metrics.get("selected_destination", "")) == SEPARATE_DESTINATION
	param.cloud_sync_disabled = str(metrics.get("cloud_sync", "")) == CLOUD_SYNC_DISABLED
	param.sync_metrics()
	return param

func on_solve_success() -> void:
	feedback_label.text = "✅ กู้คืนสำเร็จ: ดึงไฟล์ v2 (18:55 น.) ลงไดรฟ์แยกและระงับ Cloud Sync ตามกฎ 3-2-1 ปลอดภัย 100%!"
	if restore_progress_bar:
		restore_progress_bar.value = 100
	_set_controls_disabled(true)

func on_solve_failed() -> void:
	var ver: String = _get_selected_version()
	var dest: String = _get_selected_destination()

	if _is_auto_sync_active:
		feedback_label.text = "💥 [ล้มเหลว]: เปิด Auto-Sync ทิ้งไว้! Cloud ซิงค์ไฟล์ .locked ลงมาทับไฟล์สะอาดทันที!"
		return

	if ver != CLEAN_VERSION:
		feedback_label.text = "💥 [ล้มเหลว]: เวอร์ชันที่เลือกติดมัลแวร์หรือยังไม่สมบูรณ์! ต้องเลือกสแนปช็อตก่อนเวลา 19:02 น."
		return

	if dest != SEPARATE_DESTINATION:
		feedback_label.text = "⚠️ [ล้มเหลว]: กู้คืนลงไดรฟ์เดิมที่เพิ่งติดมัลแวร์ เสี่ยงเขียนทับซ้ำ! ต้องใช้ Separate external recovery drive!"
		return

	feedback_label.text = "❌ การตั้งค่ายังไม่ปลอดภัย กรุณาตรวจสอบกฎ 3-2-1 แล้วทดสอบใหม่"

func _on_submit_pressed() -> void:
	mark_decision_started()
	if _is_simulating:
		return
	_build_or_show_sim_console()
	_run_recovery_simulation()

# ---------------------------------------------------------------------------
# Live Trial-and-Error Simulation Console (T13)
# ---------------------------------------------------------------------------
func _build_or_show_sim_console() -> void:
	if not _sim_panel:
		_sim_panel = PanelContainer.new()
		_sim_panel.name = "LiveBackupSimulationConsole"
		_sim_panel.custom_minimum_size = Vector2(380, 180)
		_sim_panel.set_anchors_preset(Control.PRESET_CENTER)
		_sim_panel.offset_left = -190.0
		_sim_panel.offset_top = -90.0
		_sim_panel.offset_right = 190.0
		_sim_panel.offset_bottom = 90.0
		_sim_panel.z_index = 50

		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.05, 0.07, 0.12, 0.98)
		sb.border_width_left = 1
		sb.border_width_top = 2
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(0.2, 0.7, 1.0, 0.95)
		sb.corner_radius_top_left = 4
		sb.corner_radius_top_right = 4
		sb.corner_radius_bottom_right = 4
		sb.corner_radius_bottom_left = 4
		sb.content_margin_left = 8.0
		sb.content_margin_top = 6.0
		sb.content_margin_right = 8.0
		sb.content_margin_bottom = 6.0
		sb.shadow_size = 6
		_sim_panel.add_theme_stylebox_override("panel", sb)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		_sim_panel.add_child(vbox)

		var title_lbl := Label.new()
		title_lbl.text = "🖥️ Live Simulation Console: จำลองการกู้คืนข้อมูลสำรอง 3-2-1 Backup Engine"
		title_lbl.add_theme_font_override("font", FONT_THAI)
		title_lbl.add_theme_font_size_override("font_size", 6)
		title_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1, 1))
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(title_lbl)

		_sim_output = RichTextLabel.new()
		_sim_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_sim_output.bbcode_enabled = true
		_sim_output.scroll_following = true
		_sim_output.add_theme_font_override("normal_font", FONT_MONO)
		_sim_output.add_theme_font_size_override("normal_font_size", 5)
		_sim_output.add_theme_color_override("default_color", Color(0.9, 0.95, 1, 1))
		var out_sb := StyleBoxFlat.new()
		out_sb.bg_color = Color(0.02, 0.03, 0.05, 1)
		out_sb.border_width_left = 1
		out_sb.border_width_top = 1
		out_sb.border_width_right = 1
		out_sb.border_width_bottom = 1
		out_sb.border_color = Color(0.15, 0.25, 0.35, 1)
		out_sb.content_margin_left = 6.0
		out_sb.content_margin_top = 4.0
		out_sb.content_margin_right = 6.0
		out_sb.content_margin_bottom = 4.0
		_sim_output.add_theme_stylebox_override("normal", out_sb)
		vbox.add_child(_sim_output)

		var btn_hbox := HBoxContainer.new()
		btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		btn_hbox.add_theme_constant_override("separation", 8)
		vbox.add_child(btn_hbox)

		_sim_btn_retry = Button.new()
		_sim_btn_retry.text = "🔄 ย้อนกลับไปตั้งค่าใหม่ (Try Again)"
		_sim_btn_retry.custom_minimum_size = Vector2(160, 18)
		_sim_btn_retry.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_sim_btn_retry.add_theme_font_override("font", FONT_THAI)
		_sim_btn_retry.add_theme_font_size_override("font_size", 6)
		_sim_btn_retry.pressed.connect(func() -> void:
			_sim_panel.hide()
			_is_simulating = false
			submit_button.disabled = false
		)
		btn_hbox.add_child(_sim_btn_retry)

		_sim_btn_continue = Button.new()
		_sim_btn_continue.text = "✓ ดำเนินการต่อ (Complete)"
		_sim_btn_continue.custom_minimum_size = Vector2(140, 18)
		_sim_btn_continue.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_sim_btn_continue.add_theme_font_override("font", FONT_THAI)
		_sim_btn_continue.add_theme_font_size_override("font_size", 6)
		_sim_btn_continue.pressed.connect(func() -> void:
			_sim_panel.hide()
			_is_simulating = false
			_submit_final_payload()
		)
		btn_hbox.add_child(_sim_btn_continue)

		add_child(_sim_panel)

	_sim_panel.show()
	_sim_panel.move_to_front()
	_sim_output.clear()
	_sim_btn_retry.hide()
	_sim_btn_continue.hide()

func _run_recovery_simulation() -> void:
	_is_simulating = true
	submit_button.disabled = true
	if restore_progress_bar:
		restore_progress_bar.value = 10

	var ver: String = _get_selected_version()
	var dest: String = _get_selected_destination()

	_sim_output.append_text("[color=#00e676]▶ เริ่มต้นจำลองการกู้คืนข้อมูล 3-2-1 Backup Engine...[/color]\n")
	await get_tree().create_timer(0.25).timeout

	# 1. Check Auto-Sync Status
	_sim_output.append_text("[color=#80d8ff][ขั้นตอนที่ 1/4][/color] ตรวจสอบสถานะ Cloud Auto-Sync...\n")
	await get_tree().create_timer(0.25).timeout

	if _is_auto_sync_active:
		_sim_output.append_text("[color=#ff3333]💥 [SYNC COLLISION]: Auto-Sync ยังทำงานอยู่! ไดรฟ์คลาวด์ซิงค์ไฟล์ .locked ลงมาทับไฟล์สะอาดที่เพิ่งกู้คืนทันที!\nกรุณาระงับ Auto-Sync ก่อนเริ่มกู้คืน![/color]\n")
		_sim_btn_retry.show()
		_is_simulating = false
		_submit_final_payload()
		return

	_sim_output.append_text("[color=#a8ffb2]  ✔ ผ่าน: ระงับ Cloud Auto-Sync แล้ว ปลอดภัยจากการซิงค์ไฟล์เสียทับซ้อน[/color]\n")
	if restore_progress_bar:
		restore_progress_bar.value = 35
	await get_tree().create_timer(0.2).timeout

	# 2. Check Version Snapshot
	_sim_output.append_text("[color=#80d8ff][ขั้นตอนที่ 2/4][/color] ตรวจสอบ Recovery Point เวอร์ชันที่เลือก: %s...\n" % ver)
	await get_tree().create_timer(0.25).timeout

	if ver != CLEAN_VERSION:
		if ver == "infected_1910":
			_sim_output.append_text("[color=#ff3333]💥 [VERSION ERROR]: เลือก v4 (19:10 น.) ไฟล์ถูกเข้ารหัส .locked หมดแล้ว ไม่สามารถนำมาใช้งานได้![/color]\n")
		elif ver == "infected_1905":
			_sim_output.append_text("[color=#ff3333]💥 [VERSION ERROR]: เลือก v3 (19:05 น.) เป็นไฟล์ที่มีโค้ดมัลแวร์ฝังอยู่ ไวรัสจะทำงานซ้ำทันที![/color]\n")
		else:
			_sim_output.append_text("[color=#ff3333]💥 [VERSION ERROR]: เลือก v1 เป็นโครงร่างเปล่า เนื้อหารายงานยังไม่สมบูรณ์![/color]\n")
		_sim_btn_retry.show()
		_is_simulating = false
		_submit_final_payload()
		return

	_sim_output.append_text("[color=#a8ffb2]  ✔ ผ่าน: สแนปช็อต v2 (18:55 น.) เป็นจุดเวลาก่อนติดเชื้อ ไฟล์สมบูรณ์ ปลอดภัย 100%[/color]\n")
	if restore_progress_bar:
		restore_progress_bar.value = 65
	await get_tree().create_timer(0.2).timeout

	# 3. Check Destination
	_sim_output.append_text("[color=#80d8ff][ขั้นตอนที่ 3/4][/color] ตรวจสอบปลายทางบันทึกไฟล์: %s...\n" % dest)
	await get_tree().create_timer(0.25).timeout

	if dest != SEPARATE_DESTINATION:
		_sim_output.append_text("[color=#ff9900]⚠️ [STORAGE RISK]: กู้คืนลงไดรฟ์เดิมที่เพิ่งติดมัลแวร์ เสี่ยงต่อการถูกมัลแวร์ในระบบเขียนทับ!\nตามกฎ 3-2-1 ต้องกู้คืนลงไดรฟ์สำรองแยกต่างหาก (Separate external drive)![/color]\n")
		_sim_btn_retry.show()
		_is_simulating = false
		_submit_final_payload()
		return

	_sim_output.append_text("[color=#a8ffb2]  ✔ ผ่าน: แยกไดรฟ์กู้คืนภายนอก (D:\\External + C:\\Clean) ป้องกันการปนเปื้อน[/color]\n")
	if restore_progress_bar:
		restore_progress_bar.value = 85
	await get_tree().create_timer(0.2).timeout

	# 4. Check 3-2-1 Rule
	_sim_output.append_text("[color=#80d8ff][ขั้นตอนที่ 4/4][/color] ตรวจสอบความสอดคล้องตามกฎ 3-2-1 Backup Rule...\n")
	await get_tree().create_timer(0.2).timeout

	_sim_output.append_text("[color=#a8ffb2]  ✔ 3 Copies: Cloud Snapshot + External Drive + Clean Local Work\n  ✔ 2 Media: Cloud Storage + USB External Flash Drive\n  ✔ 1 Off-site: GG Disk Cloud Server (Off-premise)[/color]\n")
	if restore_progress_bar:
		restore_progress_bar.value = 100

	# Complete
	_sim_output.append_text("\n[color=#00e676]🎉 [RESTORE COMPLETE 100%]: กู้คืนไฟล์ Report_Final.docx จากจุดเวลา 18:55 ลงไดรฟ์แยกโดยระงับ Cloud Sync สำเร็จสมบูรณ์แบบ!\nข้อมูลปลอดภัย ปราศจากมัลแวร์ 100%![/color]\n")
	_sim_btn_continue.show()
	_is_simulating = false

func _submit_final_payload() -> void:
	submit_puzzle({
		"version": _get_selected_version(),
		"destination": _get_selected_destination(),
		"sync": CLOUD_SYNC_DISABLED if not _is_auto_sync_active else CLOUD_SYNC_ENABLED
	})

func _set_controls_disabled(disabled: bool) -> void:
	if version_list:
		for i: int in range(version_list.item_count):
			version_list.set_item_disabled(i, disabled)
	if destination_selector:
		destination_selector.disabled = disabled
	if auto_sync_toggle_button:
		auto_sync_toggle_button.disabled = disabled
	if confirm_321_checkbox:
		confirm_321_checkbox.disabled = disabled
	if submit_button:
		submit_button.disabled = disabled
