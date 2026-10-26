class_name OSTelemetryParam
extends BaseTelemetryParam

var object_id: String = ""
var action_name: String = ""
var selected_timestamp: String = ""
var selected_email: String = ""
var domain_checked: String = ""
var selected_option_id: String = ""

func sync_metrics() -> void:
	if not object_id.is_empty():
		metrics["object_id"] = object_id
	if not action_name.is_empty():
		metrics["action"] = action_name
	if not selected_timestamp.is_empty():
		metrics["selected_timestamp"] = selected_timestamp
	if not selected_email.is_empty():
		metrics["selected_email"] = selected_email
	if not domain_checked.is_empty():
		metrics["domain_checked"] = domain_checked
	if not selected_option_id.is_empty():
		metrics["selected_option_id"] = selected_option_id
