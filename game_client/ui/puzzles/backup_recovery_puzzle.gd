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
	feedback_label.text = "✅ ตั้งค่าการกู้คืนข้อมูลตามกฎ 3-2-1 Backup ปลอดภัยแล้ว!"
	_set_controls_disabled(true)

func on_solve_failed() -> void:
	feedback_label.text = "❌ การตั้งค่ายังไม่ปลอดภัย: เลือกเวลา 18:55 (verified clean point), ปลายทาง Separate external recovery drive, และ Disable cloud sync"

func _on_submit_pressed() -> void:
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