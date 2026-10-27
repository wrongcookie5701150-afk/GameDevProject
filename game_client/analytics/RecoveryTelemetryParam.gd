class_name RecoveryTelemetryParam
extends BaseTelemetryParam

var selected_version: String = ""
var separate_destination: bool = false
var cloud_sync_disabled: bool = false

func sync_metrics() -> void:
	metrics["selected_version"] = selected_version
	metrics["separate_destination"] = separate_destination
	metrics["cloud_sync_disabled"] = cloud_sync_disabled