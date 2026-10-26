class_name IncidentTelemetryParam
extends BaseTelemetryParam

var wifi_disabled: bool = false
var lan_unplugged: bool = false
var personal_accounts_unlinked: bool = false
var no_important_files: bool = false

func is_environment_isolated() -> bool:
	return wifi_disabled and lan_unplugged and personal_accounts_unlinked and no_important_files

func sync_metrics() -> void:
	metrics["wifi_disabled"] = wifi_disabled
	metrics["lan_unplugged"] = lan_unplugged
	metrics["personal_accounts_unlinked"] = personal_accounts_unlinked
	metrics["no_important_files"] = no_important_files
	metrics["isolated_environment"] = is_environment_isolated()
