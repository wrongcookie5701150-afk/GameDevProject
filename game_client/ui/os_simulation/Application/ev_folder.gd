class_name EvFolderApp extends Control

## Controller for EV-DRIVE (E:) File Explorer (TaoDam OS Simulation)
## Displays forensic files and folders mirroring inspector_app.gd.
## Initially hidden until the flashdrive is plugged into the TaoDam notebook.

signal closed()
signal file_opened(file_id: String)
signal file_inspect_requested(file_id: String)
signal puzzle_shortcut_requested(task_key: String)

const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

@onready var title_label: Label = find_child("Label", true, false) as Label
@onready var minimize_button: Button = find_child("Minimize", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button
var maximize_button: Button = null

var _is_maximized: bool = false
var _pre_maximize_pos: Vector2 = Vector2(50, 40)
var _pre_maximize_size: Vector2 = Vector2(380, 190)

# Directory buttons
@onready var folder1_btn: Button = find_child("Folder1", true, false) as Button
@onready var folder2_btn: Button = find_child("Folder2", true, false) as Button
@onready var folder3_btn: Button = find_child("Folder3", true, false) as Button
@onready var folder4_btn: Button = find_child("Folder4", true, false) as Button

# File buttons
@onready var file1_btn: Button = find_child("File1", true, false) as Button
@onready var file2_btn: Button = find_child("File2", true, false) as Button
@onready var file3_btn: Button = find_child("File3", true, false) as Button
@onready var file4_btn: Button = find_child("File4", true, false) as Button
@onready var file5_btn: Button = find_child("File5", true, false) as Button

# Optional UI elements (breadcrumbs, details)
@onready var path_label: Label = find_child("PathLabel", true, false) as Label
@onready var details_label: Label = find_child("DetailsLabel", true, false) as Label
@onready var inspect_btn: Button = find_child("InspectBtn", true, false) as Button

var _folder_buttons: Array[Button] = []
var _file_buttons: Array[Button] = []

const FOLDER_DATA: Dictionary = {
	"documents": {
		"path": "E:\\Documents",
		"name": "Documents",
		"files": [
			{
				"id": "report_docx",
				"name": "Report_Final.docx",
				"size": "47.1 KB",
				"type": "Word Document (.docx)",
				"icon": "res://assets/Icon32x32/doc.png",
				"desc": "Annual Security Research Report (Contains embedded macro vbaProject.bin)"
			},
			{
				"id": "vba_macro",
				"name": "vba_extracted_macro.vba",
				"size": "3.4 KB",
				"type": "VBA Macro Script (.vba)",
				"icon": "res://assets/Icon32x32/script.png",
				"desc": "Extracted VBA Macro: invokes TriggerStaging to run Office_Update_Helper"
			}
		]
	},
	"logs": {
		"path": "E:\\Logs",
		"name": "Logs",
		"files": [
			{
				"id": "event_log",
				"name": "Windows_Event_Log.txt",
				"size": "14.8 KB",
				"type": "System Event Log (.txt)",
				"icon": "res://assets/Icon32x32/txt.png",
				"desc": "Exported event timeline (EventID 11, 1, 4104, 106) recording malware launch"
			},
			{
				"id": "drive_log",
				"name": "Drive_Activity.log",
				"size": "5.2 KB",
				"type": "Cloud Audit Log (.log)",
				"icon": "res://assets/Icon32x32/txt.png",
				"desc": "Cloud drive audit trail showing spoofed sender 'mesasohot.sukj@universcity.example'"
			}
		]
	},
	"artifacts": {
		"path": "E:\\Malware_Artifacts",
		"name": "Malware_Artifacts",
		"files": [
			{
				"id": "helper_dat",
				"name": "Office_Update_Helper.dat",
				"size": "12.0 KB",
				"type": "Quarantined Binary (.dat)",
				"icon": "res://assets/Icon32x32/warning.png",
				"desc": "Staged payload in %APPDATA% with XOR/Base64 encoded wiper strings"
			},
			{
				"id": "scheduled_task",
				"name": "scheduled_task.xml",
				"size": "2.8 KB",
				"type": "Task Definition (.xml)",
				"icon": "res://assets/Icon32x32/script_code.png",
				"desc": "Windows Task Scheduler config executing Office_Update_Helper /sc onidle"
			}
		]
	},
	"notes": {
		"path": "E:\\Incident_Notes",
		"name": "Incident_Notes",
		"files": [
			{
				"id": "ransom_note",
				"name": "Ransom_Note.txt",
				"size": "1.5 KB",
				"type": "Text Document (.txt)",
				"icon": "res://assets/Icon32x32/warning.png",
				"desc": "Ransom note: 'ALL YOUR FILES ARE LOCKED! Contact: unlock@blackshield-leak.onion'"
			},
			{
				"id": "manifest",
				"name": "Evidence_Manifest.txt",
				"size": "1.2 KB",
				"type": "Checksum Manifest (.txt)",
				"icon": "res://assets/Icon32x32/txt.png",
				"desc": "Forensic evidence integrity manifest with verified MD5 checksums"
			},
			{
				"id": "readme",
				"name": "README_INCIDENT.txt",
				"size": "820 B",
				"type": "Briefing Notes (.txt)",
				"icon": "res://assets/Icon32x32/info.png",
				"desc": "Case briefing from March outlining forensic objectives"
			}
		]
	}
}

var current_folder_key: String = "documents"
var selected_file_data: Dictionary = {}
var _icon_cache: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_folder_buttons = [folder1_btn, folder2_btn, folder3_btn, folder4_btn]
	_file_buttons = [file1_btn, file2_btn, file3_btn, file4_btn, file5_btn]
	
	_apply_modern_styling()
	_style_window()
	_setup_folder_buttons()
	_setup_file_buttons()
	_setup_window_dragging()
	
	# Open default folder
	open_folder("documents")

func _apply_modern_styling() -> void:
	var window_box: Control = get_node_or_null("ColorRect") as Control
	if not window_box:
		window_box = find_child("ColorRect", true, false) as Control
	if window_box:
		if window_box is ColorRect:
			(window_box as ColorRect).color = Color(0, 0, 0, 0)
		
		var bg_panel: Panel = window_box.get_node_or_null("WinBgPanel") as Panel
		if not bg_panel:
			bg_panel = Panel.new()
			bg_panel.name = "WinBgPanel"
			bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bg_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			window_box.add_child(bg_panel)
			window_box.move_child(bg_panel, 0)
		
		var win_sb := StyleBoxFlat.new()
		win_sb.bg_color = Color(0.11, 0.12, 0.15, 0.98)
		win_sb.corner_radius_top_left = 7
		win_sb.corner_radius_top_right = 7
		win_sb.corner_radius_bottom_left = 7
		win_sb.corner_radius_bottom_right = 7
		win_sb.shadow_size = 6
		win_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		win_sb.shadow_offset = Vector2(0, 3)
		win_sb.border_width_left = 1
		win_sb.border_width_top = 1
		win_sb.border_width_right = 1
		win_sb.border_width_bottom = 1
		win_sb.border_color = Color(0.25, 0.40, 0.65, 0.7)
		bg_panel.add_theme_stylebox_override("panel", win_sb)
		
		var title_bar: Panel = window_box.get_node_or_null("AppTitle") as Panel
		if not title_bar:
			title_bar = window_box.find_child("AppTitle", true, false) as Panel
		if title_bar:
			var title_sb := StyleBoxFlat.new()
			title_sb.bg_color = Color(0.16, 0.17, 0.22, 1.0)
			title_sb.corner_radius_top_left = 7
			title_sb.corner_radius_top_right = 7
			title_sb.corner_radius_bottom_left = 0
			title_sb.corner_radius_bottom_right = 0
			title_sb.border_width_bottom = 1
			title_sb.border_color = Color(0.22, 0.25, 0.35, 0.8)
			title_bar.add_theme_stylebox_override("panel", title_sb)
	
	if title_label:
		title_label.add_theme_font_size_override("font_size", 9)
	if path_label:
		path_label.add_theme_font_size_override("font_size", 7)
	if details_label:
		details_label.add_theme_font_size_override("font_size", 6)
	if inspect_btn:
		inspect_btn.add_theme_font_size_override("font_size", 6)
		var insp_sb := StyleBoxFlat.new()
		insp_sb.bg_color = Color(0.18, 0.38, 0.65, 0.95)
		insp_sb.corner_radius_top_left = 7
		insp_sb.corner_radius_top_right = 7
		insp_sb.corner_radius_bottom_left = 7
		insp_sb.corner_radius_bottom_right = 7
		insp_sb.shadow_size = 6
		insp_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		insp_sb.shadow_offset = Vector2(0, 3)
		insp_sb.border_width_left = 1
		insp_sb.border_width_top = 1
		insp_sb.border_width_right = 1
		insp_sb.border_width_bottom = 1
		insp_sb.border_color = Color(0.4, 0.65, 0.95, 0.8)
		insp_sb.content_margin_left = 6.0
		insp_sb.content_margin_right = 6.0
		insp_sb.content_margin_top = 2.0
		insp_sb.content_margin_bottom = 2.0
		inspect_btn.add_theme_stylebox_override("normal", insp_sb)

	var sidebar := find_child("Sidebar", true, false) as Control
	if sidebar:
		var sb_card := StyleBoxFlat.new()
		sb_card.bg_color = Color(0.12, 0.13, 0.17, 0.9)
		sb_card.corner_radius_top_left = 7
		sb_card.corner_radius_top_right = 7
		sb_card.corner_radius_bottom_left = 7
		sb_card.corner_radius_bottom_right = 7
		sb_card.border_width_left = 1
		sb_card.border_width_top = 1
		sb_card.border_width_right = 1
		sb_card.border_width_bottom = 1
		sb_card.border_color = Color(0.2, 0.24, 0.32, 0.6)
		sidebar.add_theme_stylebox_override("panel", sb_card)

	var content_panel := find_child("Content", true, false) as Control
	if content_panel:
		var cp_card := StyleBoxFlat.new()
		cp_card.bg_color = Color(0.14, 0.15, 0.2, 0.85)
		cp_card.corner_radius_top_left = 7
		cp_card.corner_radius_top_right = 7
		cp_card.corner_radius_bottom_left = 7
		cp_card.corner_radius_bottom_right = 7
		cp_card.border_width_left = 1
		cp_card.border_width_top = 1
		cp_card.border_width_right = 1
		cp_card.border_width_bottom = 1
		cp_card.border_color = Color(0.22, 0.28, 0.38, 0.6)
		content_panel.add_theme_stylebox_override("panel", cp_card)

	var details_panel := find_child("Details", true, false) as Control
	if details_panel:
		var dp_card := StyleBoxFlat.new()
		dp_card.bg_color = Color(0.12, 0.14, 0.18, 0.95)
		dp_card.corner_radius_top_left = 7
		dp_card.corner_radius_top_right = 7
		dp_card.corner_radius_bottom_left = 7
		dp_card.corner_radius_bottom_right = 7
		dp_card.border_width_left = 1
		dp_card.border_width_top = 1
		dp_card.border_width_right = 1
		dp_card.border_width_bottom = 1
		dp_card.border_color = Color(0.24, 0.32, 0.45, 0.7)
		details_panel.add_theme_stylebox_override("panel", dp_card)

func _style_window() -> void:
	var window_box: Control = get_node_or_null("ColorRect") as Control
	if not window_box:
		window_box = find_child("ColorRect", true, false) as Control
	var title_bar: Control = null
	if window_box:
		title_bar = window_box.get_node_or_null("AppTitle") as Control
		if not title_bar:
			title_bar = window_box.find_child("AppTitle", true, false) as Control
	if not title_bar:
		return

	# 1. ตั้งค่า AppTitle ให้ยืดเต็มความกว้างด้านบนของ ColorRect
	title_bar.anchor_left = 0.0
	title_bar.anchor_right = 1.0
	title_bar.offset_left = 0.0
	title_bar.offset_right = 0.0
	title_bar.offset_top = 0.0
	title_bar.offset_bottom = 20.0
	title_bar.custom_minimum_size = Vector2(0, 20)

	# 2. ตั้งค่า AppTitle/HBoxContainer ให้ยืดเต็ม AppTitle
	var title_hbox: HBoxContainer = title_bar.find_child("HBoxContainer", true, false) as HBoxContainer
	if title_hbox:
		title_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		title_hbox.offset_left = 4.0
		title_hbox.offset_right = -4.0
		title_hbox.custom_maximum_size = Vector2.ZERO
		title_hbox.add_theme_constant_override("separation", 2)

	var old_btn_container = title_bar.find_child("ControlButtonsHBox", true, false)
	if old_btn_container:
		for c in old_btn_container.get_children():
			c.reparent(title_hbox)
		old_btn_container.queue_free()

	if not minimize_button:
		minimize_button = title_bar.find_child("Minimize", true, false) as Button
	if not exit_button:
		exit_button = title_bar.find_child("Exit", true, false) as Button

	# 3. จัดการปุ่ม Maximize ให้อยู่คั่นกลางระหว่าง Minimize และ Exit ภายใน title_hbox
	if not maximize_button:
		maximize_button = title_bar.find_child("Maximize", true, false) as Button
		if not maximize_button:
			maximize_button = title_bar.find_child("MaximizeButton", true, false) as Button
		if not maximize_button and title_hbox:
			maximize_button = Button.new()
			maximize_button.name = "Maximize"
			title_hbox.add_child(maximize_button)

	if title_hbox and minimize_button and maximize_button and exit_button:
		var min_idx: int = minimize_button.get_index()
		title_hbox.move_child(maximize_button, min_idx + 1)
		title_hbox.move_child(exit_button, min_idx + 2)

	var title_lbl := title_bar.find_child("Label", true, false) as Label
	if title_lbl:
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var btn_normal := StyleBoxEmpty.new()
	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = Color(1.0, 1.0, 1.0, 0.15)
	btn_hover.corner_radius_top_left = 2
	btn_hover.corner_radius_top_right = 2
	btn_hover.corner_radius_bottom_right = 2
	btn_hover.corner_radius_bottom_left = 2

	var btn_pressed := StyleBoxFlat.new()
	btn_pressed.bg_color = Color(1.0, 1.0, 1.0, 0.25)
	btn_pressed.corner_radius_top_left = 2
	btn_pressed.corner_radius_top_right = 2
	btn_pressed.corner_radius_bottom_right = 2
	btn_pressed.corner_radius_bottom_left = 2

	# Exit button style (dark red #b83333, white text style terminal.tscn)
	var exit_normal := StyleBoxFlat.new()
	exit_normal.bg_color = Color("#b83333")
	exit_normal.corner_radius_top_left = 2
	exit_normal.corner_radius_top_right = 2
	exit_normal.corner_radius_bottom_right = 2
	exit_normal.corner_radius_bottom_left = 2

	var exit_hover := StyleBoxFlat.new()
	exit_hover.bg_color = Color(0.91, 0.08, 0.14, 1.0)
	exit_hover.corner_radius_top_left = 2
	exit_hover.corner_radius_top_right = 2
	exit_hover.corner_radius_bottom_right = 2
	exit_hover.corner_radius_bottom_left = 2

	var exit_pressed := StyleBoxFlat.new()
	exit_pressed.bg_color = Color(0.75, 0.05, 0.1, 1.0)
	exit_pressed.corner_radius_top_left = 2
	exit_pressed.corner_radius_top_right = 2
	exit_pressed.corner_radius_bottom_right = 2
	exit_pressed.corner_radius_bottom_left = 2

	# 4. ตั้งค่าปุ่ม Minimize
	if minimize_button:
		minimize_button.icon = null
		minimize_button.text = "─"
		minimize_button.custom_minimum_size = Vector2(18, 18)
		minimize_button.size = Vector2(18, 18)
		minimize_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		minimize_button.add_theme_font_override("font", FONT_MONO)
		minimize_button.add_theme_font_size_override("font_size", 8)
		minimize_button.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		minimize_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		minimize_button.add_theme_stylebox_override("normal", btn_normal)
		minimize_button.add_theme_stylebox_override("hover", btn_hover)
		minimize_button.add_theme_stylebox_override("pressed", btn_pressed)
		if not minimize_button.pressed.is_connected(_on_close_pressed):
			minimize_button.pressed.connect(_on_close_pressed)

	# 5. ตั้งค่าปุ่ม Maximize
	if maximize_button:
		maximize_button.icon = null
		maximize_button.text = "❐" if _is_maximized else "□"
		maximize_button.custom_minimum_size = Vector2(18, 18)
		maximize_button.size = Vector2(18, 18)
		maximize_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		maximize_button.add_theme_font_override("font", FONT_MONO)
		maximize_button.add_theme_font_size_override("font_size", 8)
		maximize_button.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		maximize_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		maximize_button.add_theme_stylebox_override("normal", btn_normal)
		maximize_button.add_theme_stylebox_override("hover", btn_hover)
		maximize_button.add_theme_stylebox_override("pressed", btn_pressed)
		if not maximize_button.pressed.is_connected(_toggle_maximize):
			maximize_button.pressed.connect(_toggle_maximize)

	# 6. ตั้งค่าปุ่ม Exit
	if exit_button:
		exit_button.icon = null
		exit_button.text = "✕"
		exit_button.custom_minimum_size = Vector2(18, 18)
		exit_button.size = Vector2(18, 18)
		exit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		exit_button.add_theme_font_override("font", FONT_MONO)
		exit_button.add_theme_font_size_override("font_size", 8)
		exit_button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
		exit_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		exit_button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
		exit_button.add_theme_stylebox_override("normal", exit_normal)
		exit_button.add_theme_stylebox_override("hover", exit_hover)
		exit_button.add_theme_stylebox_override("pressed", exit_pressed)
		if not exit_button.pressed.is_connected(_on_close_pressed):
			exit_button.pressed.connect(_on_close_pressed)

	if inspect_btn and not inspect_btn.pressed.is_connected(_on_inspect_pressed):
		inspect_btn.pressed.connect(_on_inspect_pressed)
		inspect_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if title_bar and not title_bar.gui_input.is_connected(_on_title_bar_gui_input):
		title_bar.gui_input.connect(_on_title_bar_gui_input)

func _setup_window_buttons() -> void:
	_style_window()

func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if event.double_click:
			_toggle_maximize()

func _toggle_maximize() -> void:
	var window_box: Control = get_node_or_null("ColorRect") as Control
	if not window_box:
		window_box = find_child("ColorRect", true, false) as Control
	if not window_box:
		return
	
	_is_maximized = !_is_maximized
	if _is_maximized:
		_pre_maximize_pos = window_box.position
		_pre_maximize_size = window_box.size
		window_box.set_anchors_preset(Control.PRESET_TOP_LEFT)
		window_box.position = Vector2(2, 2)
		window_box.size = Vector2(476, 246)
		window_box.custom_minimum_size = Vector2(476, 246)
		if maximize_button:
			maximize_button.text = "❐"
	else:
		window_box.position = _pre_maximize_pos
		window_box.size = _pre_maximize_size
		window_box.custom_minimum_size = _pre_maximize_size
		if maximize_button:
			maximize_button.text = "□"

func _setup_folder_buttons() -> void:
	var keys: Array[String] = ["documents", "logs", "artifacts", "notes"]
	var titles: Array[String] = ["Documents", "Logs", "Malware_Artifacts", "Incident_Notes"]
	
	for i in range(_folder_buttons.size()):
		var btn: Button = _folder_buttons[i]
		if not btn:
			continue
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 6)
		if i < titles.size():
			btn.text = " " + titles[i]
		
		# Set folder icon (compact 10x10 with generous whitespace)
		var folder_tex: Texture2D = _get_texture("res://assets/Icon32x32/folder.png")
		if folder_tex:
			btn.icon = folder_tex
			btn.expand_icon = true
			btn.add_theme_constant_override("icon_max_width", 10)
		
		var f_key: String = keys[i] if i < keys.size() else "documents"
		if not btn.pressed.is_connected(open_folder.bind(f_key)):
			btn.pressed.connect(open_folder.bind(f_key))

func _setup_file_buttons() -> void:
	for i in range(_file_buttons.size()):
		var btn: Button = _file_buttons[i]
		if not btn:
			continue
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.expand_icon = true
		btn.add_theme_constant_override("icon_max_width", 10)
		btn.add_theme_font_size_override("font_size", 6)

func open_folder(folder_key: String) -> void:
	if not FOLDER_DATA.has(folder_key):
		folder_key = "documents"
	current_folder_key = folder_key
	
	var data: Dictionary = FOLDER_DATA[folder_key]
	if path_label:
		path_label.text = " E:\\" + data.get("name", "") + "\\"
	
	# Highlight active folder button
	var keys: Array[String] = ["documents", "logs", "artifacts", "notes"]
	for i in range(_folder_buttons.size()):
		var btn: Button = _folder_buttons[i]
		if not btn:
			continue
		var is_active: bool = (i < keys.size() and keys[i] == folder_key)
		_apply_button_highlight(btn, is_active)
	
	# Populate files
	var files: Array = data.get("files", [])
	for i in range(_file_buttons.size()):
		var btn: Button = _file_buttons[i]
		if not btn:
			continue
		if i < files.size():
			var file_info: Dictionary = files[i]
			btn.visible = true
			btn.text = " %s   (%s)" % [file_info.get("name", ""), file_info.get("size", "")]
			
			var icon_path: String = file_info.get("icon", "res://assets/Icon32x32/txt.png")
			btn.icon = _get_texture(icon_path)
			
			# Reconnect signal for clicking
			for conn in btn.pressed.get_connections():
				btn.pressed.disconnect(conn["callable"])
			btn.pressed.connect(_on_file_selected.bind(file_info))
		else:
			btn.visible = false
	
	# Select first file by default if available
	if files.size() > 0:
		_on_file_selected(files[0])
	else:
		selected_file_data = {}
		if details_label:
			details_label.text = "Folder is empty."
		if inspect_btn:
			inspect_btn.disabled = true

func _on_file_selected(file_info: Dictionary) -> void:
	selected_file_data = file_info
	var f_name: String = file_info.get("name", "")
	var f_type: String = file_info.get("type", "")
	var f_size: String = file_info.get("size", "")
	var f_desc: String = file_info.get("desc", "")
	
	if details_label:
		details_label.text = "%s  |  %s  |  %s\n%s" % [f_name, f_size, f_type, f_desc]
	if inspect_btn:
		inspect_btn.disabled = false
		inspect_btn.text = "Inspect in Inspector 🔍"
		
	# Highlight selected file button
	for btn: Button in _file_buttons:
		if btn and btn.visible:
			var is_selected: bool = btn.text.contains(f_name)
			_apply_button_highlight(btn, is_selected, true)
			
	file_opened.emit(file_info.get("id", ""))

func _on_inspect_pressed() -> void:
	if selected_file_data.is_empty():
		return
	var file_id: String = selected_file_data.get("id", "")
	file_inspect_requested.emit(file_id)

func _on_close_pressed() -> void:
	hide()
	closed.emit()

func _apply_button_highlight(btn: Button, is_active: bool, is_file: bool = false) -> void:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.corner_radius_top_left = 7
	box.corner_radius_top_right = 7
	box.corner_radius_bottom_right = 7
	box.corner_radius_bottom_left = 7
	box.content_margin_left = 5.0
	box.content_margin_right = 5.0
	box.content_margin_top = 2.0
	box.content_margin_bottom = 2.0
	box.set_border_width_all(1)
	
	if is_active:
		if is_file:
			box.bg_color = Color(0.25, 0.35, 0.55, 0.95)
			box.border_color = Color(0.55, 0.75, 1.0, 1.0)
		else:
			box.bg_color = Color(0.35, 0.28, 0.48, 1.0)
			box.border_color = Color(0.7, 0.6, 0.9, 1.0)
	else:
		box.bg_color = Color(0.12, 0.12, 0.16, 0.6)
		box.border_color = Color(0.2, 0.22, 0.28, 0.4)
		
	btn.add_theme_stylebox_override("normal", box)

func _get_texture(path: String) -> Texture2D:
	if _icon_cache.has(path):
		return _icon_cache[path]
	if ResourceLoader.exists(path):
		var tex: Texture2D = load(path) as Texture2D
		_icon_cache[path] = tex
		return tex
	return null

func _setup_window_dragging() -> void:
	var window_box: Control = get_node_or_null("ColorRect") as Control
	if not window_box:
		window_box = find_child("ColorRect", true, false) as Control
	var title_bar: Control = null
	if window_box:
		title_bar = window_box.get_node_or_null("AppTitle") as Control
		if not title_bar:
			title_bar = window_box.find_child("AppTitle", true, false) as Control

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
					move_to_front()
					window_box.move_to_front()
				else:
					drag_state["is_dragging"] = false
		elif event is InputEventMouseMotion and drag_state["is_dragging"]:
			if _is_maximized:
				_toggle_maximize()
			var delta: Vector2 = event.global_position - drag_state["drag_start_pos"]
			var target_pos: Vector2 = drag_state["box_start_pos"] + delta
			
			var vp_size: Vector2 = get_viewport_rect().size
			if vp_size == Vector2.ZERO:
				vp_size = Vector2(480, 270)
			var box_size: Vector2 = window_box.size
			if box_size == Vector2.ZERO:
				box_size = Vector2(380, 190)
			
			var min_x: float = -box_size.x + 40.0
			var max_x: float = vp_size.x - 40.0
			var min_y: float = 0.0
			var max_y: float = vp_size.y - 20.0
			
			target_pos.x = clampf(target_pos.x, min_x, max_x)
			target_pos.y = clampf(target_pos.y, min_y, max_y)
			
			window_box.global_position = target_pos
	)
