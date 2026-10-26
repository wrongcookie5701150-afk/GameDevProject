class_name BaseClickSelectPuzzle
extends BasePuzzleUI

@export var correct_option_id: StringName

var selected_option_id: StringName
var selected_metrics: Dictionary = {}

func submit_selection(option_id: StringName, option_metrics: Dictionary = {}) -> void:
	selected_option_id = option_id
	selected_metrics = option_metrics.duplicate(true)
	submit_puzzle(String(option_id))

func validate_answer(answer: Variant) -> bool:
	return StringName(str(answer)) == correct_option_id

func get_submission_metrics() -> Dictionary:
	var metrics: Dictionary = selected_metrics.duplicate(true)
	metrics["selected_option_id"] = String(selected_option_id)
	return metrics

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: OSTelemetryParam = OSTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "puzzle_submitted"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.metrics = metrics.duplicate(true)
	param.selected_option_id = String(selected_option_id)
	param.selected_timestamp = str(metrics.get("selected_timestamp", ""))
	param.selected_email = str(metrics.get("selected_email", ""))
	param.domain_checked = str(metrics.get("domain_checked", ""))
	param.sync_metrics()
	return param
