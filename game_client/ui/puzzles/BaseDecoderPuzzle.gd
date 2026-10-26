class_name BaseDecoderPuzzle
extends BasePuzzleUI

var forensic_metrics: Dictionary = {}

func set_forensic_metrics(metrics: Dictionary) -> void:
	forensic_metrics = metrics.duplicate(true)

func get_submission_metrics() -> Dictionary:
	return forensic_metrics.duplicate(true)

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: ForensicAnalysisTelemetryParam = ForensicAnalysisTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "puzzle_submitted"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.metrics = metrics.duplicate(true)
	param.evidence_file = str(metrics.get("evidence_file", ""))
	param.hash_algorithm = str(metrics.get("hash_algorithm", ""))
	param.expected_hash = str(metrics.get("expected_hash", ""))
	param.submitted_hash = str(metrics.get("submitted_hash", ""))
	param.match_status = bool(metrics.get("match_status", false))
	param.inspected_component = str(metrics.get("inspected_component", ""))
	param.decoded_output = str(metrics.get("decoded_output", ""))
	param.decoded_target = str(metrics.get("decoded_target", ""))
	param.decoded_mode = str(metrics.get("decoded_mode", ""))
	param.sync_metrics()
	return param
