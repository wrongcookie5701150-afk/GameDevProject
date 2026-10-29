extends Control

const MAIN_MENU_PATH: String = "res://ui/menus/MainMenu.tscn"

@onready var desktop_screen: Control = $CanvasLayer/DesktopScreen
@onready var stage_label: Label = $CanvasLayer/StageBanner/StageLabel
@onready var backup_puzzle: BackupRecoveryPuzzle = $CanvasLayer/Puzzle_321_Backup
@onready var report_puzzle: IncidentReportPuzzle = $CanvasLayer/Puzzle_Last_Boss_Summary
@onready var evaluation_ui: KsaEvaluation = $CanvasLayer/KSA_Evaluation_UI

func _ready() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("hide_inventory"):
		inv.hide_inventory()

	if desktop_screen:
		desktop_screen.set_process_unhandled_input(false)
		desktop_screen.set_process_input(false)
		if desktop_screen.has_method("set_wifi_connected"):
			desktop_screen.call("set_wifi_connected", false)
		var clock_lbl: Label = desktop_screen.find_child("ClockLabel", true, false) as Label
		if clock_lbl:
			clock_lbl.text = "22:15"
		var leave_btn: Button = desktop_screen.find_child("LeavePCButton", true, false) as Button
		if leave_btn:
			leave_btn.hide()
		var start_leave_btn: Button = desktop_screen.find_child("StartMenuLeaveBtn", true, false) as Button
		if start_leave_btn:
			start_leave_btn.hide()
		var icons_box: Control = desktop_screen.find_child("IconsContainer", true, false) as Control
		if icons_box:
			icons_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			for child in icons_box.find_children("*", "Button", true, false):
				if child is Button:
					(child as Button).disabled = true
					(child as Button).mouse_filter = Control.MOUSE_FILTER_IGNORE

	report_puzzle.hide()
	evaluation_ui.hide()
	backup_puzzle.show()
	backup_puzzle.start_puzzle()

	backup_puzzle.puzzle_resolved.connect(_on_backup_recovered)
	report_puzzle.puzzle_resolved.connect(_on_report_submitted)
	evaluation_ui.puzzle_resolved.connect(_on_evaluation_acknowledged)
	stage_label.text = "💻 เครื่อง PC ของเมย์: ขั้นตอนที่ 1/2 - กู้คืนข้อมูลจาก 3-2-1 Backup (เลือกเวลาก่อนติดมัลแวร์ 19:02)"

func _on_backup_recovered() -> void:
	backup_puzzle.hide()
	report_puzzle.show()
	report_puzzle.start_puzzle()
	stage_label.text = "📝 เครื่อง PC ของเมย์: ขั้นตอนที่ 2/2 - กู้คืนข้อมูลสำเร็จ! นั่งทำรายงานสรุปเหตุการณ์ให้เสร็จ"

func _on_report_submitted() -> void:
	report_puzzle.hide()
	evaluation_ui.show()
	evaluation_ui.start_puzzle()
	stage_label.text = "🎉 ทำรายงานเสร็จสมบูรณ์! สรุปผลการประเมินทักษะ (KSA Evaluation)"

func _on_evaluation_acknowledged() -> void:
	TelemetryManager.active_timers.clear()
	var result: Error = get_tree().change_scene_to_file(MAIN_MENU_PATH)
	if result != OK:
		push_error("Unable to return to the main menu: %s" % result)
