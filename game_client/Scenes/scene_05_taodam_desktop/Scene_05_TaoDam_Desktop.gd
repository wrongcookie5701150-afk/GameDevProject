extends Control

const SCENE_06_INVESTIGATION_PATH: String = "res://scenes/scene_06_taodam_investigation/Scene_06_TaoDam_Investigation.tscn"

@onready var notebook_screen: Control = $CanvasLayer/NotebookScreen
@onready var checklist: BasePuzzleUI = $CanvasLayer/NotebookScreen/Checklist_UI
@onready var app_login_window: Control = $CanvasLayer/NotebookScreen/AppLoginWindow
@onready var file_explorer_window: Control = $CanvasLayer/NotebookScreen/FileExplorerWindow
@onready var guide_label: Label = $CanvasLayer/NotebookScreen/GuideBanner/GuideLabel
@onready var completion_panel: Control = $CanvasLayer/CompletionPanel
@onready var continue_button: Button = $CanvasLayer/CompletionPanel/VBox/ContinueButton

var _wifi_disconnected: bool = false

func _ready() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("hide_inventory"):
		inv.hide_inventory()
	
	if app_login_window:
		app_login_window.hide()
	if file_explorer_window:
		file_explorer_window.hide()
	if completion_panel:
		completion_panel.hide()
	
	if checklist:
		checklist.mouse_filter = Control.MOUSE_FILTER_IGNORE
		checklist.show()
		if checklist.has_method("start_puzzle"):
			checklist.start_puzzle()
		if not checklist.puzzle_resolved.is_connected(_on_checklist_completed):
			checklist.puzzle_resolved.connect(_on_checklist_completed)
	
	if continue_button and not continue_button.pressed.is_connected(_on_continue_to_investigation):
		continue_button.pressed.connect(_on_continue_to_investigation)
	
	_setup_taodam_isolation_hooks()

func _setup_taodam_isolation_hooks() -> void:
	if not notebook_screen:
		return
	
	# Hide internal TaskObjective inside locked notebook_screen.tscn
	var nb_task_obj: Control = notebook_screen.get_node_or_null("TaskObjective") as Control
	if nb_task_obj:
		nb_task_obj.hide()
	
	# Ensure WindowContainer does not block desktop icons in top-left corner
	var window_container: Control = notebook_screen.get_node_or_null("WindowContainer") as Control
	if window_container:
		window_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Hide EV-01 flashdrive icon until Scene 6 (after isolation is complete)
	var evfile_icon: Button = notebook_screen.find_child("EvfileIcon", true, false) as Button
	if evfile_icon:
		evfile_icon.hide()
	
	var inspector_icon: Button = notebook_screen.find_child("InspectorIcon", true, false) as Button
	var decoder_icon: Button = notebook_screen.find_child("DecoderIcon", true, false) as Button
	var discord_icon: Button = notebook_screen.find_child("Discord", true, false) as Button
	var ggdisk_icon: Button = notebook_screen.find_child("GGdisk", true, false) as Button
	var msword_icon: Button = notebook_screen.find_child("MSword", true, false) as Button
	var folder_icon: Button = notebook_screen.find_child("Folder", true, false) as Button
	
	var wifi_tray_btn: Button = notebook_screen.find_child("WifiTrayButton", true, false) as Button
	var wifi_popup: Control = notebook_screen.find_child("WifiPopup", true, false) as Control
	var wifi_close_btn: Button = notebook_screen.find_child("WifiCloseBtn", true, false) as Button
	var wifi_toggle_btn: Button = notebook_screen.find_child("WifiToggleBtn", true, false) as Button
	var wifi_status_lbl: Label = notebook_screen.find_child("WifiStatusLabel", true, false) as Label
	var ssid_lbl: Label = notebook_screen.find_child("SSIDLabel", true, false) as Label
	var wifi_sync_lbl: Label = notebook_screen.find_child("WifiCloudSyncLabel", true, false) as Label

	var start_btn: Button = notebook_screen.find_child("StartButton", true, false) as Button
	var start_popup: Control = notebook_screen.find_child("StartMenuPopup", true, false) as Control
	var start_leave_btn: Button = notebook_screen.find_child("StartMenuLeaveBtn", true, false) as Button
	var menu_discord: Button = notebook_screen.find_child("MenuDiscord", true, false) as Button
	var menu_ggdisk: Button = notebook_screen.find_child("MenuGGDisk", true, false) as Button
	var menu_files: Button = notebook_screen.find_child("MenuFiles", true, false) as Button
	var menu_word: Button = notebook_screen.find_child("MenuWord", true, false) as Button
	var menu_notepad: Button = notebook_screen.find_child("MenuNotepad", true, false) as Button
	var menu_recycle: Button = notebook_screen.find_child("MenuRecycleBin", true, false) as Button

	var app_close_btn: Button = notebook_screen.find_child("AppLoginCloseBtn", true, false) as Button
	var app_action_btn: Button = notebook_screen.find_child("AppLoginActionBtn", true, false) as Button
	var file_close_btn: Button = notebook_screen.find_child("FileExplorerCloseBtn", true, false) as Button
	var file_action_btn: Button = notebook_screen.find_child("FileExplorerActionBtn", true, false) as Button

	if start_btn and start_popup:
		start_btn.pressed.connect(func() -> void:
			start_popup.visible = !start_popup.visible
			if wifi_popup:
				wifi_popup.hide()
		)

	if start_leave_btn:
		start_leave_btn.pressed.connect(func() -> void:
			if start_popup:
				start_popup.hide()
			if guide_label:
				guide_label.text = "⚠️ กรุณาตรวจสอบเงื่อนไขการ Isolate เต่าดำให้ครบทั้ง 4 ข้อก่อนเริ่มสืบสวน!"
		)

	# 1. Network Disconnect (Wi-Fi & LAN)
	var perform_disconnect := func() -> void:
		_wifi_disconnected = true
		if wifi_tray_btn:
			wifi_tray_btn.icon = preload("res://assets/Icon32x32/world_disable.png")
			wifi_tray_btn.text = "No Net"
		if wifi_status_lbl:
			wifi_status_lbl.text = "สถานะ: ตัดการเชื่อมต่อแล้ว (Disconnected)"
			wifi_status_lbl.add_theme_color_override("font_color", Color(0.95, 0.35, 0.35, 1.0))
		if ssid_lbl:
			ssid_lbl.text = "สาย LAN: ไม่ได้เชื่อมต่อ (Unplugged)"
		if wifi_toggle_btn:
			wifi_toggle_btn.text = "สัญญาณ Wi-Fi: ปิดใช้งาน (Disabled)"
		if wifi_sync_lbl:
			wifi_sync_lbl.text = "CloudSync: ปิดการทำงาน (Offline)"
		if checklist and checklist.has_method("update_condition"):
			checklist.update_condition("wifi_disabled", true)
			checklist.update_condition("lan_unplugged", true)

	if wifi_tray_btn and wifi_popup:
		wifi_tray_btn.pressed.connect(func() -> void:
			wifi_popup.visible = !wifi_popup.visible
			if start_popup:
				start_popup.hide()
			perform_disconnect.call()
		)

	if wifi_toggle_btn:
		wifi_toggle_btn.pressed.connect(func() -> void:
			perform_disconnect.call()
		)

	if wifi_close_btn and wifi_popup:
		wifi_close_btn.pressed.connect(func() -> void:
			wifi_popup.hide()
		)

	# 2. Check Personal / Cloud Accounts Not Logged In
	var open_login_check := func() -> void:
		if start_popup:
			start_popup.hide()
		if file_explorer_window:
			file_explorer_window.hide()
		if app_login_window:
			app_login_window.show()
		if checklist and checklist.has_method("update_condition"):
			checklist.update_condition("personal_accounts_unlinked", true)

	for btn: Button in [menu_discord, menu_ggdisk, menu_word, discord_icon, ggdisk_icon, msword_icon, decoder_icon]:
		if btn and not btn.pressed.is_connected(open_login_check):
			btn.pressed.connect(open_login_check)

	if app_close_btn and app_login_window:
		app_close_btn.pressed.connect(func() -> void:
			app_login_window.hide()
		)
	if app_action_btn and app_login_window:
		app_action_btn.pressed.connect(func() -> void:
			app_login_window.hide()
			if checklist and checklist.has_method("update_condition"):
				checklist.update_condition("personal_accounts_unlinked", true)
		)

	# 3. Check File Explorer (No Important Local Files)
	var open_file_check := func() -> void:
		if start_popup:
			start_popup.hide()
		if app_login_window:
			app_login_window.hide()
		if file_explorer_window:
			file_explorer_window.show()
		if checklist and checklist.has_method("update_condition"):
			checklist.update_condition("no_important_files", true)

	for btn: Button in [menu_files, menu_notepad, menu_recycle, folder_icon, inspector_icon, evfile_icon]:
		if btn and not btn.pressed.is_connected(open_file_check):
			btn.pressed.connect(open_file_check)

	if file_close_btn and file_explorer_window:
		file_close_btn.pressed.connect(func() -> void:
			file_explorer_window.hide()
		)
	if file_action_btn and file_explorer_window:
		file_action_btn.pressed.connect(func() -> void:
			file_explorer_window.hide()
			if checklist and checklist.has_method("update_condition"):
				checklist.update_condition("no_important_files", true)
		)

func _on_checklist_completed() -> void:
	if app_login_window:
		app_login_window.hide()
	if file_explorer_window:
		file_explorer_window.hide()
	if guide_label:
		guide_label.text = "✅ ยืนยันการ Isolate เต่าดำครบถ้วนแล้ว! กดปุ่มเพื่อเสียบแฟลชไดรฟ์เริ่มสืบสวน"
	if completion_panel:
		completion_panel.show()

func _on_continue_to_investigation() -> void:
	var result: Error = get_tree().change_scene_to_file(SCENE_06_INVESTIGATION_PATH)
	if result != OK:
		push_error("Unable to load Scene 6 Investigation: %s (error %d)" % [SCENE_06_INVESTIGATION_PATH, result])
