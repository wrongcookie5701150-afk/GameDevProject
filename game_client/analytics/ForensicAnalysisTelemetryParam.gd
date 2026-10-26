class_name ForensicAnalysisTelemetryParam
extends BaseTelemetryParam

var evidence_file: String = ""
var hash_algorithm: String = ""
var expected_hash: String = ""
var submitted_hash: String = ""
var match_status: bool = false
var inspected_component: String = ""
var decoded_output: String = ""
var decoded_target: String = ""
var decoded_mode: String = ""

func sync_metrics() -> void:
	if not evidence_file.is_empty():
		metrics["evidence_file"] = evidence_file
	if not hash_algorithm.is_empty():
		metrics["hash_algorithm"] = hash_algorithm
	if not expected_hash.is_empty():
		metrics["expected_hash"] = expected_hash
	if not submitted_hash.is_empty():
		metrics["submitted_hash"] = submitted_hash
	metrics["match_status"] = match_status
	if not inspected_component.is_empty():
		metrics["inspected_component"] = inspected_component
	if not decoded_output.is_empty():
		metrics["decoded_output"] = decoded_output
	if not decoded_target.is_empty():
		metrics["decoded_target"] = decoded_target
	if not decoded_mode.is_empty():
		metrics["decoded_mode"] = decoded_mode
