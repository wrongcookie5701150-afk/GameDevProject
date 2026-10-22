class_name DesktopScreenController extends Control

## DesktopScreenController - Full In-game Simulated Desktop for May's PC
## Conforms strictly to Story Content (Scenes 2, 3, 4, 5)

const BEDROOM_SCENE_PATH: String = "res://Scenes/Scene_01_Intro.tscn"

# Preloaded assets for UI & tray (Original Project Fonts)
const TEX_WIFI_CONNECTED: Texture2D = preload("res://assets/Icon32x32/world_enable.png")
const TEX_WIFI_DISCONNECTED: Texture2D = preload("res://assets/Icon32x32/world_disable.png")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")
const FONT_PIXEL: FontFile = preload("res://assets/fonts/Press_Start_2P/PressStart2P-Regular.ttf")

# --- Signals ---
signal wifi_toggled(is_connected: bool)

# --- Desktop Icons Container ---
var icons_container: Control

# --- Window Container ---
var window_container: Control

# --- Applications / Windows ---
var gg_disk_window: DesktopWindow
var ms_word_window: DesktopWindow
var files_window: DesktopWindow
var text_editor_window: DesktopWindow
var discord_window: DesktopWindow
var recycle_bin_window: DesktopWindow

# --- Taskbar Controls ---
var start_button: Button
var start_menu_popup: PanelContainer
var clock_label: Label
var taskbar_tabs_container: HBoxContainer
var leave_pc_button: Button
var start_menu_leave_btn: Button

# --- Start Menu App Buttons ---
var menu_gg_disk: Button
var menu_word: Button
var menu_files: Button
var menu_notepad: Button
var menu_discord: Button
var menu_recycle_bin: Button

# --- Wi-Fi Controls ---
var wifi_tray_btn: Button
var wifi_popup: PanelContainer
var wifi_toggle_btn: Button
var wifi_status_label: Label
var wifi_cloud_sync_label: Label
var wifi_close_btn: Button

# --- In-App Content References ---
# GG Disk
var gg_tab_files_btn: Button
var gg_tab_history_btn: Button
var gg_files_panel: Control
var gg_history_panel: Control
var gg_open_word_btn: Button

# Word Macro Banner
var word_macro_banner: PanelContainer
var enable_content_btn: Button
var word_doc_status: Label

# File Explorer Files
var file_item_report_label: Label
var file_item_data_label: Label
var file_item_pres_label: Label
var file_item_readme: Control
var file_item_report_open_btn: Button
var file_item_readme_open_btn: Button

# Discord Channels & Chat
var btn_chat_mesa: Button
var btn_chat_march: Button
var chat_scroll_mesa: ScrollContainer
var chat_scroll_march: ScrollContainer
var chat_log_mesa: Label
var chat_log_march: Label
var discord_chat_title: Label
var discord_chat_status: Label
var march_notif_badge: Control
var discord_input_bar: Control
var discord_input_placeholder: Label
var _current_discord_channel: String = "mesa"
var _discord_btn_active: StyleBoxFlat
var _discord_btn_inactive: StyleBoxFlat

# Story & System State
var is_wifi_connected: bool = true
var is_ransomware_triggered: bool = false
var story_time_string: String = "19:02"

# Taskbar Tab Styles
var _tab_style_active: StyleBoxFlat
var _tab_style_inactive: StyleBoxFlat

func _ready() -> void:
	_resolve_all_nodes()
	_init_taskbar_styles()
	_init_taskbar()
	_connect_icons()
	_connect_windows()
	_setup_files_explorer()
	_setup_gg_disk()
	_setup_word_window()
	_setup_discord_window()
	_hide_all_windows()
	_update_clock()
	_update_file_status_ui()
	_update_wifi_ui()

## Dynamic Safe Node Lookup: never crashes and never prints debugger errors
func _find_node_safe(node_name: String, search_roots: Array = []) -> Node:
	# 1. Check unique name via has_node to avoid debugger error
	if has_node("%" + node_name):
		return get_node("%" + node_name)
	
	# 2. Check in specific search roots
	for root_node in search_roots:
		if root_node and is_instance_valid(root_node):
			var found: Node = root_node.find_child(node_name, true, false)
			if found:
				return found
	
	# 3. Search whole tree
	var anywhere: Node = find_child(node_name, true, false)
	if anywhere:
		return anywhere
	
	return null

func _resolve_all_nodes() -> void:
	# Containers & Windows
	icons_container = _find_node_safe("IconsContainer") as Control
	window_container = _find_node_safe("WindowContainer") as Control
	
	gg_disk_window = _find_node_safe("GGDiskWindow") as DesktopWindow
	ms_word_window = _find_node_safe("MSWordWindow") as DesktopWindow
	files_window = _find_node_safe("FilesWindow") as DesktopWindow
	text_editor_window = _find_node_safe("TextEditorWindow") as DesktopWindow
	discord_window = _find_node_safe("DiscordWindow") as DesktopWindow
	recycle_bin_window = _find_node_safe("RecycleBinWindow") as DesktopWindow
	
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
	menu_notepad = _find_node_safe("MenuNotepad") as Button
	menu_discord = _find_node_safe("MenuDiscord") as Button
	menu_recycle_bin = _find_node_safe("MenuRecycleBin") as Button
	
	# Wi-Fi Controls
	wifi_tray_btn = _find_node_safe("WifiTrayButton") as Button
	wifi_popup = _find_node_safe("WifiPopup") as PanelContainer
	wifi_toggle_btn = _find_node_safe("WifiToggleBtn") as Button
	wifi_status_label = _find_node_safe("WifiStatusLabel") as Label
	wifi_cloud_sync_label = _find_node_safe("WifiCloudSyncLabel") as Label
	wifi_close_btn = _find_node_safe("WifiCloseBtn") as Button
	
	# GG Disk internal nodes
	gg_tab_files_btn = _find_node_safe("GGTabFilesBtn", [gg_disk_window]) as Button
	gg_tab_history_btn = _find_node_safe("GGTabHistoryBtn", [gg_disk_window]) as Button
	gg_files_panel = _find_node_safe("GGFilesPanel", [gg_disk_window]) as Control
	gg_history_panel = _find_node_safe("GGHistoryPanel", [gg_disk_window]) as Control
	gg_open_word_btn = _find_node_safe("GGOpenWordBtn", [gg_disk_window]) as Button
	
	# MS Word internal nodes
	word_macro_banner = _find_node_safe("WordMacroBanner", [ms_word_window]) as PanelContainer
	enable_content_btn = _find_node_safe("EnableContentBtn", [ms_word_window]) as Button
	word_doc_status = _find_node_safe("WordDocStatus", [ms_word_window]) as Label
	
	# Files Explorer internal nodes
	file_item_report_label = _find_node_safe("FileItemReportLabel", [files_window]) as Label
	file_item_data_label = _find_node_safe("FileItemDataLabel", [files_window]) as Label
	file_item_pres_label = _find_node_safe("FileItemPresLabel", [files_window]) as Label
	file_item_readme = _find_node_safe("FileItemReadme", [files_window]) as Control
	file_item_report_open_btn = _find_node_safe("FileItemReportOpenBtn", [files_window]) as Button
	file_item_readme_open_btn = _find_node_safe("ReadmeOpenBtn", [files_window]) as Button
	
	# Discord internal nodes
	btn_chat_mesa = _find_node_safe("BtnChatMesa", [discord_window]) as Button
	btn_chat_march = _find_node_safe("BtnChatMarch", [discord_window]) as Button
	chat_scroll_mesa = _find_node_safe("ChatScrollMesa", [discord_window]) as ScrollContainer
	chat_scroll_march = _find_node_safe("ChatScrollMarch", [discord_window]) as ScrollContainer
	chat_log_mesa = _find_node_safe("ChatLogMesa", [discord_window]) as Label
	chat_log_march = _find_node_safe("ChatLogMarch", [discord_window]) as Label
	discord_chat_title = _find_node_safe("DiscordChatTitle", [discord_window]) as Label
	discord_chat_status = _find_node_safe("DiscordChatStatus", [discord_window]) as Label
	march_notif_badge = _find_node_safe("MarchNotifBadge", [discord_window]) as Control
	discord_input_bar = _find_node_safe("DiscordInputBar", [discord_window]) as Control
	discord_input_placeholder = _find_node_safe("DiscordInputPlaceholder", [discord_window]) as Label

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
	
	if start_button and not start_button.pressed.is_connected(_toggle_start_menu):
		start_button.pressed.connect(_toggle_start_menu)
	if wifi_tray_btn and not wifi_tray_btn.pressed.is_connected(_toggle_wifi_popup):
		wifi_tray_btn.pressed.connect(_toggle_wifi_popup)
	if wifi_toggle_btn and not wifi_toggle_btn.pressed.is_connected(_on_wifi_toggle_pressed):
		wifi_toggle_btn.pressed.connect(_on_wifi_toggle_pressed)
	if wifi_close_btn and not wifi_close_btn.pressed.is_connected(func() -> void: if wifi_popup: wifi_popup.visible = false):
		wifi_close_btn.pressed.connect(func() -> void: if wifi_popup: wifi_popup.visible = false)
	
	if leave_pc_button and not leave_pc_button.pressed.is_connected(_on_leave_pc_pressed):
		leave_pc_button.pressed.connect(_on_leave_pc_pressed)
	if start_menu_leave_btn and not start_menu_leave_btn.pressed.is_connected(_on_leave_pc_pressed):
		start_menu_leave_btn.pressed.connect(_on_leave_pc_pressed)
	
	# Connect Start Menu apps
	if menu_gg_disk and not menu_gg_disk.pressed.is_connected(func() -> void: _on_app_activated("gg_disk")):
		menu_gg_disk.pressed.connect(func() -> void: _on_app_activated("gg_disk"))
	if menu_word and not menu_word.pressed.is_connected(func() -> void: _on_app_activated("ms_word")):
		menu_word.pressed.connect(func() -> void: _on_app_activated("ms_word"))
	if menu_files and not menu_files.pressed.is_connected(func() -> void: _on_app_activated("files")):
		menu_files.pressed.connect(func() -> void: _on_app_activated("files"))
	if menu_notepad and not menu_notepad.pressed.is_connected(func() -> void: _on_app_activated("notepad")):
		menu_notepad.pressed.connect(func() -> void: _on_app_activated("notepad"))
	if menu_discord and not menu_discord.pressed.is_connected(func() -> void: _on_app_activated("discord")):
		menu_discord.pressed.connect(func() -> void: _on_app_activated("discord"))
	if menu_recycle_bin and not menu_recycle_bin.pressed.is_connected(func() -> void: _on_app_activated("recycle_bin")):
		menu_recycle_bin.pressed.connect(func() -> void: _on_app_activated("recycle_bin"))

## Global input handling: Click outside to close Start Menu & Wi-Fi popup
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos: Vector2 = event.global_position
		
		# Auto-close Start Menu when clicking outside
		if start_menu_popup and start_menu_popup.visible:
			var menu_rect: Rect2 = start_menu_popup.get_global_rect()
			var start_btn_rect: Rect2 = start_button.get_global_rect() if start_button else Rect2()
			if not menu_rect.has_point(click_pos) and not start_btn_rect.has_point(click_pos):
				start_menu_popup.visible = false
		
		# Auto-close Wi-Fi popup when clicking outside
		if wifi_popup and wifi_popup.visible:
			var wifi_rect: Rect2 = wifi_popup.get_global_rect()
			var tray_btn_rect: Rect2 = wifi_tray_btn.get_global_rect() if wifi_tray_btn else Rect2()
			if not wifi_rect.has_point(click_pos) and not tray_btn_rect.has_point(click_pos):
				wifi_popup.visible = false

func _update_clock() -> void:
	if clock_label:
		clock_label.text = story_time_string

func _get_all_desktop_icons() -> Array[DesktopIcon]:
	var result: Array[DesktopIcon] = []
	if not icons_container:
		return result
	for node in icons_container.find_children("*", "DesktopIcon", true, false):
		if node is DesktopIcon:
			result.append(node)
	return result

func _connect_icons() -> void:
	for icon in _get_all_desktop_icons():
		icon._update_ui()
		if not icon.icon_activated.is_connected(_on_app_activated):
			icon.icon_activated.connect(_on_app_activated)
		if not icon.icon_selected.is_connected(_on_icon_selected):
			icon.icon_selected.connect(_on_icon_selected)

func _on_icon_selected(selected_app_id: String) -> void:
	for icon in _get_all_desktop_icons():
		icon.set_selected(icon.app_id == selected_app_id)

func _connect_windows() -> void:
	var windows: Array[DesktopWindow] = [
		gg_disk_window,
		ms_word_window,
		files_window,
		text_editor_window,
		discord_window,
		recycle_bin_window
	]
	for win in windows:
		if win:
			if not win.window_closed.is_connected(_on_window_closed.bind(win)):
				win.window_closed.connect(_on_window_closed.bind(win))
			if not win.window_minimized.is_connected(_on_window_minimized.bind(win)):
				win.window_minimized.connect(_on_window_minimized.bind(win))
			if not win.window_focused.is_connected(_on_window_focused.bind(win)):
				win.window_focused.connect(_on_window_focused.bind(win))

# --- Explorer Content Setup & Resiliency ---
func _setup_files_explorer() -> void:
	if not files_window:
		return
	
	# Connect Open buttons if already present
	if file_item_report_open_btn and not file_item_report_open_btn.pressed.is_connected(func() -> void: _on_app_activated("ms_word")):
		file_item_report_open_btn.pressed.connect(func() -> void: _on_app_activated("ms_word"))
	if file_item_readme_open_btn and not file_item_readme_open_btn.pressed.is_connected(func() -> void: _on_app_activated("notepad")):
		file_item_readme_open_btn.pressed.connect(func() -> void: _on_app_activated("notepad"))
	
	# Allow clicking on Report_Final file card row to open Word
	var file_item_1: Control = _find_node_safe("FileItem1", [files_window]) as Control
	if file_item_1 and not file_item_1.gui_input.is_connected(_on_file_item_1_gui_input):
		file_item_1.mouse_filter = Control.MOUSE_FILTER_STOP
		file_item_1.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		file_item_1.gui_input.connect(_on_file_item_1_gui_input)

func _on_file_item_1_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_app_activated("ms_word")

# --- Google Drive Setup & Resiliency ---
func _setup_gg_disk() -> void:
	if not gg_disk_window:
		return
	
	# Tab switching
	if gg_tab_files_btn and not gg_tab_files_btn.pressed.is_connected(_show_gg_files_tab):
		gg_tab_files_btn.pressed.connect(_show_gg_files_tab)
	if gg_tab_history_btn and not gg_tab_history_btn.pressed.is_connected(_show_gg_history_tab):
		gg_tab_history_btn.pressed.connect(_show_gg_history_tab)
	if gg_open_word_btn and not gg_open_word_btn.pressed.is_connected(func() -> void: _on_app_activated("ms_word")):
		gg_open_word_btn.pressed.connect(func() -> void: _on_app_activated("ms_word"))

func _show_gg_files_tab() -> void:
	if gg_files_panel: gg_files_panel.visible = true
	if gg_history_panel: gg_history_panel.visible = false

func _show_gg_history_tab() -> void:
	if gg_files_panel: gg_files_panel.visible = false
	if gg_history_panel: gg_history_panel.visible = true

# --- MS Word Window Setup ---
func _setup_word_window() -> void:
	if not ms_word_window:
		return
	if enable_content_btn and not enable_content_btn.pressed.is_connected(_on_enable_content_pressed):
		enable_content_btn.pressed.connect(_on_enable_content_pressed)

func _on_enable_content_pressed() -> void:
	trigger_macro_infection()

# --- Discord Window Setup & Channel Switching ---
func _setup_discord_window() -> void:
	if not discord_window:
		return
	
	_discord_btn_active = StyleBoxFlat.new()
	_discord_btn_active.bg_color = Color(0.22, 0.28, 0.44, 0.95)
	_discord_btn_active.border_width_left = 2
	_discord_btn_active.border_color = Color(0.35, 0.75, 1.0, 1.0)
	_discord_btn_active.content_margin_left = 4.0
	_discord_btn_active.content_margin_right = 4.0
	_discord_btn_active.content_margin_top = 2.0
	_discord_btn_active.content_margin_bottom = 2.0
	_discord_btn_active.corner_radius_top_left = 2
	_discord_btn_active.corner_radius_top_right = 2
	_discord_btn_active.corner_radius_bottom_right = 2
	_discord_btn_active.corner_radius_bottom_left = 2
	
	_discord_btn_inactive = StyleBoxFlat.new()
	_discord_btn_inactive.bg_color = Color(0.1, 0.13, 0.2, 0.7)
	_discord_btn_inactive.border_width_left = 0
	_discord_btn_inactive.content_margin_left = 4.0
	_discord_btn_inactive.content_margin_right = 4.0
	_discord_btn_inactive.content_margin_top = 2.0
	_discord_btn_inactive.content_margin_bottom = 2.0
	_discord_btn_inactive.corner_radius_top_left = 2
	_discord_btn_inactive.corner_radius_top_right = 2
	_discord_btn_inactive.corner_radius_bottom_right = 2
	_discord_btn_inactive.corner_radius_bottom_left = 2
	
	if btn_chat_mesa and not btn_chat_mesa.pressed.is_connected(_select_discord_chat.bind("mesa")):
		btn_chat_mesa.pressed.connect(_select_discord_chat.bind("mesa"))
	if btn_chat_march and not btn_chat_march.pressed.is_connected(_select_discord_chat.bind("march")):
		btn_chat_march.pressed.connect(_select_discord_chat.bind("march"))
	
	if march_notif_badge and is_instance_valid(march_notif_badge):
		march_notif_badge.visible = false
	
	_select_discord_chat(_current_discord_channel)

func _select_discord_chat(channel_id: String) -> void:
	_current_discord_channel = channel_id
	if channel_id == "mesa":
		if chat_scroll_mesa and is_instance_valid(chat_scroll_mesa): chat_scroll_mesa.visible = true
		if chat_scroll_march and is_instance_valid(chat_scroll_march): chat_scroll_march.visible = false
		if discord_chat_title and is_instance_valid(discord_chat_title): discord_chat_title.text = "@ Mesasohot131415"
		if discord_input_placeholder and is_instance_valid(discord_input_placeholder):
			discord_input_placeholder.text = "Message @Mesasohot131415"
		if discord_chat_status and is_instance_valid(discord_chat_status):
			discord_chat_status.text = "● Online"
			discord_chat_status.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5, 0.9))
		if btn_chat_mesa and is_instance_valid(btn_chat_mesa):
			btn_chat_mesa.add_theme_stylebox_override("normal", _discord_btn_active)
			btn_chat_mesa.add_theme_stylebox_override("hover", _discord_btn_active)
			btn_chat_mesa.add_theme_stylebox_override("pressed", _discord_btn_active)
			btn_chat_mesa.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		if btn_chat_march and is_instance_valid(btn_chat_march):
			btn_chat_march.add_theme_stylebox_override("normal", _discord_btn_inactive)
			btn_chat_march.add_theme_stylebox_override("hover", _discord_btn_active)
			btn_chat_march.add_theme_stylebox_override("pressed", _discord_btn_active)
			btn_chat_march.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.7))
		_scroll_to_bottom(chat_scroll_mesa)
	elif channel_id == "march":
		if chat_scroll_mesa and is_instance_valid(chat_scroll_mesa): chat_scroll_mesa.visible = false
		if chat_scroll_march and is_instance_valid(chat_scroll_march): chat_scroll_march.visible = true
		if discord_chat_title and is_instance_valid(discord_chat_title): discord_chat_title.text = "@ M4rchupikchu_inw101"
		if discord_input_placeholder and is_instance_valid(discord_input_placeholder):
			discord_input_placeholder.text = "Message @M4rchupikchu_inw101"
		if march_notif_badge and is_instance_valid(march_notif_badge):
			march_notif_badge.visible = false
		if discord_chat_status and is_instance_valid(discord_chat_status):
			discord_chat_status.text = "● In Roblox"
			discord_chat_status.add_theme_color_override("font_color", Color(0.35, 0.75, 1.0, 0.9))
		if btn_chat_mesa and is_instance_valid(btn_chat_mesa):
			btn_chat_mesa.add_theme_stylebox_override("normal", _discord_btn_inactive)
			btn_chat_mesa.add_theme_stylebox_override("hover", _discord_btn_active)
			btn_chat_mesa.add_theme_stylebox_override("pressed", _discord_btn_active)
			btn_chat_mesa.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.7))
		if btn_chat_march and is_instance_valid(btn_chat_march):
			btn_chat_march.add_theme_stylebox_override("normal", _discord_btn_active)
			btn_chat_march.add_theme_stylebox_override("hover", _discord_btn_active)
			btn_chat_march.add_theme_stylebox_override("pressed", _discord_btn_active)
			btn_chat_march.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		_scroll_to_bottom(chat_scroll_march)

func _scroll_to_bottom(scroll_container: ScrollContainer) -> void:
	if not scroll_container or not is_inside_tree():
		return
	await get_tree().process_frame
	if scroll_container and is_instance_valid(scroll_container):
		var v_bar: VScrollBar = scroll_container.get_v_scroll_bar()
		if v_bar:
			v_bar.value = v_bar.max_value

func get_discord_chat_log(channel_id: String) -> Label:
	if channel_id == "march":
		return chat_log_march
	return chat_log_mesa

func add_discord_message(channel_id: String, sender: String, message: String, timestamp: String = "") -> void:
	var target_label: Label = get_discord_chat_log(channel_id)
	if not target_label:
		return
	var time_str: String = timestamp if timestamp != "" else story_time_string
	var formatted: String = "\n\n%s | %s:\n\"%s\"" % [time_str, sender, message]
	target_label.text += formatted
	if channel_id == "mesa" and chat_scroll_mesa:
		_scroll_to_bottom(chat_scroll_mesa)
	elif channel_id == "march" and chat_scroll_march:
		_scroll_to_bottom(chat_scroll_march)

func _hide_all_windows() -> void:
	var windows: Array[DesktopWindow] = [
		gg_disk_window,
		ms_word_window,
		files_window,
		text_editor_window,
		discord_window,
		recycle_bin_window
	]
	for win in windows:
		if win:
			win.hide()

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
		"files":
			_open_app_window(files_window, "งานกลุ่ม", Vector2(130, 50))
		"notepad":
			_open_app_window(text_editor_window, "Notepad", Vector2(130, 48))
		"discord":
			_open_app_window(discord_window, "Discord", Vector2(125, 46))
			_select_discord_chat(_current_discord_channel)
		"recycle_bin":
			_open_app_window(recycle_bin_window, "Trash", Vector2(140, 60))
		_:
			print("[Desktop] Unknown app id: ", app_id)

func _open_app_window(win: DesktopWindow, tab_title: String, default_pos: Vector2 = Vector2(125, 45)) -> void:
	if not win:
		return
	if not win.visible and (win.position == Vector2.ZERO or win.position.y > 210.0):
		win.position = default_pos
	win.open_window()
	_update_taskbar_tab(win, tab_title, true)
	_highlight_active_tab(win)

func _update_taskbar_tab(win: DesktopWindow, tab_title: String, is_active: bool) -> void:
	if not taskbar_tabs_container or not win:
		return
	var tab_name: String = "Tab_" + win.name
	var existing_tab: Button = taskbar_tabs_container.get_node_or_null(tab_name) as Button
	if not existing_tab and is_active:
		var new_tab: Button = Button.new()
		new_tab.name = tab_name
		new_tab.text = " " + tab_title.substr(0, 12)
		if win.window_icon:
			new_tab.icon = win.window_icon
			new_tab.expand_icon = true
			new_tab.set("theme_override_constants/icon_max_width", 11)
			new_tab.set("theme_override_constants/h_separation", 3)
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
				var is_top: bool = (win.get_index() == window_container.get_child_count() - 1)
				if is_top:
					win.minimize_window()
				else:
					win.focus_window()
			else:
				win.open_window()
		)
		taskbar_tabs_container.add_child(new_tab)
		_highlight_active_tab(win)
	elif existing_tab and not is_active:
		existing_tab.queue_free()

func _highlight_active_tab(active_win: DesktopWindow) -> void:
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

func _on_window_closed(win: DesktopWindow) -> void:
	_update_taskbar_tab(win, "", false)

func _on_window_minimized(_win: DesktopWindow) -> void:
	_highlight_active_tab(null)

func _on_window_focused(win: DesktopWindow) -> void:
	_highlight_active_tab(win)

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
	
	if wifi_toggle_btn:
		if is_wifi_connected:
			wifi_toggle_btn.text = "● สัญญาณ Wi-Fi: เปิดใช้งาน"
			wifi_toggle_btn.add_theme_color_override("font_color", Color(0.4, 0.9, 0.6, 1))
		else:
			wifi_toggle_btn.text = "○ สัญญาณ Wi-Fi: ปิดการเชื่อมต่อ"
			wifi_toggle_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1))
	
	if wifi_cloud_sync_label:
		if is_ransomware_triggered:
			if is_wifi_connected:
				wifi_cloud_sync_label.text = "⚠️ CloudSync: กำลังซิงค์ไฟล์ที่ติดมัลแวร์ขึ้นคลาวด์!"
				wifi_cloud_sync_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1))
			else:
				wifi_cloud_sync_label.text = "🛡️ CloudSync: หยุดทำงานแล้ว (มัลแวร์ถูกสกัดกั้น)"
				wifi_cloud_sync_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5, 1))
		else:
			if is_wifi_connected:
				wifi_cloud_sync_label.text = "CloudSync: กำลังทำงานปกติ"
				wifi_cloud_sync_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1, 0.8))
			else:
				wifi_cloud_sync_label.text = "CloudSync: ออฟไลน์ ไม่มีการซิงค์"
				wifi_cloud_sync_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.8))

func _on_leave_pc_pressed() -> void:
	print("[Desktop] Exiting PC, returning to bedroom...")
	if ResourceLoader.exists(BEDROOM_SCENE_PATH):
		get_tree().change_scene_to_file(BEDROOM_SCENE_PATH)
	else:
		push_error("Bedroom scene not found: " + BEDROOM_SCENE_PATH)

# --- Story Integration: Enable Content -> Ransomware Locked ---
func trigger_macro_infection() -> void:
	if is_ransomware_triggered:
		return
	is_ransomware_triggered = true
	story_time_string = "21:23"
	_update_clock()
	
	if word_macro_banner and is_instance_valid(word_macro_banner):
		word_macro_banner.visible = false
	if word_doc_status and is_instance_valid(word_doc_status):
		word_doc_status.text = "สถานะ: ไวรัสทำงานแล้ว - เอกสารกลายเป็น .locked"
		word_doc_status.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	
	_update_file_status_ui()
	_update_wifi_ui()
	
	# Story Alert: P'March messages about Roblox / malware -> show red notification badge on March's contact
	if march_notif_badge and is_instance_valid(march_notif_badge):
		march_notif_badge.visible = true
	
	print("[Story Alert] Macro enabled -> Files locked -> README popped up!")
	if text_editor_window and is_instance_valid(text_editor_window):
		text_editor_window.position = Vector2(130, 48)
		_open_app_window(text_editor_window, "Notepad - README")

func _update_file_status_ui() -> void:
	if is_ransomware_triggered:
		if file_item_report_label and is_instance_valid(file_item_report_label):
			file_item_report_label.text = "Report_Final.docx.locked"
		if file_item_data_label and is_instance_valid(file_item_data_label):
			file_item_data_label.text = "Research_Data.xlsx.locked"
		if file_item_pres_label and is_instance_valid(file_item_pres_label):
			file_item_pres_label.text = "Presentation.pptx.locked"
		if file_item_readme and is_instance_valid(file_item_readme):
			file_item_readme.visible = true
	else:
		if file_item_report_label and is_instance_valid(file_item_report_label):
			file_item_report_label.text = "Report_Final.docx"
		if file_item_data_label and is_instance_valid(file_item_data_label):
			file_item_data_label.text = "Research_Data.xlsx"
		if file_item_pres_label and is_instance_valid(file_item_pres_label):
			file_item_pres_label.text = "Presentation.pptx"
		if file_item_readme and is_instance_valid(file_item_readme):
			file_item_readme.visible = false
