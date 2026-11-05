class_name DesktopScreenController extends Control

## Simulated OS desktop for May's PC (Story Scenes 2-5).

const BEDROOM_SCENE_PATH: String = "res://scenes/scene_01_intro/Scene_01_Intro.tscn"

# System fonts & tray textures
const TEX_WIFI_CONNECTED: Texture2D = preload("res://assets/Icon32x32/world_enable.png")
const TEX_WIFI_DISCONNECTED: Texture2D = preload("res://assets/Icon32x32/world_disable.png")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")
const FONT_PIXEL: FontFile = preload("res://assets/fonts/Press_Start_2P/PressStart2P-Regular.ttf")

signal wifi_toggled(is_connected: bool)
signal closed()

# Desktop & window containers
var icons_container: MarginContainer
var window_container: Control

# Application windows
var gg_disk_window: Control
var ms_word_window: Control
var downloaded_folder_window: Control
var discord_window: Control

# Taskbar controls
var start_button: Button
var start_menu_popup: PanelContainer
var clock_label: Label
var taskbar_tabs_container: HBoxContainer
var leave_pc_button: Button
var start_menu_leave_btn: Button

# Start Menu buttons
var menu_gg_disk: Button
var menu_word: Button
var menu_files: Button
var menu_discord: Button

# Wi-Fi tray & modal controls
var wifi_tray_btn: Button
var wifi_popup: PanelContainer
var wifi_toggle_btn: Button
var wifi_status_label: Label
var wifi_cloud_sync_label: Label
var wifi_close_btn: Button

# Desktop icon buttons
var ggdisk_btn: Button
var msword_btn: Button
var discord_btn: Button
var folder_btn: Button

# Toast notification
var notification_toast: PanelContainer
var toast_label: Label
var _toast_timer: SceneTreeTimer

# State
var is_wifi_connected: bool = true
var is_ransomware_triggered: bool = false
var story_time_string: String = "19:02"
var is_folder_downloaded: bool = false

# Taskbar tab styles
var _tab_style_active: StyleBoxFlat
var _tab_style_inactive: StyleBoxFlat

func _ready() -> void:
	_resolve_all_nodes()
	_init_taskbar_styles()
	_init_taskbar()
	_connect_icons()
	_connect_window_signals()
	_hide_all_windows()
	_update_clock()
	
	# Initially, the work folder has not been downloaded yet.
	# Folder button is hidden until player downloads it from GG Disk.
	if folder_btn:
		folder_btn.visible = false
	if menu_files:
		menu_files.visible = false
	
	visibility_changed.connect(_on_self_visibility_changed)
	_on_self_visibility_changed()

func _on_self_visibility_changed() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv:
		if visible:
			inv.hide_inventory()
		else:
			inv.show_inventory()

# Safe node lookup
func _find_node_safe(node_name: String, search_root: Node = null) -> Node:
	var root: Node = search_root if search_root else self
	if root.has_node("%" + node_name):
		return root.get_node("%" + node_name)
	var found: Node = root.find_child(node_name, true, false)
	if found:
		return found
	return null

func _resolve_all_nodes() -> void:
	icons_container = _find_node_safe("IconsContainer") as MarginContainer
	window_container = _find_node_safe("WindowContainer") as Control
	
	gg_disk_window = _find_node_safe("GgDisk", window_container) as Control
	ms_word_window = _find_node_safe("MsWord", window_container) as Control
	downloaded_folder_window = _find_node_safe("DownloadedFolder", window_container) as Control
	discord_window = _find_node_safe("DiscordApp", window_container) as Control
	
	# Taskbar
	start_button = _find_node_safe("StartButton") as Button
	start_menu_popup = _find_node_safe("StartMenuPopup") as PanelContainer
	clock_label = _find_node_safe("ClockLabel") as Label
	taskbar_tabs_container = _find_node_safe("TaskbarTabsContainer") as HBoxContainer
	leave_pc_button = _find_node_safe("LeavePCButton") as Button
	start_menu_leave_btn = _find_node_safe("StartMenuLeaveBtn") as Button
	
	# Start Menu Buttons
	menu_gg_disk = _find_node_safe("MenuGGDisk") as Button
	menu_word = _find_node_safe("MenuWord") as Button
	menu_files = _find_node_safe("MenuFiles") as Button
	menu_discord = _find_node_safe("MenuDiscord") as Button
	
	# Wi-Fi Controls
	wifi_tray_btn = _find_node_safe("WifiTrayButton") as Button
	wifi_popup = _find_node_safe("WifiPopup") as PanelContainer
	wifi_toggle_btn = _find_node_safe("WifiToggleBtn") as Button
	wifi_status_label = _find_node_safe("WifiStatusLabel") as Label
	wifi_cloud_sync_label = _find_node_safe("WifiCloudSyncLabel") as Label
	wifi_close_btn = _find_node_safe("WifiCloseBtn") as Button
	
	# Desktop Icon Buttons
	ggdisk_btn = _find_node_safe("GGdisk") as Button
	msword_btn = _find_node_safe("MSword") as Button
	discord_btn = _find_node_safe("Discord") as Button
	folder_btn = _find_node_safe("Folder") as Button
	
	# Toast Notification
	notification_toast = _find_node_safe("NotificationToast") as PanelContainer
	toast_label = _find_node_safe("ToastLabel") as Label

func _init_taskbar_styles() -> void:
	_tab_style_active = StyleBoxFlat.new()
	_tab_style_active.bg_color = Color(0.18, 0.28, 0.44, 0.95)
	_tab_style_active.border_width_bottom = 2
	_tab_style_active.border_color = Color(0.35, 0.75, 1.0, 1.0)
	_tab_style_active.content_margin_left = 5.0
	_tab_style_active.content_margin_right = 5.0
	_tab_style_active.content_margin_top = 1.0
	_tab_style_active.content_margin_bottom = 1.0
	_tab_style_active.corner_radius_top_left = 2
	_tab_style_active.corner_radius_top_right = 2
	
	_tab_style_inactive = StyleBoxFlat.new()
	_tab_style_inactive.bg_color = Color(0.1, 0.14, 0.22, 0.75)
	_tab_style_inactive.border_width_bottom = 0
	_tab_style_inactive.content_margin_left = 5.0
	_tab_style_inactive.content_margin_right = 5.0
	_tab_style_inactive.content_margin_top = 1.0
	_tab_style_inactive.content_margin_bottom = 1.0
	_tab_style_inactive.corner_radius_top_left = 2
	_tab_style_inactive.corner_radius_top_right = 2

func _init_taskbar() -> void:
	if clock_label:
		clock_label.text = story_time_string
	if start_menu_popup:
		start_menu_popup.visible = false
	if wifi_popup:
		wifi_popup.visible = false
	if notification_toast:
		notification_toast.visible = false
	
	# Connect taskbar buttons
	if start_button:
		start_button.pressed.connect(_toggle_start_menu)
	if wifi_tray_btn:
		wifi_tray_btn.pressed.connect(_toggle_wifi_popup)
	if wifi_toggle_btn:
		wifi_toggle_btn.pressed.connect(_on_wifi_toggle_pressed)
	if wifi_close_btn:
		wifi_close_btn.pressed.connect(func() -> void: if wifi_popup: wifi_popup.visible = false)
	
	# Power button: leave PC and return to bedroom
	if leave_pc_button:
		leave_pc_button.pressed.connect(_on_leave_pc_pressed)
	if start_menu_leave_btn:
		start_menu_leave_btn.pressed.connect(_on_leave_pc_pressed)
	
	# Start Menu app launchers
	if menu_gg_disk:
		menu_gg_disk.pressed.connect(func() -> void: _on_app_activated("gg_disk"))
	if menu_word:
		menu_word.pressed.connect(func() -> void: _on_app_activated("ms_word"))
	if menu_files:
		menu_files.pressed.connect(func() -> void: _on_app_activated("files"))
	if menu_discord:
		menu_discord.pressed.connect(func() -> void: _on_app_activated("discord"))

func _connect_icons() -> void:
	if ggdisk_btn:
		ggdisk_btn.pressed.connect(func() -> void: _on_app_activated("gg_disk"))
	if msword_btn:
		msword_btn.pressed.connect(func() -> void: _on_app_activated("ms_word"))
	if discord_btn:
		discord_btn.pressed.connect(func() -> void: _on_app_activated("discord"))
	if folder_btn:
		folder_btn.pressed.connect(func() -> void: _on_app_activated("files"))

func _connect_window_signals() -> void:
	# GG Disk window
	if gg_disk_window:
		if gg_disk_window.has_signal("folder_downloaded"):
			gg_disk_window.connect("folder_downloaded", Callable(self, "_on_folder_downloaded_from_disk"))
		if gg_disk_window.has_signal("minimize_requested"):
			gg_disk_window.connect("minimize_requested", func() -> void: _minimize_app_window(gg_disk_window))
		if gg_disk_window.has_signal("close_requested"):
			gg_disk_window.connect("close_requested", func() -> void: _close_app_window(gg_disk_window))
	
	# Downloaded folder window
	if downloaded_folder_window:
		if downloaded_folder_window.has_signal("file_opened"):
			downloaded_folder_window.connect("file_opened", Callable(self, "_on_file_opened_from_folder"))
		if downloaded_folder_window.has_signal("minimize_requested"):
			downloaded_folder_window.connect("minimize_requested", func() -> void: _minimize_app_window(downloaded_folder_window))
		if downloaded_folder_window.has_signal("close_requested"):
			downloaded_folder_window.connect("close_requested", func() -> void: _close_app_window(downloaded_folder_window))
	
	# MS Word window
	if ms_word_window:
		if ms_word_window.has_signal("minimize_requested"):
			ms_word_window.connect("minimize_requested", func() -> void: _minimize_app_window(ms_word_window))
		if ms_word_window.has_signal("close_requested"):
			ms_word_window.connect("close_requested", func() -> void: _close_app_window(ms_word_window))
	
	# Discord window
	if discord_window:
		if discord_window.has_signal("minimize_requested"):
			discord_window.connect("minimize_requested", func() -> void: _minimize_app_window(discord_window))
		if discord_window.has_signal("close_requested"):
			discord_window.connect("close_requested", func() -> void: _close_app_window(discord_window))

# When download is triggered from GG Disk
func _on_folder_downloaded_from_disk() -> void:
	is_folder_downloaded = true
	if folder_btn:
		folder_btn.visible = true
	if menu_files:
		menu_files.visible = true
	
	_show_toast("🔔 GG Disk: ดาวน์โหลดโฟลเดอร์ 'งานกลุ่ม' ลง Desktop สำเร็จ!")
	
	# Send T03 Telemetry event
	TelemetryManager.track_event(
		"Scene_02",
		"T03",
		"download_folder",
		0.0,
		true,
		1,
		false,
		{"source": "gg_disk", "target": "งานกลุ่ม"}
	)

# When Report.docx is clicked inside the downloaded folder
func _on_file_opened_from_folder(file_name: String) -> void:
	if file_name.to_lower().contains("report"):
		_open_app_window(ms_word_window, "MS Word")
		if ms_word_window and ms_word_window.has_method("open_document"):
			ms_word_window.call("open_document")
	elif file_name.to_lower().contains("presentation"):
		_show_toast("Presentation.ppxt: สไลด์พรีเซนต์งานกลุ่ม")
	elif file_name.to_lower().contains("network") or file_name.to_lower().contains("png"):
		_show_toast("Network Diagram.png: แผนผังระบบเครือข่าย")
	elif file_name.to_lower().contains("readme"):
		_show_toast("ReadMe: ไฟล์บันทึกข้อมูลการกู้คืน")

func _show_toast(message: String) -> void:
	if not notification_toast or not toast_label:
		return
	toast_label.text = message
	notification_toast.show()
	notification_toast.move_to_front()
	
	_toast_timer = get_tree().create_timer(3.5)
	_toast_timer.timeout.connect(func() -> void:
		if notification_toast:
			notification_toast.hide()
	)

func _hide_all_windows() -> void:
	if gg_disk_window:
		gg_disk_window.hide()
	if ms_word_window:
		ms_word_window.hide()
	if downloaded_folder_window:
		downloaded_folder_window.hide()
	if discord_window:
		discord_window.hide()

# App launcher router
func _on_app_activated(app_id: String) -> void:
	if start_menu_popup:
		start_menu_popup.visible = false
	if wifi_popup:
		wifi_popup.visible = false
		
	match app_id:
		"gg_disk":
			_open_app_window(gg_disk_window, "GG Disk")
		"ms_word":
			if is_folder_downloaded:
				_open_app_window(ms_word_window, "MS Word")
				if ms_word_window and ms_word_window.has_method("open_document"):
					ms_word_window.call("open_document")
			else:
				_show_toast("ยังไม่มีไฟล์ Report.docx! กรุณาดาวน์โหลดจาก GG Disk ก่อน")
		"files":
			if is_folder_downloaded:
				_open_app_window(downloaded_folder_window, "งานกลุ่ม")
			else:
				_show_toast("ยังไม่มีโฟลเดอร์งานกลุ่ม! กรุณาดาวน์โหลดจาก GG Disk ก่อน")
		"discord":
			_open_app_window(discord_window, "Discord")
		_:
			print("[Desktop] Unknown app id: ", app_id)

# Open window and register/activate taskbar tab
func _open_app_window(win: Control, tab_title: String) -> void:
	if not win:
		return
	win.show()
	win.move_to_front()
	_update_taskbar_tab(win, tab_title, true)
	_highlight_active_tab(win)

# Minimize window (keeps taskbar tab but unhighlights it)
func _minimize_app_window(win: Control) -> void:
	if not win:
		return
	win.hide()
	_highlight_active_tab(null)

# Close window (hides window and removes tab from taskbar)
func _close_app_window(win: Control) -> void:
	if not win:
		return
	win.hide()
	_remove_taskbar_tab(win)
	_highlight_active_tab(null)

# Manage taskbar tabs
func _update_taskbar_tab(win: Control, tab_title: String, is_active: bool) -> void:
	if not taskbar_tabs_container or not win:
		return
	var tab_name: String = "Tab_" + win.name
	var existing_tab: Button = taskbar_tabs_container.get_node_or_null(tab_name) as Button
	if not existing_tab and is_active:
		var new_tab: Button = Button.new()
		new_tab.name = tab_name
		new_tab.text = " " + tab_title.substr(0, 14)
		new_tab.custom_minimum_size = Vector2(65, 16)
		new_tab.alignment = HORIZONTAL_ALIGNMENT_LEFT
		new_tab.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		new_tab.add_theme_font_override("font", FONT_MONO)
		new_tab.add_theme_font_size_override("font_size", 7)
		new_tab.add_theme_stylebox_override("normal", _tab_style_active)
		new_tab.add_theme_stylebox_override("hover", _tab_style_active)
		new_tab.add_theme_stylebox_override("pressed", _tab_style_active)
		new_tab.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		
		new_tab.pressed.connect(func() -> void:
			if win.visible:
				# Minimize
				win.hide()
				_highlight_active_tab(null)
			else:
				# Restore
				win.show()
				win.move_to_front()
				_highlight_active_tab(win)
		)
		taskbar_tabs_container.add_child(new_tab)
		_highlight_active_tab(win)
	elif existing_tab and not is_active:
		existing_tab.queue_free()

func _remove_taskbar_tab(win: Control) -> void:
	if not taskbar_tabs_container or not win:
		return
	var tab_name: String = "Tab_" + win.name
	var existing_tab: Button = taskbar_tabs_container.get_node_or_null(tab_name) as Button
	if existing_tab:
		existing_tab.queue_free()

func _highlight_active_tab(active_win: Control) -> void:
	if not taskbar_tabs_container:
		return
	for child in taskbar_tabs_container.get_children():
		if child is Button:
			var is_current: bool = (active_win != null and child.name == "Tab_" + active_win.name and active_win.visible)
			if is_current:
				child.add_theme_stylebox_override("normal", _tab_style_active)
				child.add_theme_stylebox_override("hover", _tab_style_active)
				child.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			else:
				child.add_theme_stylebox_override("normal", _tab_style_inactive)
				child.add_theme_stylebox_override("hover", _tab_style_active)
				child.add_theme_color_override("font_color", Color(0.75, 0.82, 0.9, 0.8))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos: Vector2 = event.global_position
		
		# Dismiss Start Menu when clicking outside
		if start_menu_popup and start_menu_popup.visible:
			var menu_rect: Rect2 = start_menu_popup.get_global_rect()
			var start_btn_rect: Rect2 = start_button.get_global_rect() if start_button else Rect2()
			if not menu_rect.has_point(click_pos) and not start_btn_rect.has_point(click_pos):
				start_menu_popup.visible = false
		
		# Dismiss Wi-Fi popup when clicking outside
		if wifi_popup and wifi_popup.visible:
			var wifi_rect: Rect2 = wifi_popup.get_global_rect()
			var tray_btn_rect: Rect2 = wifi_tray_btn.get_global_rect() if wifi_tray_btn else Rect2()
			if not wifi_rect.has_point(click_pos) and not tray_btn_rect.has_point(click_pos):
				wifi_popup.visible = false

# Sync taskbar clock to incident timeline (19:02 -> 21:25)
func _update_clock() -> void:
	if clock_label:
		clock_label.text = story_time_string

func _toggle_start_menu() -> void:
	if start_menu_popup:
		start_menu_popup.visible = !start_menu_popup.visible
		if start_menu_popup.visible and wifi_popup:
			wifi_popup.visible = false

func _toggle_wifi_popup() -> void:
	if wifi_popup:
		wifi_popup.visible = !wifi_popup.visible
		if wifi_popup.visible and start_menu_popup:
			start_menu_popup.visible = false

func _on_wifi_toggle_pressed() -> void:
	set_wifi_connected(!is_wifi_connected)

func set_wifi_connected(connected: bool) -> void:
	if is_wifi_connected == connected:
		return
	is_wifi_connected = connected
	_update_wifi_ui()
	wifi_toggled.emit(is_wifi_connected)
	if not is_wifi_connected:
		print("[Story Timeline] 21:23:54 | Wi-Fi disconnected by user. CloudSync.exe paused.")
	else:
		print("[Network] Wi-Fi connected to University_WiFi_5G.")

func _update_wifi_ui() -> void:
	if wifi_tray_btn:
		if is_wifi_connected:
			wifi_tray_btn.icon = TEX_WIFI_CONNECTED
			wifi_tray_btn.text = "Wi-Fi"
			wifi_tray_btn.tooltip_text = "Wi-Fi: University_WiFi_5G (เชื่อมต่อแล้ว)"
			wifi_tray_btn.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5, 1))
		else:
			wifi_tray_btn.icon = TEX_WIFI_DISCONNECTED
			wifi_tray_btn.text = "Offline"
			wifi_tray_btn.tooltip_text = "Wi-Fi: Disconnected (ตัดการเชื่อมต่อแล้ว)"
			wifi_tray_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1))
	
	if wifi_status_label:
		if is_wifi_connected:
			wifi_status_label.text = "สถานะ: เชื่อมต่อแล้ว (Connected)"
			wifi_status_label.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5, 1))
		else:
			wifi_status_label.text = "สถานะ: ตัดการเชื่อมต่อแล้ว (Offline)"
			wifi_status_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1))

func _on_leave_pc_pressed() -> void:
	print("[Desktop] Leaving PC, returning to bedroom...")
	closed.emit()
	if get_parent() is CanvasLayer:
		hide()
	else:
		get_tree().change_scene_to_file(BEDROOM_SCENE_PATH)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused and (focused is LineEdit or focused is TextEdit):
			return
		_on_leave_pc_pressed()
		get_viewport().set_input_as_handled()
