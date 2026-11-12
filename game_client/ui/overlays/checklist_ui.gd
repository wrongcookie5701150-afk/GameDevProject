extends BasePuzzleUI

@onready var wifi_check: CheckBox = (find_child("task01", true, false) as CheckBox) if find_child("task01", true, false) else (find_child("WifiCheck", true, false) as CheckBox)
@onready var lan_check: CheckBox = find_child("LanCheck", true, false) as CheckBox
@onready var accounts_check: CheckBox = (find_child("task02", true, false) as CheckBox) if find_child("task02", true, false) else (find_child("AccountsCheck", true, false) as CheckBox)
@onready var files_check: CheckBox = (find_child("task03", true, false) as CheckBox) if find_child("task03", true, false) else (find_child("FilesCheck", true, false) as CheckBox)
@onready var submit_button: Button = find_child("SubmitButton", true, false) as Button
@onready var feedback_label: Label = find_child("FeedbackLabel", true, false) as Label

var _is_custom_mode: bool = false
var _custom_checkboxes: Array[CheckBox] = []
var _is_collapsed: bool = false
var _expanded_height: float = 84.0
var _collapse_button: Button = null

func _ready() -> void:
	hint_tier_1 = "หลักการกักกันระบบ (Isolation) คือการตัดช่องทางสื่อสารภายนอกและตรวจสอบสภาพแวดล้อมให้ปลอดภัย"
	hint_tier_2 = "ตัดการเชื่อมต่อไร้สาย ตรวจสอบสถานะบัญชีในระบบ และตรวจสอบพื้นที่จัดเก็บข้อมูล"
	hint_tier_3 = "1. ตัดการเชื่อมต่อไร้สาย 2. ตรวจสอบบัญชีในตั้งค่าระบบ 3. สำรวจโฟลเดอร์ในเครื่อง"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var task_obj: Control = find_child("TaskObjective", true, false) as Control
	if task_obj:
		task_obj.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_apply_panel_styling(task_obj)
	super._ready()
	_resolve_nodes()
	if not _is_custom_mode:
		_setup_automated_checks()
		_apply_principled_texts_and_fonts()
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)

func _setup_collapse_button(task_obj: Control) -> void:
	if not task_obj:
		return
	if task_obj.has_node("CollapseButton"):
		_collapse_button = task_obj.get_node("CollapseButton") as Button
		return
	
	_collapse_button = Button.new()
	_collapse_button.name = "CollapseButton"
	_collapse_button.text = "─"
	_collapse_button.tooltip_text = "ย่อ/ขยายเป้าหมายภารกิจ"
	_collapse_button.custom_minimum_size = Vector2(16, 14)
	_collapse_button.size = Vector2(16, 14)
	_collapse_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_collapse_button.offset_left = -18.0
	_collapse_button.offset_top = 2.0
	_collapse_button.offset_right = -2.0
	_collapse_button.offset_bottom = 16.0
	_collapse_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_collapse_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var mono_font: FontFile = load("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")
	if mono_font:
		_collapse_button.add_theme_font_override("font", mono_font)
	_collapse_button.add_theme_font_size_override("font_size", 7)
	
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.14, 0.18, 0.85)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.4, 0.55, 0.75, 0.8)
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_right = 2
	sb.corner_radius_bottom_left = 2
	_collapse_button.add_theme_stylebox_override("normal", sb)
	
	var sb_h := sb.duplicate() as StyleBoxFlat
	sb_h.bg_color = Color(0.2, 0.3, 0.45, 1.0)
	_collapse_button.add_theme_stylebox_override("hover", sb_h)
	
	_collapse_button.pressed.connect(toggle_collapse)
	task_obj.add_child(_collapse_button)
	_collapse_button.z_index = 2

	var title_lbl: Label = find_child("TitleLabel", true, false) as Label
	if title_lbl and not title_lbl.gui_input.is_connected(_on_title_gui_input):
		title_lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		title_lbl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		title_lbl.gui_input.connect(_on_title_gui_input)

func _on_title_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle_collapse()

func toggle_collapse() -> void:
	_is_collapsed = !_is_collapsed
	_apply_collapse_state()

func _apply_collapse_state() -> void:
	var task_obj: Control = find_child("TaskObjective", true, false) as Control
	if not task_obj:
		return

	if _collapse_button:
		_collapse_button.text = "□" if _is_collapsed else "─"
		_collapse_button.tooltip_text = "ขยายเป้าหมายภารกิจ" if _is_collapsed else "ย่อเป้าหมายภารกิจ"

	if _is_custom_mode:
		for cb: CheckBox in _custom_checkboxes:
			if is_instance_valid(cb):
				cb.visible = !_is_collapsed
	else:
		if wifi_check:
			wifi_check.visible = !_is_collapsed
		if accounts_check:
			accounts_check.visible = !_is_collapsed
		if files_check:
			files_check.visible = !_is_collapsed
		if submit_button:
			submit_button.visible = !_is_collapsed and not is_resolved
		if feedback_label:
			feedback_label.visible = !_is_collapsed

	var target_height: float = 18.0 if _is_collapsed else _expanded_height
	task_obj.offset_bottom = task_obj.offset_top + target_height

func _apply_panel_styling(panel: Control) -> void:
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -258.0
	panel.offset_top = 6.0
	panel.offset_right = -6.0
	_expanded_height = 84.0
	var content: Control = panel.get_node_or_null("Content") as Control
	if content:
		content.clip_contents = false
		content.offset_right = -20.0
	_setup_collapse_button(panel)
	_apply_collapse_state()

func setup_custom_checklist(title_text: String, items: Array[String]) -> void:
	_is_custom_mode = true
	_resolve_nodes()
	
	var title_lbl: Label = find_child("TitleLabel", true, false) as Label
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
	if title_lbl:
		title_lbl.text = title_text
		title_lbl.add_theme_font_size_override("font_size", 7)
		if thai_font:
			title_lbl.add_theme_font_override("font", thai_font)
			
	if wifi_check:
		wifi_check.hide()
	if lan_check:
		lan_check.hide()
	if accounts_check:
		accounts_check.hide()
	if files_check:
		files_check.hide()
	if submit_button:
		submit_button.hide()
	if feedback_label:
		feedback_label.hide()
		
	var content: Control = find_child("Content", true, false) as Control
	if not content:
		return
	content.clip_contents = false
	content.offset_right = -20.0
	
	for cb: CheckBox in _custom_checkboxes:
		if is_instance_valid(cb):
			cb.queue_free()
	_custom_checkboxes.clear()
	
	var checked_icon: Texture2D = preload("res://assets/UI_Wenrexa/Checked_01.png")
	var unchecked_icon: Texture2D = preload("res://assets/UI_Wenrexa/Checked_02.png")
	var empty_style := StyleBoxEmpty.new()
	empty_style.content_margin_left = 6.0
	
	for i in range(items.size()):
		var cb := CheckBox.new()
		cb.name = "CustomTask_%02d" % (i + 1)
		cb.text = items[i]
		cb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cb.focus_mode = Control.FOCUS_NONE
		cb.add_theme_constant_override("icon_max_width", 7)
		cb.add_theme_font_size_override("font_size", 6)
		cb.add_theme_stylebox_override("normal", empty_style)
		if thai_font:
			cb.add_theme_font_override("font", thai_font)
		if checked_icon:
			cb.add_theme_icon_override("checked", checked_icon)
		if unchecked_icon:
			cb.add_theme_icon_override("unchecked", unchecked_icon)
		content.add_child(cb)
		_custom_checkboxes.append(cb)
		
	var task_obj: Control = find_child("TaskObjective", true, false) as Control
	if task_obj:
		task_obj.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		task_obj.offset_left = -286.0
		task_obj.offset_top = 4.0
		task_obj.offset_right = -6.0
		_expanded_height = maxf(92.0, 18.0 + items.size() * 14.0)
		_setup_collapse_button(task_obj)
		_apply_collapse_state()

func set_task_index_completed(idx: int, completed: bool) -> void:
	if idx >= 0 and idx < _custom_checkboxes.size():
		var cb: CheckBox = _custom_checkboxes[idx]
		if cb and is_instance_valid(cb):
			cb.button_pressed = completed

func _apply_principled_texts_and_fonts() -> void:
	if _is_custom_mode:
		return
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
	var title_lbl: Label = find_child("TitleLabel", true, false) as Label
	if title_lbl:
		title_lbl.text = "เป้าหมาย: มาตรการกักกันระบบเครื่องเต่าดำ (Isolation Checklist)"
		title_lbl.add_theme_font_size_override("font_size", 8)
		if thai_font:
			title_lbl.add_theme_font_override("font", thai_font)

	# Hide LAN check since TaoDam is Wi-Fi based, but keep it automated in code
	if lan_check:
		lan_check.hide()
		lan_check.visible = false
		lan_check.button_pressed = true

	if wifi_check:
		wifi_check.text = "1. ตัดช่องทางการเชื่อมต่อเครือข่ายไร้สายของเครื่อง"
		wifi_check.add_theme_font_size_override("font_size", 7)
		if thai_font:
			wifi_check.add_theme_font_override("font", thai_font)

	if accounts_check:
		accounts_check.text = "2. ตรวจสอบสถานะบัญชีที่ผูกไว้ในตั้งค่าระบบของเครื่อง"
		accounts_check.add_theme_font_size_override("font_size", 7)
		if thai_font:
			accounts_check.add_theme_font_override("font", thai_font)

	if files_check:
		files_check.text = "3. สำรวจไฟล์และโฟลเดอร์สำคัญในพื้นที่จัดเก็บหลัก"
		files_check.add_theme_font_size_override("font_size", 7)
		if thai_font:
			files_check.add_theme_font_override("font", thai_font)

	if feedback_label:
		feedback_label.add_theme_font_size_override("font_size", 7)
		if thai_font:
			feedback_label.add_theme_font_override("font", thai_font)

func _resolve_task_check(task_name: String, legacy_name: String) -> CheckBox:
	# Prefer the exact path defined in Checklist_UI.tscn, then fall back to recursive search.
	var cb: CheckBox = get_node_or_null("TaskObjective/Content/" + task_name) as CheckBox
	if not cb:
		cb = find_child(task_name, true, false) as CheckBox
	if not cb and not legacy_name.is_empty():
		cb = find_child(legacy_name, true, false) as CheckBox
	return cb

func _resolve_nodes() -> void:
	if not is_instance_valid(wifi_check):
		wifi_check = _resolve_task_check("task01", "WifiCheck")
	if not is_instance_valid(lan_check):
		lan_check = find_child("LanCheck", true, false) as CheckBox
	if not is_instance_valid(accounts_check):
		accounts_check = _resolve_task_check("task02", "AccountsCheck")
	if not is_instance_valid(files_check):
		files_check = _resolve_task_check("task03", "FilesCheck")
	if not submit_button:
		submit_button = find_child("SubmitButton", true, false) as Button
	if not feedback_label:
		feedback_label = find_child("FeedbackLabel", true, false) as Label

func _setup_automated_checks() -> void:
	for cb: CheckBox in [wifi_check, lan_check, accounts_check, files_check]:
		if cb:
			cb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cb.focus_mode = Control.FOCUS_NONE

	# LAN is automatically unplugged on TaoDam laptop
	if lan_check:
		lan_check.button_pressed = true
		lan_check.hide()

func start_puzzle() -> void:
	super.start_puzzle()
	if not _is_custom_mode:
		_resolve_nodes()
		_setup_automated_checks()
		_apply_principled_texts_and_fonts()

func update_condition(condition_key: String, value: bool) -> void:
	mark_decision_started()
	_resolve_nodes()
	if lan_check:
		lan_check.button_pressed = true
	match condition_key:
		"wifi_disabled":
			if wifi_check:
				wifi_check.button_pressed = value
		"lan_unplugged":
			if lan_check:
				lan_check.button_pressed = value
		"personal_accounts_unlinked":
			if accounts_check:
				accounts_check.button_pressed = value
		"no_important_files":
			if files_check:
				files_check.button_pressed = value
	
	_check_completion()

func _check_completion() -> void:
	if lan_check:
		lan_check.button_pressed = true
	if is_all_conditions_met() and not is_resolved:
		submit_puzzle(_checklist_values())

func is_all_conditions_met() -> bool:
	if lan_check:
		lan_check.button_pressed = true
	var vals: Dictionary = _checklist_values()
	return bool(vals.get("wifi_disabled", false)) \
		and bool(vals.get("lan_unplugged", true)) \
		and bool(vals.get("personal_accounts_unlinked", false)) \
		and bool(vals.get("no_important_files", false))

func validate_answer(answer: Variant) -> bool:
	if not answer is Dictionary:
		return false
	return bool(answer.get("wifi_disabled", false)) \
		and bool(answer.get("lan_unplugged", true)) \
		and bool(answer.get("personal_accounts_unlinked", false)) \
		and bool(answer.get("no_important_files", false))

func get_submission_metrics() -> Dictionary:
	return _checklist_values()

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: IncidentTelemetryParam = IncidentTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "isolation_checklist_submitted"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.wifi_disabled = bool(metrics.get("wifi_disabled", false))
	param.lan_unplugged = bool(metrics.get("lan_unplugged", true))
	param.personal_accounts_unlinked = bool(metrics.get("personal_accounts_unlinked", false))
	param.no_important_files = bool(metrics.get("no_important_files", false))
	param.sync_metrics()
	return param

func on_solve_success() -> void:
	if feedback_label:
		feedback_label.text = "✅ กักกันระบบเต่าดำเรียบร้อยแล้ว พร้อมสำหรับการตรวจวิเคราะห์หลักฐาน"
		feedback_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.55, 1.0))
	_set_checklist_enabled(false)
	if submit_button:
		submit_button.hide()

func on_solve_failed() -> void:
	if feedback_label:
		feedback_label.text = "⚠️ กรุณาตรวจสอบและดำเนินการมาตรการกักกันระบบให้ครบทุกข้อ"
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45, 1.0))

func _on_submit_pressed() -> void:
	mark_decision_started()
	if lan_check:
		lan_check.button_pressed = true
	submit_puzzle(_checklist_values())

func _checklist_values() -> Dictionary:
	_resolve_nodes()
	if lan_check:
		lan_check.button_pressed = true
	return {
		"wifi_disabled": wifi_check.button_pressed if wifi_check else false,
		"lan_unplugged": true,
		"personal_accounts_unlinked": accounts_check.button_pressed if accounts_check else false,
		"no_important_files": files_check.button_pressed if files_check else false
	}

func _set_checklist_enabled(enabled: bool) -> void:
	if wifi_check:
		wifi_check.disabled = not enabled
	if lan_check:
		lan_check.disabled = not enabled
	if accounts_check:
		accounts_check.disabled = not enabled
	if files_check:
		files_check.disabled = not enabled
