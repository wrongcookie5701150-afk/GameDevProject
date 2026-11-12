extends Control

const SCENE_06_INVESTIGATION_PATH: String = "res://scenes/scene_06_taodam_investigation/Scene_06_TaoDam_Investigation.tscn"

@onready var notebook_screen: Control = $CanvasLayer/NotebookScreen
@onready var checklist: BasePuzzleUI = $CanvasLayer/NotebookScreen/Checklist_UI
@onready var app_login_window: Control = $CanvasLayer/NotebookScreen/AppLoginWindow
@onready var file_explorer_window: Control = $CanvasLayer/NotebookScreen/FileExplorerWindow
@onready var guide_label: Label = $CanvasLayer/NotebookScreen/GuideBanner/GuideLabel
@onready var guide_banner: Control = get_node_or_null("CanvasLayer/NotebookScreen/GuideBanner") as Control
@onready var app_login_close_btn: Button = get_node_or_null("CanvasLayer/NotebookScreen/AppLoginWindow/VBox/TitleBar/AppLoginCloseBtn") as Button
@onready var app_login_action_btn: Button = get_node_or_null("CanvasLayer/NotebookScreen/AppLoginWindow/VBox/BodyVBox/AppLoginActionBtn") as Button
@onready var file_explorer_close_btn: Button = get_node_or_null("CanvasLayer/NotebookScreen/FileExplorerWindow/VBox/TitleBar/FileExplorerCloseBtn") as Button
@onready var file_explorer_action_btn: Button = get_node_or_null("CanvasLayer/NotebookScreen/FileExplorerWindow/VBox/BodyVBox/FileExplorerActionBtn") as Button
@onready var completion_panel: Control = $CanvasLayer/CompletionPanel
@onready var continue_button: Button = $CanvasLayer/CompletionPanel/VBox/ContinueButton

var _wifi_disconnected: bool = false
var _personal_accounts_unlinked: bool = false
var _breach_popup: PanelContainer = null

var _idle_seconds: float = 0.0
var _idle_tier1_sent: bool = false
var _idle_tier2_sent: bool = false
var _active_emphasis_tween: Tween = null
var _emphasized_node: Control = null

var _wifi_tray_btn: Button = null
var _settings_desktop_icon: Button = null
var _files_desktop_icon: Button = null
var _evfile_icon: Button = null

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
	# Checklist_UI is the single source of objectives; hide the redundant guide banner.
	if is_instance_valid(guide_banner):
		guide_banner.hide()
	
	if checklist:
		checklist.mouse_filter = Control.MOUSE_FILTER_IGNORE
		checklist.show()
		checklist.visible = true
		if checklist.has_method("start_puzzle"):
			checklist.start_puzzle()
		if not checklist.puzzle_resolved.is_connected(_on_checklist_completed):
			checklist.puzzle_resolved.connect(_on_checklist_completed)
	
	if continue_button and not continue_button.pressed.is_connected(_on_continue_to_investigation):
		continue_button.pressed.connect(_on_continue_to_investigation)
	
	_setup_taodam_isolation_hooks()
	_setup_draggable_windows()

func _process(delta: float) -> void:
	if completion_panel and completion_panel.visible:
		return
	if checklist and checklist.has_method("is_all_conditions_met") and checklist.is_all_conditions_met():
		return
		
	_idle_seconds += delta
	if _idle_seconds >= 35.0 and not _idle_tier2_sent:
		_idle_tier2_sent = true
		_trigger_idle_tier2_emphasis()
	elif _idle_seconds >= 20.0 and not _idle_tier1_sent:
		_idle_tier1_sent = true
		_trigger_idle_tier1_hint()

func _reset_idle_timer() -> void:
	_idle_seconds = 0.0
	_idle_tier1_sent = false
	_idle_tier2_sent = false
	_clear_target_emphasis()

func _get_current_missing_condition() -> String:
	var vals: Dictionary = {}
	if checklist and checklist.has_method("_checklist_values"):
		vals = checklist._checklist_values()
	if not vals.get("wifi_disabled", false):
		return "wifi"
	if not vals.get("personal_accounts_unlinked", false):
		return "accounts"
	if not vals.get("no_important_files", false):
		return "files"
	return "ready_ev"

func _trigger_idle_tier1_hint() -> void:
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
	if guide_label:
		if thai_font:
			guide_label.add_theme_font_override("font", thai_font)
		guide_label.add_theme_font_size_override("font_size", 6)
		match _get_current_missing_condition():
			"wifi":
				guide_label.text = "💡 คำใบ้พี่มาร์ช (20s): Isolate เครื่องก่อน! สังเกตที่ Taskbar มุมล่างขวา มีปุ่มสัญญาณเน็ตอยู่ ให้คลิกเพื่อตัดการเชื่อมต่อไร้สาย"
			"accounts":
				guide_label.text = "💡 คำใบ้พี่มาร์ช (20s): ตรวจสอบบัญชีในเครื่อง! เปิด '⚙️ ตั้งค่าระบบ' จากไอคอนบนเดสก์ท็อปหรือเมนูเริ่ม เพื่อยืนยันการตัดการซิงค์"
			"files":
				guide_label.text = "💡 คำใบ้พี่มาร์ช (20s): สำรวจไดรฟ์ C: ของเครื่องเต่าดำ โดยเปิด '📁 ไฟล์ในเครื่อง' หรือโฟลเดอร์หลักว่าไม่มีไฟล์สำคัญหลงเหลือ"
			"ready_ev":
				guide_label.text = "💡 คำใบ้พี่มาร์ช (20s): กักกันระบบเสร็จแล้ว! ดับเบิลคลิกไอคอนแฟลชไดรฟ์ 'EV-01' บนเดสก์ท็อปเพื่อเริ่มวิเคราะห์หลักฐาน"

func _trigger_idle_tier2_emphasis() -> void:
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
	if guide_label:
		if thai_font:
			guide_label.add_theme_font_override("font", thai_font)
		guide_label.add_theme_font_size_override("font_size", 6)
	match _get_current_missing_condition():
		"wifi":
			if guide_label:
				guide_label.text = "👉 ชี้เป้า (35s): กดที่ปุ่มสัญญาณ Wi-Fi ที่มุมล่างขวา (กำลังกระพริบไฮไลท์) เพื่อตัดเน็ตทันที!"
			if _wifi_tray_btn:
				_emphasize_target_control(_wifi_tray_btn)
		"accounts":
			if guide_label:
				guide_label.text = "👉 ชี้เป้า (35s): เปิดไอคอน '⚙️ ตั้งค่าระบบ' บนหน้าจอ (กำลังกระพริบไฮไลท์) เพื่อตรวจสอบบัญชี"
			if _settings_desktop_icon:
				_emphasize_target_control(_settings_desktop_icon)
		"files":
			if guide_label:
				guide_label.text = "👉 ชี้เป้า (35s): เปิดไอคอน '📁 ไฟล์ในเครื่อง' บนหน้าจอ (กำลังกระพริบไฮไลท์) เพื่อสำรวจไดรฟ์ C:"
			if _files_desktop_icon:
				_emphasize_target_control(_files_desktop_icon)
		"ready_ev":
			if guide_label:
				guide_label.text = "👉 ชี้เป้า (35s): ดับเบิลคลิกไอคอนแฟลชไดรฟ์ 'EV-01' (กำลังกระพริบไฮไลท์) เพื่อเข้าสู่การสืบสวน"
			if _evfile_icon:
				_emphasize_target_control(_evfile_icon)

func _emphasize_target_control(target_node: Control) -> void:
	if not target_node:
		return
	_clear_target_emphasis()
	_emphasized_node = target_node
	_active_emphasis_tween = create_tween().set_loops()
	_active_emphasis_tween.tween_property(target_node, "modulate", Color(1.8, 1.8, 0.4, 1.0), 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_emphasis_tween.tween_property(target_node, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _clear_target_emphasis() -> void:
	if _active_emphasis_tween and _active_emphasis_tween.is_valid():
		_active_emphasis_tween.kill()
	_active_emphasis_tween = null
	if _emphasized_node and is_instance_valid(_emphasized_node):
		_emphasized_node.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_emphasized_node = null

func _setup_draggable_windows() -> void:
	if app_login_window:
		var login_title: Control = app_login_window.find_child("TitleBar", true, false) as Control
		_make_window_draggable(app_login_window, login_title)
	if file_explorer_window:
		var file_title: Control = file_explorer_window.find_child("TitleBar", true, false) as Control
		_make_window_draggable(file_explorer_window, file_title)
	if notebook_screen:
		var wifi_popup: Control = notebook_screen.find_child("WifiPopup", true, false) as Control
		if wifi_popup:
			var wifi_header: Control = wifi_popup.find_child("WifiHeader", true, false) as Control
			_make_window_draggable(wifi_popup, wifi_header)

func _make_window_draggable(window_box: Control, title_bar: Control) -> void:
	if not window_box or not title_bar:
		return

	var gs = get_node_or_null("/root/GlobalSettings")
	if gs and gs.has_method("make_window_draggable"):
		gs.call("make_window_draggable", window_box, title_bar)
		return

	for child in title_bar.find_children("*", "Control", true, false):
		if child is Control and not (child is BaseButton):
			(child as Control).mouse_filter = Control.MOUSE_FILTER_PASS

	title_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	title_bar.mouse_default_cursor_shape = Control.CURSOR_MOVE

	var drag_state := {
		"is_dragging": false,
		"drag_start_pos": Vector2.ZERO,
		"box_start_pos": Vector2.ZERO
	}

	title_bar.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					drag_state["is_dragging"] = true
					drag_state["drag_start_pos"] = event.global_position
					var cur_gp: Vector2 = window_box.global_position
					window_box.set_anchors_preset(Control.PRESET_TOP_LEFT)
					window_box.global_position = cur_gp
					drag_state["box_start_pos"] = cur_gp
					window_box.move_to_front()
				else:
					drag_state["is_dragging"] = false
		elif event is InputEventMouseMotion and drag_state["is_dragging"]:
			var delta: Vector2 = event.global_position - drag_state["drag_start_pos"]
			var target_pos: Vector2 = drag_state["box_start_pos"] + delta

			var vp_size: Vector2 = get_viewport_rect().size
			if vp_size == Vector2.ZERO:
				vp_size = Vector2(480, 270)
			var box_size: Vector2 = window_box.size
			if box_size == Vector2.ZERO:
				box_size = Vector2(240, 130)

			var min_x: float = -box_size.x + 40.0
			var max_x: float = vp_size.x - 40.0
			var min_y: float = 0.0
			var max_y: float = vp_size.y - 20.0

			target_pos.x = clampf(target_pos.x, min_x, max_x)
			target_pos.y = clampf(target_pos.y, min_y, max_y)

			window_box.global_position = target_pos
	)

func _setup_taodam_isolation_hooks() -> void:
	if not notebook_screen:
		return
	
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
	var mono_font: FontFile = load("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

	# Free internal TaskObjective inside locked notebook_screen.tscn
	var old_task: Control = notebook_screen.get_node_or_null("TaskObjective") as Control
	if old_task:
		old_task.queue_free()
	
	# Ensure WindowContainer does not block desktop icons in top-left corner
	var window_container: Control = notebook_screen.get_node_or_null("WindowContainer") as Control
	if window_container:
		window_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 1. Hide unnecessary personal apps from TaoDam lab laptop (Desktop & Start Menu)
	var discord_icon: Button = notebook_screen.find_child("Discord", true, false) as Button
	if discord_icon:
		discord_icon.hide()
	var ggdisk_icon: Button = notebook_screen.find_child("GGdisk", true, false) as Button
	if ggdisk_icon:
		ggdisk_icon.hide()
	var msword_icon: Button = notebook_screen.find_child("MSword", true, false) as Button
	if msword_icon:
		msword_icon.hide()

	var menu_discord: Button = notebook_screen.find_child("MenuDiscord", true, false) as Button
	if menu_discord:
		menu_discord.hide()
	var menu_ggdisk: Button = notebook_screen.find_child("MenuGGDisk", true, false) as Button
	if menu_ggdisk:
		menu_ggdisk.hide()
	var menu_word: Button = notebook_screen.find_child("MenuWord", true, false) as Button
	if menu_word:
		menu_word.hide()

	# Show EV-01 flashdrive icon from start
	var evfile_icon: Button = notebook_screen.find_child("EvfileIcon", true, false) as Button
	_evfile_icon = evfile_icon
	if evfile_icon:
		evfile_icon.show()
		evfile_icon.visible = true
		if not evfile_icon.pressed.is_connected(_on_evfile_icon_pressed):
			evfile_icon.pressed.connect(_on_evfile_icon_pressed)

	var inspector_icon: Button = notebook_screen.find_child("InspectorIcon", true, false) as Button
	if inspector_icon:
		inspector_icon.hide()
	var decoder_icon: Button = notebook_screen.find_child("DecoderIcon", true, false) as Button
	if decoder_icon:
		decoder_icon.hide()
	var folder_icon: Button = notebook_screen.find_child("Folder", true, false) as Button

	var wifi_tray_btn: Button = notebook_screen.find_child("WifiTrayButton", true, false) as Button
	_wifi_tray_btn = wifi_tray_btn
	var wifi_popup: Control = notebook_screen.find_child("WifiPopup", true, false) as Control
	var wifi_close_btn: Button = notebook_screen.find_child("WifiCloseBtn", true, false) as Button
	var wifi_toggle_btn: Button = notebook_screen.find_child("WifiToggleBtn", true, false) as Button
	var wifi_status_lbl: Label = notebook_screen.find_child("WifiStatusLabel", true, false) as Label
	var ssid_lbl: Label = notebook_screen.find_child("SSIDLabel", true, false) as Label
	var wifi_sync_lbl: Label = notebook_screen.find_child("WifiCloudSyncLabel", true, false) as Label

	var start_btn: Button = notebook_screen.find_child("StartButton", true, false) as Button
	var start_popup: Control = notebook_screen.find_child("StartMenuPopup", true, false) as Control
	var start_leave_btn: Button = notebook_screen.find_child("StartMenuLeaveBtn", true, false) as Button

	var menu_files: Button = notebook_screen.find_child("MenuFiles", true, false) as Button
	var menu_notepad: Button = notebook_screen.find_child("MenuNotepad", true, false) as Button
	var menu_recycle: Button = notebook_screen.find_child("MenuRecycleBin", true, false) as Button

	# Guide Banner is superseded by Checklist_UI (top-right); keep it hidden.
	if is_instance_valid(guide_banner):
		guide_banner.hide()

	if guide_label:
		guide_label.text = "🎯 เป้าหมายการเตรียมเครื่องวิเคราะห์ (Isolation): ตรวจสอบและตัดช่องทางสื่อสารภายนอก บัญชีซิงค์ในตั้งค่าระบบ และพื้นที่จัดเก็บหลักก่อนเปิดหลักฐาน"
		guide_label.add_theme_font_size_override("font_size", 6)
		if thai_font:
			guide_label.add_theme_font_override("font", thai_font)

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
				guide_label.text = "⚠️ กรุณาตรวจสอบเงื่อนไขการ Isolate เต่าดำให้ครบทุกข้อก่อนเริ่มสืบสวน!"
		)

	# 1. Network Disconnect (Wi-Fi)
	var perform_disconnect := func() -> void:
		_wifi_disconnected = true
		_reset_idle_timer()
		if wifi_tray_btn:
			wifi_tray_btn.icon = preload("res://assets/Icon32x32/world_disable.png")
			wifi_tray_btn.text = "No Net"
		if wifi_status_lbl:
			wifi_status_lbl.text = "สถานะ: ตัดการเชื่อมต่อแล้ว (Disconnected)"
			wifi_status_lbl.add_theme_color_override("font_color", Color(0.95, 0.35, 0.35, 1.0))
		if ssid_lbl:
			ssid_lbl.text = "เครือข่าย: ไม่ได้เชื่อมต่อ (Disconnected)"
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

	# 2. System Settings -> Accounts & Sync Window
	_setup_system_settings_window(thai_font, mono_font)

	var open_settings_check := func() -> void:
		_reset_idle_timer()
		if start_popup:
			start_popup.hide()
		if file_explorer_window:
			file_explorer_window.hide()
		if app_login_window:
			app_login_window.show()
			app_login_window.move_to_front()
		# Opening the Accounts & Sync window is the verification step itself.
		_mark_personal_accounts_unlinked()

	# Add Settings button to Start Menu
	if start_popup:
		var start_vbox: VBoxContainer = start_popup.find_child("VBox", true, false) as VBoxContainer
		if start_vbox and not start_vbox.has_node("MenuSettings"):
			var menu_settings := Button.new()
			menu_settings.name = "MenuSettings"
			menu_settings.text = "⚙️ ตั้งค่าระบบ (Settings)"
			menu_settings.icon = preload("res://assets/Icon32x32/tools.png")
			menu_settings.expand_icon = true
			menu_settings.custom_minimum_size = Vector2(0, 16)
			menu_settings.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			menu_settings.alignment = HORIZONTAL_ALIGNMENT_LEFT
			if thai_font:
				menu_settings.add_theme_font_override("font", thai_font)
			menu_settings.add_theme_font_size_override("font_size", 7)
			start_vbox.add_child(menu_settings)
			start_vbox.move_child(menu_settings, 2)
			menu_settings.pressed.connect(open_settings_check)

	# 3. Check File Explorer (Storage Check)
	_setup_file_explorer_window_style(thai_font, mono_font)

	var open_file_check := func() -> void:
		_reset_idle_timer()
		if start_popup:
			start_popup.hide()
		if app_login_window:
			app_login_window.hide()
		if file_explorer_window:
			file_explorer_window.show()
			file_explorer_window.move_to_front()
		if checklist and checklist.has_method("update_condition"):
			checklist.update_condition("no_important_files", true)

	for btn: Button in [menu_files, menu_notepad, menu_recycle, folder_icon]:
		if btn and not btn.pressed.is_connected(open_file_check):
			btn.pressed.connect(open_file_check)

	# Add Settings and Files icons on Desktop
	var icon_vbox = notebook_screen.get_node_or_null("MarginContainer/VBoxContainer")
	if icon_vbox:
		if not icon_vbox.has_node("SettingsDesktopIcon"):
			var settings_icon := Button.new()
			settings_icon.name = "SettingsDesktopIcon"
			settings_icon.text = "⚙️ ตั้งค่าระบบ"
			settings_icon.icon = preload("res://assets/Icon32x32/tools.png")
			settings_icon.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			settings_icon.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
			settings_icon.expand_icon = true
			settings_icon.custom_minimum_size = Vector2(36, 36)
			settings_icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			if thai_font:
				settings_icon.add_theme_font_override("font", thai_font)
			settings_icon.add_theme_font_size_override("font_size", 5)
			settings_icon.pressed.connect(open_settings_check)
			icon_vbox.add_child(settings_icon)
			_settings_desktop_icon = settings_icon

		if not icon_vbox.has_node("FilesDesktopIcon"):
			var files_icon := Button.new()
			files_icon.name = "FilesDesktopIcon"
			files_icon.text = "📁 ไฟล์ในเครื่อง"
			files_icon.icon = preload("res://assets/Icon32x32/folder.png")
			files_icon.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			files_icon.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
			files_icon.expand_icon = true
			files_icon.custom_minimum_size = Vector2(36, 36)
			files_icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			if thai_font:
				files_icon.add_theme_font_override("font", thai_font)
			files_icon.add_theme_font_size_override("font_size", 5)
			files_icon.pressed.connect(open_file_check)
			icon_vbox.add_child(files_icon)
			_files_desktop_icon = files_icon

	# File Explorer: close via the top-right ✕ only (bottom confirm button removed)
	if is_instance_valid(file_explorer_action_btn):
		file_explorer_action_btn.hide()
	if is_instance_valid(file_explorer_close_btn) and file_explorer_window:
		if not file_explorer_close_btn.pressed.is_connected(_on_file_explorer_close_pressed):
			file_explorer_close_btn.pressed.connect(_on_file_explorer_close_pressed)

func _on_file_explorer_close_pressed() -> void:
	_reset_idle_timer()
	if file_explorer_window:
		file_explorer_window.hide()
	if checklist and checklist.has_method("update_condition"):
		checklist.update_condition("no_important_files", true)

func _mark_personal_accounts_unlinked() -> void:
	_reset_idle_timer()
	_personal_accounts_unlinked = true
	if app_login_window:
		var status_lbl: Label = app_login_window.find_child("StatusLabel", true, false) as Label
		if status_lbl:
			status_lbl.text = "💻 เครื่อง: TaoDam-Lab (ชมรมไซเบอร์ - เครื่องส่วนกลาง)\n👤 บัญชีระบบ: TaoDam-Lab-User (บัญชีมาตรฐาน)\n✅ ตรวจสอบแล้ว: ไม่มีบัญชีส่วนตัวหรือคลาวด์ภายนอกผูกค้าง (ตัดการซิงค์เรียบร้อย)"
			status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.55, 1.0))
	if checklist and checklist.has_method("update_condition"):
		checklist.update_condition("personal_accounts_unlinked", true)

func _on_app_login_close_pressed() -> void:
	_mark_personal_accounts_unlinked()
	if app_login_window:
		app_login_window.hide()

func _setup_system_settings_window(thai_font: FontFile, mono_font: FontFile) -> void:
	if not app_login_window:
		return

	# Style window with rounded corners, dark cyber theme, and shadow
	var win_sb := StyleBoxFlat.new()
	win_sb.bg_color = Color(0.09, 0.12, 0.18, 0.98)
	win_sb.border_width_left = 1
	win_sb.border_width_top = 2
	win_sb.border_width_right = 1
	win_sb.border_width_bottom = 1
	win_sb.border_color = Color(0.3, 0.65, 0.95, 0.9)
	win_sb.corner_radius_top_left = 6
	win_sb.corner_radius_top_right = 6
	win_sb.corner_radius_bottom_right = 6
	win_sb.corner_radius_bottom_left = 6
	win_sb.content_margin_left = 8.0
	win_sb.content_margin_top = 6.0
	win_sb.content_margin_right = 8.0
	win_sb.content_margin_bottom = 8.0
	win_sb.shadow_size = 8
	win_sb.shadow_color = Color(0, 0, 0, 0.5)
	app_login_window.add_theme_stylebox_override("panel", win_sb)

	var title_lbl: Label = app_login_window.find_child("Title", true, false) as Label
	if title_lbl:
		title_lbl.text = "⚙️ ตั้งค่าระบบ — บัญชีผู้ใช้และการซิงค์ข้อมูล (Accounts & Sync)"
		if thai_font:
			title_lbl.add_theme_font_override("font", thai_font)
		title_lbl.add_theme_font_size_override("font_size", 7)
		title_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))

	var close_btn: Button = app_login_close_btn
	if not is_instance_valid(close_btn):
		close_btn = app_login_window.find_child("AppLoginCloseBtn", true, false) as Button
	if close_btn:
		close_btn.text = "✕"
		close_btn.add_theme_font_size_override("font_size", 7)
		if mono_font:
			close_btn.add_theme_font_override("font", mono_font)
		if not close_btn.pressed.is_connected(_on_app_login_close_pressed):
			close_btn.pressed.connect(_on_app_login_close_pressed)

	var status_lbl: Label = app_login_window.find_child("StatusLabel", true, false) as Label
	if status_lbl:
		status_lbl.text = "💻 เครื่อง: TaoDam-Lab (ชมรมไซเบอร์ - เครื่องส่วนกลาง)\n👤 บัญชีระบบ: TaoDam-Lab-User (บัญชีมาตรฐาน)\n✅ ตรวจไม่พบบัญชีส่วนตัวหรือคลาวด์ภายนอกที่ผูกค้างไว้"
		if thai_font:
			status_lbl.add_theme_font_override("font", thai_font)
		status_lbl.add_theme_font_size_override("font_size", 7)
		status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.55, 1.0))

	var desc_lbl: Label = app_login_window.find_child("DescLabel", true, false) as Label
	if desc_lbl:
		desc_lbl.text = "หลักการ Isolate: ตรวจสอบและยกเลิกการซิงค์บัญชีภายนอก (Google Drive, Discord, อีเมลส่วนตัว) เพื่อป้องกันไม่ให้ข้อมูลหรือโทเคนถูกส่งออกภายนอก"
		if thai_font:
			desc_lbl.add_theme_font_override("font", thai_font)
		desc_lbl.add_theme_font_size_override("font_size", 6)
		desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.92, 0.85))

	# Bottom confirm button removed: opening/closing (✕) the window completes the check.
	if is_instance_valid(app_login_action_btn):
		app_login_action_btn.hide()

func _setup_file_explorer_window_style(thai_font: FontFile, mono_font: FontFile) -> void:
	if not file_explorer_window:
		return

	var win_sb := StyleBoxFlat.new()
	win_sb.bg_color = Color(0.08, 0.11, 0.16, 0.98)
	win_sb.border_width_left = 1
	win_sb.border_width_top = 2
	win_sb.border_width_right = 1
	win_sb.border_width_bottom = 1
	win_sb.border_color = Color(0.3, 0.65, 0.85, 0.9)
	win_sb.corner_radius_top_left = 6
	win_sb.corner_radius_top_right = 6
	win_sb.corner_radius_bottom_right = 6
	win_sb.corner_radius_bottom_left = 6
	win_sb.content_margin_left = 8.0
	win_sb.content_margin_top = 6.0
	win_sb.content_margin_right = 8.0
	win_sb.content_margin_bottom = 8.0
	win_sb.shadow_size = 8
	win_sb.shadow_color = Color(0, 0, 0, 0.5)
	file_explorer_window.add_theme_stylebox_override("panel", win_sb)

	var title_lbl: Label = file_explorer_window.find_child("Title", true, false) as Label
	if title_lbl:
		title_lbl.text = "📁 พื้นที่จัดเก็บหลัก (Local Storage C:) — TaoDam Lab"
		if thai_font:
			title_lbl.add_theme_font_override("font", thai_font)
		title_lbl.add_theme_font_size_override("font_size", 7)

	var close_btn: Button = file_explorer_window.find_child("FileExplorerCloseBtn", true, false) as Button
	if close_btn:
		close_btn.text = "✕"
		close_btn.add_theme_font_size_override("font_size", 7)
		if mono_font:
			close_btn.add_theme_font_override("font", mono_font)

	var status_lbl: Label = file_explorer_window.find_child("StatusLabel", true, false) as Label
	if status_lbl:
		status_lbl.text = "✅ สำรวจไดรฟ์ C: เรียบร้อย — ไม่พบไฟล์สำคัญที่ไม่ได้สำรองข้อมูล"
		if thai_font:
			status_lbl.add_theme_font_override("font", thai_font)
		status_lbl.add_theme_font_size_override("font_size", 7)

	var desc_lbl: Label = file_explorer_window.find_child("DescLabel", true, false) as Label
	if desc_lbl:
		desc_lbl.text = "เครื่องเต่าดำเป็นเครื่องสำหรับวิเคราะห์มัลแวร์โดยเฉพาะ ไม่มีไฟล์เอกสารงานกลุ่มหรือข้อมูลส่วนตัวหลงเหลือ"
		if thai_font:
			desc_lbl.add_theme_font_override("font", thai_font)
		desc_lbl.add_theme_font_size_override("font_size", 6)

	# Bottom confirm button removed: player closes the window with the top-right ✕.
	if is_instance_valid(file_explorer_action_btn):
		file_explorer_action_btn.hide()

func _on_evfile_icon_pressed() -> void:
	var all_met: bool = false
	if checklist and checklist.has_method("is_all_conditions_met"):
		all_met = checklist.is_all_conditions_met()
	elif checklist and "is_resolved" in checklist:
		all_met = checklist.is_resolved

	if not all_met:
		if checklist and checklist.has_method("submit_puzzle"):
			var cur_vals: Variant = checklist._checklist_values() if checklist.has_method("_checklist_values") else null
			checklist.submit_puzzle(cur_vals)
		_show_isolation_breach_popup()
	else:
		_on_checklist_completed()

func _show_isolation_breach_popup() -> void:
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
	var mono_font: FontFile = load("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

	if not _breach_popup:
		_breach_popup = PanelContainer.new()
		_breach_popup.name = "IsolationBreachPopup"
		_breach_popup.custom_minimum_size = Vector2(360, 175)
		_breach_popup.set_anchors_preset(Control.PRESET_CENTER)
		_breach_popup.offset_left = -180.0
		_breach_popup.offset_top = -87.0
		_breach_popup.offset_right = 180.0
		_breach_popup.offset_bottom = 88.0
		_breach_popup.z_index = 60

		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.14, 0.04, 0.05, 0.98)
		sb.border_width_left = 2
		sb.border_width_top = 2
		sb.border_width_right = 2
		sb.border_width_bottom = 2
		sb.border_color = Color(1.0, 0.25, 0.25, 1.0)
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_right = 6
		sb.corner_radius_bottom_left = 6
		sb.content_margin_left = 0.0
		sb.content_margin_top = 0.0
		sb.content_margin_right = 0.0
		sb.content_margin_bottom = 0.0
		sb.shadow_size = 8
		sb.shadow_color = Color(0, 0, 0, 0.5)
		_breach_popup.add_theme_stylebox_override("panel", sb)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 0)
		_breach_popup.add_child(vbox)

		# Title Bar (Draggable) — same layout/style as terminal.tscn
		var title_sb := StyleBoxFlat.new()
		title_sb.bg_color = Color(0.22, 0.06, 0.07, 1.0)
		title_sb.border_width_bottom = 1
		title_sb.border_color = Color(1.0, 0.25, 0.25, 0.6)
		title_sb.corner_radius_top_left = 6
		title_sb.corner_radius_top_right = 6

		var header_bar := Panel.new()
		header_bar.name = "TitleBar"
		header_bar.custom_minimum_size = Vector2(0, 18)
		header_bar.mouse_default_cursor_shape = Control.CURSOR_MOVE
		header_bar.add_theme_stylebox_override("panel", title_sb)
		vbox.add_child(header_bar)

		var title_hbox := HBoxContainer.new()
		title_hbox.name = "HBox"
		title_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		title_hbox.offset_left = 5.0
		title_hbox.add_theme_constant_override("separation", 4)
		header_bar.add_child(title_hbox)

		var title := Label.new()
		title.name = "TitleLabel"
		title.text = "💥 [SECURITY ALERT]: ละเมิดขั้นตอนการกักกันระบบ (Isolation Breach)!"
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if thai_font:
			title.add_theme_font_override("font", thai_font)
		title.add_theme_font_size_override("font_size", 7)
		title.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
		title_hbox.add_child(title)

		var close_hover_sb := StyleBoxFlat.new()
		close_hover_sb.bg_color = Color(0.91, 0.08, 0.14, 1.0)
		close_hover_sb.corner_radius_top_right = 6
		var close_pressed_sb := StyleBoxFlat.new()
		close_pressed_sb.bg_color = Color(0.75, 0.05, 0.1, 1.0)
		close_pressed_sb.corner_radius_top_right = 6

		var close_btn := Button.new()
		close_btn.name = "ExitButton"
		close_btn.text = "✕"
		close_btn.custom_minimum_size = Vector2(24, 18)
		close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		close_btn.focus_mode = Control.FOCUS_NONE
		if mono_font:
			close_btn.add_theme_font_override("font", mono_font)
		close_btn.add_theme_font_size_override("font_size", 7)
		close_btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		close_btn.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
		close_btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		close_btn.add_theme_stylebox_override("hover", close_hover_sb)
		close_btn.add_theme_stylebox_override("pressed", close_pressed_sb)
		close_btn.pressed.connect(_on_breach_popup_close_pressed)
		title_hbox.add_child(close_btn)

		var body_margin := MarginContainer.new()
		body_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
		body_margin.add_theme_constant_override("margin_left", 8)
		body_margin.add_theme_constant_override("margin_top", 6)
		body_margin.add_theme_constant_override("margin_right", 8)
		body_margin.add_theme_constant_override("margin_bottom", 8)
		vbox.add_child(body_margin)

		var desc := RichTextLabel.new()
		desc.name = "BreachDesc"
		desc.bbcode_enabled = true
		desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if thai_font:
			desc.add_theme_font_override("normal_font", thai_font)
		desc.add_theme_font_size_override("normal_font_size", 6)
		body_margin.add_child(desc)

		var target_parent: Node = get_node_or_null("CanvasLayer")
		if not target_parent:
			target_parent = self
		target_parent.add_child(_breach_popup)
		_make_window_draggable(_breach_popup, header_bar)

	# Dynamic simulation logs based on missed conditions
	var vals: Dictionary = {}
	if checklist and checklist.has_method("_checklist_values"):
		vals = checklist._checklist_values()
	
	var log_lines: Array[String] = []
	if not vals.get("wifi_disabled", false):
		log_lines.append("• [color=#ff7777]ตรวจพบการเชื่อมต่อเครือข่ายไร้สายยังเปิดอยู่:[/color] มัลแวร์พยายามส่ง Beacon ออกไปยัง C2 Server ทันทีที่เสียบไดรฟ์!")
	if not vals.get("personal_accounts_unlinked", false):
		log_lines.append("• [color=#ff7777]ตรวจพบบัญชีในเครื่องยังไม่ได้ตรวจสอบในตั้งค่าระบบ:[/color] มีความเสี่ยงที่โทเคนหรือข้อมูลผู้ใช้จะถูกส่งออกภายนอก!")
	if not vals.get("no_important_files", false):
		log_lines.append("• [color=#ff7777]ตรวจพบพื้นที่จัดเก็บหลักยังไม่ได้รับการสำรวจ:[/color] มีความเสี่ยงที่ข้อมูลภายในเครื่องวิเคราะห์จะได้รับความเสียหาย!")

	if log_lines.is_empty():
		log_lines.append("• ตรวจพบเงื่อนไขการกักกันระบบยังไม่ครบถ้วน กรุณาดำเนินการตามเป้าหมายใน Checklist ให้ครบ")

	var desc_label: RichTextLabel = _breach_popup.find_child("BreachDesc", true, false) as RichTextLabel
	if desc_label:
		desc_label.text = "[color=#ffcccc]ตรวจพบการพยายามเปิดแฟลชไดรฟ์หลักฐาน EV-01 ทั้งที่เงื่อนไข Isolation ยังไม่ครบทุกข้อ!

" + "\n".join(log_lines) + "

[color=#ffff66]หลัก Forensic: ต้องตัดการเชื่อมต่อเครือข่ายและตรวจสอบความพร้อมของระบบก่อนเสียบสื่อหลักฐานเสมอ[/color][/color]"

	_breach_popup.show()
	_breach_popup.move_to_front()

func _on_breach_popup_close_pressed() -> void:
	# Close the alert and return the player to the checklist flow immediately.
	if is_instance_valid(_breach_popup):
		_breach_popup.hide()
	_reset_idle_timer()
	if checklist:
		checklist.visible = true
		var feedback: Label = checklist.find_child("FeedbackLabel", true, false) as Label
		if feedback:
			feedback.text = ""

func _on_checklist_completed() -> void:
	_reset_idle_timer()
	if app_login_window:
		app_login_window.hide()
	if file_explorer_window:
		file_explorer_window.hide()
	if guide_label:
		guide_label.text = "✅ ยืนยันการ Isolate เต่าดำครบถ้วนแล้ว! ดับเบิลคลิกไอคอน EV-01 เพื่อเริ่มการสืบสวน"
	if completion_panel:
		completion_panel.show()

func _on_continue_to_investigation() -> void:
	var result: Error = get_tree().change_scene_to_file(SCENE_06_INVESTIGATION_PATH)
	if result != OK:
		push_error("Unable to load Scene 6 Investigation: %s (error %d)" % [SCENE_06_INVESTIGATION_PATH, result])
