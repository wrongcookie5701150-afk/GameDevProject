class_name DesktopScreenController extends Control

## Simulated OS desktop for May's PC (Story Scenes 2-5).

const BEDROOM_SCENE_PATH: String = "res://scenes/scene_01_intro/Scene_01_Intro.tscn"

# System fonts & tray textures
const TEX_WIFI_CONNECTED: Texture2D = preload("res://assets/Icon32x32/world_enable.png")
const TEX_WIFI_DISCONNECTED: Texture2D = preload("res://assets/Icon32x32/world_disable.png")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")
const FONT_PIXEL: FontFile = preload("res://assets/fonts/Press_Start_2P/PressStart2P-Regular.ttf")

signal wifi_toggled(is_connected: bool)

# Desktop & window containers
var icons_container: HBoxContainer
var window_container: Control

# Application windows (simple Control nodes)
var gg_disk_window: Control
var ms_word_window: Control

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

# Incident timeline state (starts at 19:02)
var is_wifi_connected: bool = true
var is_ransomware_triggered: bool = false
var story_time_string: String = "19:02"

# Taskbar tab styles
var _tab_style_active: StyleBoxFlat
var _tab_style_inactive: StyleBoxFlat

func _ready() -> void:
	_resolve_all_nodes()
	_init_taskbar_styles()
	_init_taskbar()
	_connect_icons()
	_hide_all_windows()
	_update_clock()

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
	# Containers & Windows
	icons_container = _find_node_safe("IconsContainer") as HBoxContainer
	window_container = _find_node_safe("WindowContainer") as Control
	
	gg_disk_window = _find_node_safe("GgDisk", window_container) as Control
	ms_word_window = _find_node_safe("MsWord", window_container) as Control
	
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

# Click outside to dismiss Start Menu & Wi-Fi popup
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

# Connect desktop icon click signals
func _connect_icons() -> void:
	if ggdisk_btn:
		ggdisk_btn.pressed.connect(func() -> void: _on_app_activated("gg_disk"))
	if msword_btn:
		msword_btn.pressed.connect(func() -> void: _on_app_activated("ms_word"))
	if discord_btn:
		discord_btn.pressed.connect(func() -> void: _on_app_activated("discord"))
	if folder_btn:
		folder_btn.pressed.connect(func() -> void: _on_app_activated("files"))

func _hide_all_windows() -> void:
	if gg_disk_window:
		gg_disk_window.hide()
	if ms_word_window:
		ms_word_window.hide()

# App launcher router
func _on_app_activated(app_id: String) -> void:
	if start_menu_popup:
		start_menu_popup.visible = false
	if wifi_popup:
		wifi_popup.visible = false
	match app_id:
		"gg_disk":
			_open_app_window(gg_disk_window, "GG Disk", Vector2(120, 42))
		"ms_word":
			_open_app_window(ms_word_window, "MS Word", Vector2(125, 45))
			if ms_word_window and ms_word_window.has_method("open_document"):
				ms_word_window.call("open_document")
		"files":
			print("[Desktop] Files app not implemented yet")
		"discord":
			print("[Desktop] Discord app not implemented yet")
		_:
			print("[Desktop] Unknown app id: ", app_id)

# Open window and register taskbar tab
func _open_app_window(win: Control, tab_title: String, default_pos: Vector2 = Vector2(125, 45)) -> void:
	if not win:
		return
	if not win.visible and (win.position == Vector2.ZERO or win.position.y > 210.0):
		win.position = default_pos
	win.show()
	_update_taskbar_tab(win, tab_title, true)
	_highlight_active_tab(win)

# Sync taskbar tabs with open/closed windows
func _update_taskbar_tab(win: Control, tab_title: String, is_active: bool) -> void:
	if not taskbar_tabs_container or not win:
		return
	var tab_name: String = "Tab_" + win.name
	var existing_tab: Button = taskbar_tabs_container.get_node_or_null(tab_name) as Button
	if not existing_tab and is_active:
		var new_tab: Button = Button.new()
		new_tab.name = tab_name
		new_tab.text = " " + tab_title.substr(0, 12)
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
				win.hide()
				_update_taskbar_tab(win, "", false)
			else:
				win.show()
				_update_taskbar_tab(win, tab_title, true)
				_highlight_active_tab(win)
		)
		taskbar_tabs_container.add_child(new_tab)
		_highlight_active_tab(win)
	elif existing_tab and not is_active:
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
	get_tree().change_scene_to_file(BEDROOM_SCENE_PATH)
