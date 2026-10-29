class_name EvFolderApp extends Control

## Controller for EV-DRIVE (E:) File Explorer (TaoDam OS Simulation)
## Displays forensic files and folders mirroring inspector_app.gd.
## Initially hidden until the flashdrive is plugged into the TaoDam notebook.

signal closed()
signal file_opened(file_id: String)
signal file_inspect_requested(file_id: String)

@onready var title_label: Label = find_child("Label", true, false) as Label
@onready var minimize_button: Button = find_child("Minimize", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button

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
	_folder_buttons = [folder1_btn, folder2_btn, folder3_btn, folder4_btn]
	_file_buttons = [file1_btn, file2_btn, file3_btn, file4_btn, file5_btn]
	
	_setup_window_buttons()
	_setup_folder_buttons()
	_setup_file_buttons()
	
	# Open default folder
	open_folder("documents")

func _setup_window_buttons() -> void:
	if minimize_button and not minimize_button.pressed.is_connected(_on_close_pressed):
		minimize_button.pressed.connect(_on_close_pressed)
		minimize_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if exit_button and not exit_button.pressed.is_connected(_on_close_pressed):
		exit_button.pressed.connect(_on_close_pressed)
		exit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
	if inspect_btn and not inspect_btn.pressed.is_connected(_on_inspect_pressed):
		inspect_btn.pressed.connect(_on_inspect_pressed)
		inspect_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _setup_folder_buttons() -> void:
	var keys: Array[String] = ["documents", "logs", "artifacts", "notes"]
	var titles: Array[String] = ["Documents", "Logs", "Malware_Artifacts", "Incident_Notes"]
	
	for i in range(_folder_buttons.size()):
		var btn: Button = _folder_buttons[i]
		if not btn:
			continue
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if i < titles.size():
			btn.text = " " + titles[i]
		
		# Set folder icon
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
	box.corner_radius_top_left = 2
	box.corner_radius_top_right = 2
	box.corner_radius_bottom_right = 2
	box.corner_radius_bottom_left = 2
	box.content_margin_left = 4.0
	box.content_margin_right = 4.0
	box.content_margin_top = 2.0
	box.content_margin_bottom = 2.0
	
	if is_active:
		if is_file:
			box.bg_color = Color(0.25, 0.35, 0.55, 0.95)
			box.border_color = Color(0.55, 0.75, 1.0, 1.0)
			box.set_border_width_all(1)
		else:
			box.bg_color = Color(0.35, 0.28, 0.48, 1.0)
			box.border_color = Color(0.7, 0.6, 0.9, 1.0)
			box.set_border_width_all(1)
	else:
		box.bg_color = Color(0.12, 0.12, 0.16, 0.6)
		box.set_border_width_all(0)
		
	btn.add_theme_stylebox_override("normal", box)

func _get_texture(path: String) -> Texture2D:
	if _icon_cache.has(path):
		return _icon_cache[path]
	if ResourceLoader.exists(path):
		var tex: Texture2D = load(path) as Texture2D
		_icon_cache[path] = tex
		return tex
	return null
