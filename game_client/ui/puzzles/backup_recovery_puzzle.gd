class_name BackupRecoveryPuzzle
extends BasePuzzleUI

const CLEAN_VERSION: String = "before_1902"
const SEPARATE_DESTINATION: String = "external_drive"
const CLOUD_SYNC_DISABLED: String = "disabled"

@onready var version_selector: OptionButton = $Panel/Content/VersionSelector
@onready var destination_selector: OptionButton = $Panel/Content/DestinationSelector
@onready var sync_selector: OptionButton = $Panel/Content/SyncSelector
@onready var submit_button: Button = $Panel/Content/SubmitButton
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel

func _ready() -> void:
	hint_tier_1 = "ต้องเลือกจุดกู้คืนข้อมูล (Recovery Point) ก่อนเวลาที่เปิดไฟล์มัลแวร์ (19:02) และเก็บแยกไดรฟ์"
	hint_tier_2 = "เลือกจุดเวลาสะอาด 18:55, กู้คืนไปยังไดรฟ์ภายนอกแยกต่างหาก และต้องปิด Cloud Sync ชั่วคราวเพื่อไม่ให้มัลแวร์หรือไฟล์เข้ารหัสซิงค์มาทับ"
	hint_tier_3 = "ตั้งค่า: Version = 18:55 (verified clean point), Destination = Separate external recovery drive, Cloud Sync = Disable cloud sync during restoration"
	super._ready()
	_add_options(version_selector, [
		["19:05 (after incident activity)", "infected_1905"],
		["18:55 (verified clean point)", CLEAN_VERSION],
		["19:10 (latest available)", "infected_1910"]
	])
	_add_options(destination_selector, [
		["Original system drive", "original_drive"],
		["Separate external recovery drive", SEPARATE_DESTINATION]
	])
	_add_options(sync_selector, [
		["Keep cloud sync enabled", "enabled"],
		["Disable cloud sync during restoration", CLOUD_SYNC_DISABLED]
	])
	submit_button.pressed.connect(_on_submit_pressed)
	version_selector.item_selected.connect(func(_idx: int) -> void: mark_decision_started())
	destination_selector.item_selected.connect(func(_idx: int) -> void: mark_decision_started())
	sync_selector.item_selected.connect(func(_idx: int) -> void: mark_decision_started())

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
	return {
		"selected_version": _selected_id(version_selector),
		"selected_destination": _selected_id(destination_selector),
		"cloud_sync": _selected_id(sync_selector),
		"recovery_point": _selected_id(version_selector),
		"isolated_sync": _selected_id(sync_selector) == CLOUD_SYNC_DISABLED
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
	feedback_label.text = "✅ ทดสอบสำเร็จ: กู้คืนไฟล์จากจุดเวลา 18:55 ลงไดรฟ์แยกโดยปิด Cloud Sync ข้อมูลปลอดภัย 100%!"
	_set_controls_disabled(true)

func on_solve_failed() -> void:
	# ระบบจำลองผลกระทบตามตัวเลือกที่ผิดจริง (Trial & Error Simulation Feedback)
	var ver: String = _selected_id(version_selector)
	var dest: String = _selected_id(destination_selector)
	var sync: String = _selected_id(sync_selector)

	if ver != CLEAN_VERSION:
		var ver_text: String = version_selector.get_item_text(version_selector.selected)
		feedback_label.text = "💥 [ผลจำลองล้มเหลว]: จุดเวลา %s เกิดขึ้นหลังเปิด Macro (19:02) ทำให้ไฟล์สำรองติดมัลแวร์มาด้วย ข้อมูลถูกเข้ารหัสซ้ำ!" % ver_text
		return

	if dest != SEPARATE_DESTINATION:
		feedback_label.text = "⚠️ [ผลจำลองล้มเหลว]: กู้คืนลงไดรฟ์เดิมของระบบที่เพิ่งติดมัลแวร์ เสี่ยงต่อการถูกเขียนทับหรือติดมัลแวร์ซ้ำ ควรใช้ Separate external recovery drive!"
		return

	if sync != CLOUD_SYNC_DISABLED:
		feedback_label.text = "⚠️ [ผลจำลองล้มเหลว]: เปิด Cloud Sync ไว้ ทำให้ระบบคลาวด์ซิงค์ไฟล์ .locked ลงมาทับไฟล์สะอาดที่เพิ่งกู้คืน!"
		return

	feedback_label.text = "❌ การตั้งค่ายังไม่ปลอดภัย กรุณาลองปรับการตั้งค่าแล้วทดสอบใหม่ (กด [H] เพื่อดูคำใบ้)"

func _on_submit_pressed() -> void:
	mark_decision_started()
	submit_puzzle({
		"version": _selected_id(version_selector),
		"destination": _selected_id(destination_selector),
		"sync": _selected_id(sync_selector)
	})

func _add_options(selector: OptionButton, options: Array) -> void:
	for option: Array in options:
		selector.add_item(str(option[0]))
		selector.set_item_metadata(selector.get_item_count() - 1, str(option[1]))
	selector.select(0)

func _selected_id(selector: OptionButton) -> String:
	if selector.selected < 0:
		return ""
	return str(selector.get_item_metadata(selector.selected))

func _set_controls_disabled(disabled: bool) -> void:
	version_selector.disabled = disabled
	destination_selector.disabled = disabled
	sync_selector.disabled = disabled
	submit_button.disabled = disabled
