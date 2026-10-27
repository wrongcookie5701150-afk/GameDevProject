extends Control

const MAIN_MENU_PATH: String = "res://ui/menus/MainMenu.tscn"

@onready var stage_label: Label = $CanvasLayer/StageLabel
@onready var backup_puzzle: BackupRecoveryPuzzle = $CanvasLayer/Puzzle_321_Backup
@onready var report_puzzle: IncidentReportPuzzle = $CanvasLayer/Puzzle_Last_Boss_Summary
@onready var evaluation_ui: KsaEvaluation = $CanvasLayer/KSA_Evaluation_UI

func _ready() -> void:
	report_puzzle.hide()
	evaluation_ui.hide()
	backup_puzzle.puzzle_resolved.connect(_on_backup_recovered)
	report_puzzle.puzzle_resolved.connect(_on_report_submitted)
	evaluation_ui.puzzle_resolved.connect(_on_evaluation_acknowledged)
	stage_label.text = "Recovery and Assessment"

func _on_backup_recovered() -> void:
	backup_puzzle.hide()
	report_puzzle.show()
	report_puzzle.start_puzzle()
	stage_label.text = "Recovery complete. Document the incident."

func _on_report_submitted() -> void:
	report_puzzle.hide()
	evaluation_ui.show()
	evaluation_ui.start_puzzle()
	stage_label.text = "Incident report complete. Review your assessment."

func _on_evaluation_acknowledged() -> void:
	TelemetryManager.active_timers.clear()
	var result: Error = get_tree().change_scene_to_file(MAIN_MENU_PATH)
	if result != OK:
		push_error("Unable to return to the main menu: %s" % result)