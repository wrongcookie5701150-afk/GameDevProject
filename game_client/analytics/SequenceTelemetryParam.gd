class_name SequenceTelemetryParam
extends BaseTelemetryParam

var sequence_steps: Array[String] = []
var sequence_correct: bool = false

func sync_metrics() -> void:
	metrics["sequence_steps"] = sequence_steps.duplicate()
	metrics["sequence_correct"] = sequence_correct
