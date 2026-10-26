class_name BaseSequencePuzzle
extends BasePuzzleUI

var submitted_steps: Array[String] = []

func submit_sequence(steps: Array[String]) -> void:
	submitted_steps = steps.duplicate()
	submit_puzzle(submitted_steps)

func get_submission_metrics() -> Dictionary:
	return {"sequence_steps": submitted_steps.duplicate()}

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: SequenceTelemetryParam = SequenceTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "puzzle_submitted"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.sequence_steps = submitted_steps.duplicate()
	param.sequence_correct = is_correct
	param.sync_metrics()
	return param
