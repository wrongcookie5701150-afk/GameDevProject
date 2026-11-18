extends BaseSequencePuzzle

const FONT_THAI: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

const CORRECT_SEQUENCE: Array[String] = [
	"safe_mode",
	"disable_task",
	"quarantine_helper",
	"check_persistence",
	"confirm_stopped",
	"pause_cloud_sync",
	"restore_backup"
]

const STEP_LABELS: Dictionary = {
	"safe_mode": "Start TaoDam in Safe Mode",
	"disable_task": "Disable the Office_Update_Helper scheduled task",
	"quarantine_helper": "Quarantine Office_Update_Helper.dat",
	"check_persistence": "Check and remove the persistence entry",
	"confirm_stopped": "Confirm the helper cannot restart",
	"pause_cloud_sync": "Keep cloud sync paused",
	"restore_backup": "Restore only from a verified clean backup"
}

@onready var step_selector: OptionButton = $Panel/Content/StepSelector
@onready var sequence_list: ItemList = $Panel/Content/SequenceList
@onready var add_button: Button = $Panel/Content/AddButton
@onready var remove_button: Button = $Panel/Content/RemoveButton
@onready var submit_button: Button = $Panel/Content/SubmitButton
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel

var _sim_panel: PanelContainer = null
var _sim_output: RichTextLabel = null
var _sim_btn_retry: Button = null
var _sim_btn_continue: Button = null
var _is_simulating: bool = false

func _ready() -> void:
	hint_tier_1 = "ก่อนที่จะกู้คืนไฟล์ ต้องหยุดการทำงานของมัลแวร์และวงจรฝังตัว (Persistence) ให้สนิทก่อน"
	hint_tier_2 = "เริ่มจากเข้า Safe Mode เพื่อไม่ให้มัลแวร์ทำงาน -> ปิด Scheduled Task -> กักกันไฟล์ Helper.dat -> ตรวจสอบจุดฝังตัว -> ยืนยันว่าหยุดทำงานแล้ว -> ปิด Cloud Sync -> แล้วจึงกู้คืนไฟล์"
	hint_tier_3 = "เรียงตามลำดับ: 1. Safe Mode -> 2. Disable Task -> 3. Quarantine -> 4. Check Persistence -> 5. Confirm Stopped -> 6. Pause Cloud Sync -> 7. Restore Backup"
	super._ready()
	for step_id: String in CORRECT_SEQUENCE:
		step_selector.add_item(STEP_LABELS[step_id])
		var index: int = step_selector.get_item_count() - 1
		step_selector.set_item_metadata(index, step_id)

	add_button.pressed.connect(_on_add_pressed)
	remove_button.pressed.connect(_on_remove_pressed)
	submit_button.pressed.connect(_on_submit_pressed)

func validate_answer(answer: Variant) -> bool:
	if not answer is Array:
		return false
	var steps: Array = answer
	if steps.size() != CORRECT_SEQUENCE.size():
		return false
	for index: int in range(CORRECT_SEQUENCE.size()):
		if str(steps[index]) != CORRECT_SEQUENCE[index]:
			return false
	return true

func on_solve_success() -> void:
	feedback_label.text = "✅ ทดสอบสำเร็จ: หยุดการทำงานของ Persistence และกักกันมัลแวร์ครบทั้ง 7 ขั้นตอนอย่างปลอดภัย!"
	step_selector.disabled = true
	add_button.disabled = true
	remove_button.disabled = true
	submit_button.hide()

func on_solve_failed() -> void:
	if submitted_steps.size() < CORRECT_SEQUENCE.size():
		var next_idx: int = submitted_steps.size()
		var expected_label: String = str(STEP_LABELS.get(CORRECT_SEQUENCE[next_idx], ""))
		feedback_label.text = "⚠️ [ผลจำลอง]: ยังวางแผนไม่ครบทั้ง 7 ขั้นตอน (มี %d/7) ระบบยังมีความเสี่ยงสูง! (ขั้นที่ %d ควรเป็น: %s)" % [
			submitted_steps.size(), next_idx + 1, expected_label
		]
		return

	var restore_idx: int = submitted_steps.find("restore_backup")
	var disable_idx: int = submitted_steps.find("disable_task")
	var quarantine_idx: int = submitted_steps.find("quarantine_helper")
	var sync_idx: int = submitted_steps.find("pause_cloud_sync")

	if restore_idx != -1 and disable_idx != -1 and restore_idx < disable_idx:
		feedback_label.text = "💥 [ผลการทดสอบล้มเหลว]: กู้คืนไฟล์ก่อนระงับ Scheduled Task! โปรเซส Office_Update_Helper ที่ยังฝังตัวทำงานซ้ำและลบไฟล์ที่เพิ่งกู้คืนทันที!"
		return

	if restore_idx != -1 and quarantine_idx != -1 and restore_idx < quarantine_idx:
		feedback_label.text = "💥 [ผลการทดสอบล้มเหลว]: กู้คืนไฟล์ก่อนกักกัน Helper.dat! ไฟล์มัลแวร์ยังคงอยู่ในระบบและทำการเข้ารหัสไฟล์ซ้ำ!"
		return

	if submitted_steps[0] != "safe_mode":
		feedback_label.text = "⚠️ [ผลการทดสอบล้มเหลว]: ไม่ได้เริ่มใน Safe Mode! โปรเซสมัลแวร์ที่กำลังรันอยู่เบื้องหลังบล็อกไม่ให้แก้ไข Service หรือลบ Persistence!"
		return

	if restore_idx != -1 and sync_idx != -1 and restore_idx < sync_idx:
		feedback_label.text = "⚠️ [ผลการทดสอบล้มเหลว]: กู้คืนไฟล์โดยยังไม่ระงับ Cloud Sync! ไฟล์เสียหายถูกซิงค์กลับไปทับไฟล์บนคลาวด์!"
		return

	for idx: int in range(CORRECT_SEQUENCE.size()):
		if str(submitted_steps[idx]) != CORRECT_SEQUENCE[idx]:
			var expected_step: String = str(STEP_LABELS.get(CORRECT_SEQUENCE[idx], ""))
			feedback_label.text = "❌ [ผลการทดสอบ]: ลำดับขั้นตอนที่ %d ยังไม่ถูกต้อง (ควรทำ: '%s' ก่อน)" % [
				idx + 1, expected_step
			]
			return

	feedback_label.text = "⚠️ ลำดับการกู้คืนยังไม่ปลอดภัย กรุณาลองปรับลำดับขั้นตอนใหม่"

func _advance_selector_to_next_unused() -> void:
	for idx: int in range(step_selector.item_count):
		var step_id: String = str(step_selector.get_item_metadata(idx))
		if not submitted_steps.has(step_id):
			step_selector.select(idx)
			return

func _on_add_pressed() -> void:
	mark_decision_started()
	if submitted_steps.size() >= CORRECT_SEQUENCE.size():
		feedback_label.text = "เพิ่มครบ 7 ขั้นตอนแล้ว กดปุ่ม Submit ด้านล่างเพื่อทดสอบผลลัพธ์"
		return
	var step_id: String = str(step_selector.get_item_metadata(step_selector.selected))
	if submitted_steps.has(step_id):
		_advance_selector_to_next_unused()
		step_id = str(step_selector.get_item_metadata(step_selector.selected))
		if submitted_steps.has(step_id):
			return
	submitted_steps.append(step_id)
	sequence_list.add_item("%d. %s" % [submitted_steps.size(), STEP_LABELS[step_id]])
	_advance_selector_to_next_unused()
	if submitted_steps.size() == CORRECT_SEQUENCE.size():
		feedback_label.text = "ครบทั้ง 7 ขั้นตอนแล้ว กดปุ่ม Submit เพื่อทดลองผลการจำลอง"
	else:
		feedback_label.text = "เพิ่มขั้นตอนที่ %d/7 แล้ว" % submitted_steps.size()

func _on_remove_pressed() -> void:
	mark_decision_started()
	if submitted_steps.is_empty():
		return
	var removed_id: String = submitted_steps.pop_back()
	sequence_list.remove_item(sequence_list.item_count - 1)
	for idx: int in range(step_selector.item_count):
		if str(step_selector.get_item_metadata(idx)) == removed_id:
			step_selector.select(idx)
			break
	feedback_label.text = "ลบขั้นตอนล่าสุดแล้ว (เหลือ %d/7 ขั้นตอน)" % submitted_steps.size()

func _on_submit_pressed() -> void:
	mark_decision_started()
	if _is_simulating:
		return
	_build_or_show_sim_console()
	_run_simulation_sequence()

# ---------------------------------------------------------------------------
# Live Trial-and-Error Simulation Console (T12)
# ---------------------------------------------------------------------------
func _build_or_show_sim_console() -> void:
	if not _sim_panel:
		_sim_panel = PanelContainer.new()
		_sim_panel.name = "LiveSimulationConsole"
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
		title_lbl.text = "🖥️ Live Simulation Console: จำลองการรันคำสั่งตัดวงจร Persistence ทีละขั้นตอน"
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
		_sim_btn_retry.text = "🔄 ย้อนกลับไปปรับลำดับใหม่ (Try Again)"
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
			submit_sequence(submitted_steps)
		)
		btn_hbox.add_child(_sim_btn_continue)

		add_child(_sim_panel)

	_sim_panel.show()
	_sim_panel.move_to_front()
	_sim_output.clear()
	_sim_btn_retry.hide()
	_sim_btn_continue.hide()

func _run_simulation_sequence() -> void:
	_is_simulating = true
	submit_button.disabled = true

	_sim_output.append_text("[color=#00e676]▶ เริ่มต้นจำลองการรันคำสั่งตัดวงจร Persistence (%d/7 ขั้นตอน)...[/color]
" % submitted_steps.size())
	await get_tree().create_timer(0.25).timeout

	if submitted_steps.is_empty():
		_sim_output.append_text("[color=#ff3333]❌ [FAIL]: ยังไม่ได้เลือกขั้นตอนใดๆ เลย! กรุณาเพิ่มขั้นตอนอย่างน้อย 1 ข้อ[/color]
")
		_sim_btn_retry.show()
		_is_simulating = false
		return

	# ตรวจสอบทีละขั้นตอน
	var has_failed: bool = false
	var fail_msg: String = ""

	for idx: int in range(submitted_steps.size()):
		var step_id: String = submitted_steps[idx]
		var step_label: String = str(STEP_LABELS.get(step_id, step_id))
		_sim_output.append_text("[color=#80d8ff][ขั้นที่ %d][/color] รันคำสั่ง: %s
" % [idx + 1, step_label])
		await get_tree().create_timer(0.25).timeout

		# ตรวจสอบเงื่อนไขข้อผิดพลาดเชิงความปลอดภัย
		if idx == 0 and step_id != "safe_mode":
			has_failed = true
			fail_msg = "💥 [FAIL]: เครื่องไม่ได้เริ่มใน Safe Mode! โปรเซส Office_Update_Helper ที่รันอยู่เบื้องหลังบล็อกสิทธิ์ Administrator ไม่ให้แก้ไข Service หรือ Scheduled Task!"
			break

		if step_id == "restore_backup":
			var dis_idx: int = submitted_steps.find("disable_task")
			if dis_idx == -1 or dis_idx > idx:
				has_failed = true
				fail_msg = "💥 [DISASTER]: กู้คืนไฟล์ก่อนระงับ Scheduled Task! Task Scheduler สั่งรัน Office_Update_Helper ซ้ำและลบไฟล์ที่เพิ่งกู้คืนทันที!"
				break

			var q_idx: int = submitted_steps.find("quarantine_helper")
			if q_idx == -1 or q_idx > idx:
				has_failed = true
				fail_msg = "💥 [RE-INFECTION]: กู้คืนไฟล์ก่อนกักกัน Office_Update_Helper.dat! มัลแวร์ที่ยังอยู่ในไดรฟ์เริ่มเข้ารหัสไฟล์ซ้ำ!"
				break

			var s_idx: int = submitted_steps.find("pause_cloud_sync")
			if s_idx == -1 or s_idx > idx:
				has_failed = true
				fail_msg = "⚠️ [OVERWRITE]: กู้คืนไฟล์โดยยังไม่ระงับ Cloud Sync! ไฟล์ .locked จากคลาวด์ซิงค์ลงมาทับไฟล์สะอาด!"
				break

		# ตรวจสอบการเรียงตามลำดับมาตรฐาน
		if idx < CORRECT_SEQUENCE.size() and step_id != CORRECT_SEQUENCE[idx]:
			has_failed = true
			fail_msg = "❌ [OUT OF ORDER]: ขั้นตอนที่ %d ยังไม่เหมาะสม (ควรทำ: '%s' ก่อน)" % [
				idx + 1, str(STEP_LABELS.get(CORRECT_SEQUENCE[idx], ""))
			]
			break

		_sim_output.append_text("[color=#a8ffb2]  ✔ ผ่าน: เงื่อนไขปลอดภัย การทำงานสำเร็จ[/color]
")
		await get_tree().create_timer(0.15).timeout

	if has_failed:
		_sim_output.append_text("
[color=#ff3333]%s[/color]
" % fail_msg)
		_sim_output.append_text("[color=#ffff66]คำแนะนำ: ปรับลำดับขั้นตอนให้ถูกต้อง แล้วกดทดสอบใหม่อีกครั้ง[/color]
")
		_sim_btn_retry.show()
		_is_simulating = false
		submit_sequence(submitted_steps) # บันทึก telemetry failure
		return

	if submitted_steps.size() < CORRECT_SEQUENCE.size():
		var missing_count: int = CORRECT_SEQUENCE.size() - submitted_steps.size()
		_sim_output.append_text("
[color=#ff9900]⚠️ [INCOMPLETE]: รันได้ปลอดภัยแต่ยังวางแผนไม่ครบ (%d/7 ขั้นตอน ขาดอีก %d ข้อ) ระบบยังไม่ปลอดภัย 100%%![/color]
" % [
			submitted_steps.size(), missing_count
		])
		_sim_btn_retry.show()
		_is_simulating = false
		submit_sequence(submitted_steps)
		return

	# ครบ 7 ขั้นตอนถูกต้อง 100%
	_sim_output.append_text("
[color=#00e676]🎉 [SUCCESS 100%%]: ตัดวงจร Persistence และกักกันมัลแวร์ครบทั้ง 7 ขั้นตอนอย่างสมบูรณ์แบบ!
ระบบปลอดภัยสำหรับการกู้คืนไฟล์เอกสารแล้ว![/color]
")
	_sim_btn_continue.show()
	_is_simulating = false
