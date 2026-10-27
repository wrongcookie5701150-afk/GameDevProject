class_name AssessmentTelemetryParam
extends BaseTelemetryParam

var assessment_type: String = ""

func sync_metrics() -> void:
	metrics["assessment_type"] = assessment_type