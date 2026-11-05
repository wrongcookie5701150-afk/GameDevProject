class_name BasePuzzleUI
extends Control

signal puzzle_submitted(is_correct: bool, attempt_count: int)
signal puzzle_resolved

@export var scene_id: String = ""
@export var task_id: StringName
@export var puzzle_id: StringName
@export var hint_delay_seconds: float = 5.0

@export_group("Adaptive Scaffolding")
@export_multiline var hint_tier_1: String = ""
@export_multiline var hint_tier_2: String = ""
@export_multiline var hint_tier_3: String = ""

var attempt_count: int = 0
var is_resolved: bool = false
var hint_used: bool = false
var current_hint_tier: int = 0
var decision_history: Array[Dictionary] = []

var _task_started: bool = false
var _analysis_start_msec: int = 0
var _decision_start_msec: int = 0
var _first_decision_recorded: bool = false
var _hint_button_node: Button = null
var _hint_banner_panel: PanelContainer = null
var _hint_banner_label: Label = null

func _ready() -> void:
	if visible:
		start_puzzle()
	if get_tree().current_scene == self:
		_setup_standalone_back_button()
	_setup_scaffolding_ui()

func _setup_standalone_back_button() -> void:
	var back_btn := Button.new()
	back_btn.text = "← Main Menu [Q]"
	back_btn.name = "StandaloneBackButton"
	back_btn.position = Vector2(6, 6)
	back_btn.z_index = 50
	back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_btn.add_theme_font_size_override("font_size", 7)
	back_btn.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://ui/menus/MainMenu.tscn")
	)
	add_child(back_btn)

func _setup_scaffolding_ui() -> void:
	# ตรวจหาปุ่ม HintButton ที่มีอยู่ใน Scene แล้ว
	_hint_button_node = find_child("HintButton", true, false) as Button
	if _hint_button_node:
		if not _hint_button_node.pressed.is_connected(_on_scaffolding_hint_pressed):
			_hint_button_node.pressed.connect(_on_scaffolding_hint_pressed)
	else:
		# หากไม่มีปุ่ม HintButton ใน Scene ให้สร้างปุ่มลอยสไตล์ Cyberpunk มุมขวาบน
		var new_btn := Button.new()
		new_btn.name = "DynamicScaffoldingHintButton"
		new_btn.text = "💡 Hint [H]"
		new_btn.position = Vector2(size.x - 70, 6) if size.x > 100 else Vector2(250, 6)
		new_btn.size = Vector2(64, 18)
		new_btn.z_index = 40
		new_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		new_btn.add_theme_font_size_override("font_size", 7)
		new_btn.pressed.connect(_on_scaffolding_hint_pressed)
		add_child(new_btn)
		_hint_button_node = new_btn

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var focused: Control = get_viewport().gui_get_focus_owner()
	var in_text_input: bool = focused and (focused is LineEdit or focused is TextEdit)

	if get_tree().current_scene == self:
		if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
			if not in_text_input:
				get_tree().change_scene_to_file("res://ui/menus/MainMenu.tscn")
				get_viewport().set_input_as_handled()
				return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_H:
		if not in_text_input and not is_resolved:
			request_scaffolding_hint()
			get_viewport().set_input_as_handled()

func start_puzzle() -> void:
	if _task_started or is_resolved:
		return
	if not String(task_id).is_empty():
		TelemetryManager.start_task_timer(String(task_id))
		_task_started = true
	_analysis_start_msec = Time.get_ticks_msec()
	_decision_start_msec = 0
	_first_decision_recorded = false
	decision_history.clear()

## บันทึกจุดเริ่มต้นของการตัดสินใจ (เมื่อเริ่มเลือกตัวเลือก พิมพ์คำตอบ หรือคลิก)
func mark_decision_started() -> void:
	if not _first_decision_recorded:
		_first_decision_recorded = true
		_decision_start_msec = Time.get_ticks_msec()

## คำนวณระดับคำใบ้ที่เหมาะสมตามคลัสเตอร์ของผู้เล่น (Adaptive Scaffolding)
func get_adaptive_hint_tier() -> int:
	var cluster: String = TelemetryManager.current_player_cluster
	var is_adaptive: bool = TelemetryManager.is_adaptive_hint_enabled
	if cluster == "Beginner" or is_adaptive:
		if attempt_count == 0:
			return 1
		elif attempt_count == 1:
			return 2
		else:
			return 3
	else:
		# กลุ่ม Expert: ให้ลองคิดเองก่อน
		if attempt_count <= 1:
			return 1
		elif attempt_count == 2:
			return 2
		else:
			return 3

## ขอรับคำใบ้ตามระดับทักษะและแสดงผล
func request_scaffolding_hint() -> String:
	hint_used = true
	var target_tier: int = maxi(current_hint_tier + 1, get_adaptive_hint_tier())
	current_hint_tier = clampi(target_tier, 1, 3)

	var hint_text: String = ""
	match current_hint_tier:
		1:
			hint_text = hint_tier_1 if not hint_tier_1.is_empty() else hint_tier_2
		2:
			hint_text = hint_tier_2 if not hint_tier_2.is_empty() else hint_tier_1
		3:
			hint_text = hint_tier_3 if not hint_tier_3.is_empty() else hint_tier_2

	if hint_text.is_empty():
		hint_text = "สังเกตความผิดปกติของหลักฐานและเปรียบเทียบข้อมูลที่เกี่ยวข้อง"

	var full_msg: String = "💡 [คำใบ้ Tier %d/3]: %s" % [current_hint_tier, hint_text]
	_display_scaffolding_hint(full_msg)
	
	if _hint_button_node:
		_hint_button_node.text = "💡 Hint (%d/3)" % current_hint_tier

	return full_msg

func _on_scaffolding_hint_pressed() -> void:
	request_scaffolding_hint()

func _display_scaffolding_hint(msg: String) -> void:
	var feedback_lbl = find_child("FeedbackLabel", true, false) as Label
	if feedback_lbl:
		feedback_lbl.text = msg
	else:
		_show_hint_banner(msg)

func _show_hint_banner(msg: String) -> void:
	if not _hint_banner_panel:
		_hint_banner_panel = PanelContainer.new()
		_hint_banner_panel.name = "ScaffoldingHintBanner"
		_hint_banner_panel.z_index = 60
		_hint_banner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_hint_banner_label = Label.new()
		_hint_banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_hint_banner_label.add_theme_font_size_override("font_size", 9)
		_hint_banner_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
		_hint_banner_panel.add_child(_hint_banner_label)
		add_child(_hint_banner_panel)
		_hint_banner_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_hint_banner_panel.offset_left = 10
		_hint_banner_panel.offset_right = -10
		_hint_banner_panel.offset_bottom = -6
		_hint_banner_panel.offset_top = -34

	if _hint_banner_label:
		_hint_banner_label.text = msg
	if _hint_banner_panel:
		_hint_banner_panel.show()

func submit_puzzle(answer: Variant) -> void:
	if is_resolved:
		return

	mark_decision_started()
	attempt_count += 1
	var is_correct: bool = validate_answer(answer)
	var duration_seconds: float = 0.0
	if _task_started:
		duration_seconds = TelemetryManager.stop_task_timer(String(task_id))
		_task_started = false

	# คำนวณเวลาแยกส่วน Analysis vs Decision
	var now_msec: int = Time.get_ticks_msec()
	var analysis_seconds: float = float(_decision_start_msec - _analysis_start_msec) / 1000.0
	var decision_seconds: float = float(now_msec - _decision_start_msec) / 1000.0
	if _analysis_start_msec <= 0:
		analysis_seconds = 0.0
		decision_seconds = duration_seconds
	
	decision_history.append({
		"attempt": attempt_count,
		"answer": str(answer),
		"is_correct": is_correct,
		"duration_seconds": duration_seconds,
		"hint_tier": current_hint_tier
	})

	var metrics: Dictionary = {}
	metrics.merge(get_submission_metrics(), true)
	if not String(puzzle_id).is_empty():
		metrics["puzzle_id"] = String(puzzle_id)
	
	metrics["analysis_time_seconds"] = maxf(0.0, analysis_seconds)
	metrics["decision_time_seconds"] = maxf(0.0, decision_seconds)
	metrics["decision_history"] = decision_history.duplicate(true)
	metrics["scenario_id"] = TelemetryManager.get_scenario_for_task(String(task_id))
	metrics["hint_tier_reached"] = current_hint_tier

	TelemetryManager.track_param(_build_telemetry_param(is_correct, duration_seconds, metrics))
	puzzle_submitted.emit(is_correct, attempt_count)

	if is_correct:
		is_resolved = true
		puzzle_resolved.emit()
		on_solve_success()
	else:
		on_solve_failed()
		if not String(task_id).is_empty():
			TelemetryManager.start_task_timer(String(task_id))
			_task_started = true

func validate_answer(_answer: Variant) -> bool:
	return false

func get_submission_metrics() -> Dictionary:
	return {}

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: BaseTelemetryParam = BaseTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "puzzle_submitted"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.metrics = metrics.duplicate(true)
	return param

func on_solve_success() -> void:
	pass

func on_solve_failed() -> void:
	pass
