class_name InspectorApp extends Control

## Controller for Inspector Application (TaoDam Forensic OS Simulation)
## Displays evidence file tree and inspected file content for investigation puzzles.

signal closed()

@onready var file_tree: Tree = find_child("Tree", true, false) as Tree
@onready var file_content: TextEdit = find_child("TextEdit", true, false) as TextEdit
@onready var minimize_button: Button = find_child("Minimize", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button
@onready var tree_scroll_bar: VScrollBar = get_node_or_null("ColorRect/HBoxContainer/FileTree/VScrollBar")
@onready var content_scroll_bar: VScrollBar = get_node_or_null("ColorRect/HBoxContainer/FileContent/VScrollBar")

var _internal_tree_scroll: VScrollBar = null
var _internal_content_scroll: VScrollBar = null

const EVIDENCE_DATA: Dictionary = {
	"manifest": {
		"title": "Evidence_Manifest.txt",
		"text": """============================================================
CASE INCIDENT EVIDENCE MANIFEST - TAODAM LAB
============================================================
Case ID      : CASE-2026-MAY-01
Acquisition  : 2026-10-28 21:45 UTC
Investigator : March (Incident Response Team)
Device Label : EV-DRIVE (E:) | Read-Only Forensic Image

[FILE INTEGRITY CHECKSUMS (MD5 / SHA-256)]
------------------------------------------------------------
1. Report_Final.docx
   MD5    : 7d4a2b6e1f0c3a8e9d5b7a1c4e2f6a8b
   Status : VERIFIED (Matches incident workstation copy)

2. Windows_Event_Log.txt
   MD5    : 3c9e1a7b4f2d8e0a6c5b9d3f1e4a7b2c
   Status : VERIFIED (Exported from System Event Viewer)

3. Drive_Activity.log
   MD5    : 8a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d
   Status : VERIFIED (Synchronized cloud activity record)

4. Office_Update_Helper.dat
   MD5    : 1f2e3d4c5b6a7089a0b1c2d3e4f5a6b7
   Status : EXTRACTED ARTIFACT (Quarantined)

Chain of Custody: Intact. Evidence secured with write-blocker.
"""
	},
	"readme": {
		"title": "README_INCIDENT.txt",
		"text": """============================================================
CASE BRIEFING NOTES - FROM MARCH
============================================================
Subject : May's Workstation Incident Triage
Priority: High

Summary:
At approximately 19:02 on May's PC, an external document named
'Report_Final.docx' was opened. Shortly afterward, unusual background
activity occurred and unauthorized file modifications were detected.

Key Objectives for Forensic Analysis on TaoDam:
1. Verify the integrity of the collected EV-DRIVE image using FTK Imager.
2. Inspect the structure of Report_Final.docx for embedded active content.
3. Decode the suspicious helper file and determine its operational mode.
4. Identify persistence mechanisms (e.g. Scheduled Tasks) and stop them.
"""
	},
	"report_docx": {
		"title": "Report_Final.docx",
		"text": """============================================================
DOCUMENT PROPERTIES & METADATA
============================================================
Filename       : Report_Final.docx
File Size      : 48,210 bytes
Format         : Microsoft Word Document (Office Open XML)
Author         : mesasohot.sukj@universcity.example
Original Title : Annual Security Research Report

[PACKAGE STRUCTURE]
- [Content_Types].xml
- _rels/.rels
- word/
  |-- document.xml
  |-- fontTable.xml
  |-- settings.xml
  |-- styles.xml
  |-- vbaProject.bin    <-- [ALERT: EMBEDDED VBA PROJECT FOUND]

Analysis Note:
The file contains an embedded macro binary stream 'word/vbaProject.bin'.
When opened in Word, it prompts the user to 'Enable Content'.
"""
	},
	"vba_macro": {
		"title": "vba_extracted_macro.vba",
		"text": """' ============================================================
' EXTRACTED MACRO STREAM: word/vbaProject.bin
' Analysis Tool: olevba forensic inspection
' ============================================================

Private Sub Document_Open()
    Call TriggerStaging
End Sub

Sub AutoOpen()
    Call TriggerStaging
End Sub

Private Sub TriggerStaging()
    Dim cmd As String
    Dim helperPath As String
    
    ' Encoded target name: T2ZmaWNlX1VwZGF0ZV9IZWxwZXI=
    helperPath = Environ("APPDATA") & "\\Microsoft\\Office_Update_Helper.dat"
    
    ' Scheduled task execution at user logon
    cmd = "schtasks /create /tn \\"Office_Update_Helper\\" /tr " & helperPath & " /sc onidle /i 5 /f"
    Shell cmd, vbHide
End Sub
"""
	},
	"event_log": {
		"title": "Windows_Event_Log.txt",
		"text": """============================================================
SYSTEM & APPLICATION EVENT LOGS (TIMELINE EXTRACT)
============================================================
TimeCreated          EventID  Source        Description
-------------------  -------  ------------  --------------------------------------------------
18:58:07             11       FileCreated   Report_Final.docx created in Downloads folder
19:02:10             1        WINWORD.EXE   Process start: WINWORD.EXE "Report_Final.docx"
19:03:16             4104     PowerShell    Active content allowed by user (Enable Content)
19:03:22             106      TaskScheduler Task Registered: "Office_Update_Helper"
21:21:50             1        ProcessStart  Office_Update_Helper process launched by trigger
21:21:55             11       FileModify    Multiple project directory files modified
"""
	},
	"drive_log": {
		"title": "Drive_Activity.log",
		"text": """============================================================
CLOUD DRIVE ACTIVITY & AUDIT LOG
============================================================
Timestamp   File Name             Sender / Shared By                    Domain Status
----------  --------------------  ------------------------------------  -------------------
18:54:12    Network_Diagram.png   mesa.sukj@university.example          Legitimate / Verified
18:56:45    Research_Data.xlsx    mesa.sukj@university.example          Legitimate / Verified
18:58:02    Report_Final.docx     mesasohot.sukj@universcity.example    SPOOFED (Typo: 'universcity')

Forensic Finding:
The legitimate domain is 'university.example'.
The sender email 'mesasohot.sukj@universcity.example' is a typosquatted domain used for delivery.
"""
	},
	"helper_dat": {
		"title": "Office_Update_Helper.dat",
		"text": """============================================================
ARTIFACT ANALYSIS: Office_Update_Helper.dat
============================================================
Location : %APPDATA%\\Microsoft\\Office_Update_Helper.dat
File Type: Encoded configuration / dropper payload

[ENCODED STRINGS & DECODER FINDINGS]
Encoded Helper Name (Base64) : T2ZmaWNlX1VwZGF0ZV9IZWxwZXI=
Decoded Value                : Office_Update_Helper

Operational Mode (Hex)       : 526B6c4D5256395853564246
Intermediate Base64          : RklMRV9XSVBF
Decoded Operational Mode     : FILE_WIPE

Target Target Scope          : User Project & Document directories
Trigger                      : Scheduled Task on logon / system idle
"""
	},
	"scheduled_task": {
		"title": "scheduled_task.xml",
		"text": """<?xml version="1.0" encoding="UTF-16"?>
<!-- Task Scheduler Configuration Extract -->
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Simulated Office Maintenance Update Task</Description>
    <Author>SYSTEM</Author>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
    <IdleTrigger>
      <Enabled>true</Enabled>
    </IdleTrigger>
  </Triggers>
  <Actions Context="Author">
    <Exec>
      <Command>%APPDATA%\\Microsoft\\Office_Update_Helper.dat</Command>
    </Exec>
  </Actions>
</Task>
"""
	},
	"ransom_note": {
		"title": "Ransom_Note.txt",
		"text": """============================================================
INCIDENT RANSOM NOTE RECOVERED FROM DESKTOP
============================================================
All your important project files and research data have been locked!

Do not attempt to restore or modify files directly.
Contact recovery instructions via secure gateway.

Incident Timestamp : 2026-10-28 21:22:00
Incident Code      : TAODAM-SECURITY-BREACH-01
"""
	}
}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_controls()
	_populate_tree()
	call_deferred("_post_init_scrollbars")

func _process(_delta: float) -> void:
	_sync_ranges_if_needed(_internal_tree_scroll, tree_scroll_bar)
	_sync_ranges_if_needed(_internal_content_scroll, content_scroll_bar)

func _sync_ranges_if_needed(internal: VScrollBar, custom: VScrollBar) -> void:
	if not is_instance_valid(internal) or not is_instance_valid(custom):
		return
	if not is_equal_approx(custom.max_value, internal.max_value) or not is_equal_approx(custom.page, internal.page):
		custom.min_value = internal.min_value
		custom.max_value = internal.max_value
		custom.page = internal.page
		custom.step = internal.step
	if not is_equal_approx(custom.value, internal.value):
		custom.value = internal.value

func _setup_controls() -> void:
	if file_content:
		file_content.editable = false
		file_content.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	
	if file_tree:
		_apply_custom_tree_styling()
		file_tree.item_selected.connect(_on_tree_item_selected)
		if not file_tree.item_collapsed.is_connected(_on_tree_item_collapsed):
			file_tree.item_collapsed.connect(_on_tree_item_collapsed)
	
	if minimize_button and not minimize_button.pressed.is_connected(_on_close_pressed):
		minimize_button.pressed.connect(_on_close_pressed)
	if exit_button and not exit_button.pressed.is_connected(_on_close_pressed):
		exit_button.pressed.connect(_on_close_pressed)
		
	_setup_custom_scrollbars()

func _apply_custom_tree_styling() -> void:
	# Enforce small collapse/expand arrow icons for 270p viewport
	# Downscale scene textures if assigned, or fallback to clean 5x5 pixel-art arrows
	var arrow_down: Texture2D = _get_small_arrow_texture(true)
	var arrow_right: Texture2D = _get_small_arrow_texture(false)
	
	file_tree.add_theme_icon_override("arrow", arrow_down)
	file_tree.add_theme_icon_override("arrow_collapsed", arrow_right)
	file_tree.add_theme_icon_override("arrow_collapsed_mirrored", arrow_right)
	file_tree.add_theme_font_size_override("font_size", 8)
	file_tree.add_theme_constant_override("item_margin", 2)
	file_tree.add_theme_constant_override("v_separation", 1)

func _get_small_arrow_texture(pointing_down: bool) -> Texture2D:
	var override_key: String = "arrow" if pointing_down else "arrow_collapsed"
	if file_tree and file_tree.has_theme_icon_override(override_key):
		var existing_icon: Texture2D = file_tree.get_theme_icon(override_key)
		if existing_icon:
			var img: Image = existing_icon.get_image()
			if img and not img.is_empty():
				var resized: Image = img.duplicate()
				resized.resize(6, 6, Image.INTERPOLATE_LANCZOS)
				return ImageTexture.create_from_image(resized)
	return _create_arrow_texture(pointing_down)

func _setup_custom_scrollbars() -> void:
	if not tree_scroll_bar:
		var file_tree_panel := get_node_or_null("ColorRect/HBoxContainer/FileTree")
		if file_tree_panel:
			tree_scroll_bar = file_tree_panel.get_node_or_null("VScrollBar") as VScrollBar
		elif file_tree and file_tree.get_parent():
			tree_scroll_bar = file_tree.get_parent().get_node_or_null("VScrollBar") as VScrollBar
	
	if not content_scroll_bar:
		var file_content_panel := get_node_or_null("ColorRect/HBoxContainer/FileContent")
		if file_content_panel:
			content_scroll_bar = file_content_panel.get_node_or_null("VScrollBar") as VScrollBar
		elif file_content and file_content.get_parent():
			content_scroll_bar = file_content.get_parent().get_node_or_null("VScrollBar") as VScrollBar

	# Bind FileTree scrollbar
	if file_tree and tree_scroll_bar:
		_internal_tree_scroll = _get_internal_v_scrollbar(file_tree)
		if _internal_tree_scroll:
			_bind_scrollbar(_internal_tree_scroll, tree_scroll_bar)

	# Bind FileContent (TextEdit) scrollbar
	if file_content and content_scroll_bar:
		_internal_content_scroll = _get_internal_v_scrollbar(file_content)
		if _internal_content_scroll:
			_bind_scrollbar(_internal_content_scroll, content_scroll_bar)

func _post_init_scrollbars() -> void:
	_setup_custom_scrollbars()
	_sync_tree_scrollbar_ranges()
	if is_instance_valid(_internal_content_scroll) and is_instance_valid(content_scroll_bar):
		content_scroll_bar.min_value = _internal_content_scroll.min_value
		content_scroll_bar.max_value = _internal_content_scroll.max_value
		content_scroll_bar.page = _internal_content_scroll.page
		content_scroll_bar.step = _internal_content_scroll.step

func _get_internal_v_scrollbar(control: Control) -> VScrollBar:
	if not control:
		return null
	if control.has_method("get_v_scroll_bar"):
		return control.call("get_v_scroll_bar") as VScrollBar
	for child in control.get_children(true):
		if child is VScrollBar:
			return child as VScrollBar
	var scrollbars := control.find_children("*", "VScrollBar", true, false)
	if scrollbars.size() > 0:
		return scrollbars[0] as VScrollBar
	return null

func _bind_scrollbar(internal: VScrollBar, custom: VScrollBar) -> void:
	if not internal or not custom:
		return
	
	# Visually hide the internal default scrollbar and pass mouse clicks through
	internal.modulate.a = 0.0
	internal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Ensure the custom scrollbar has proper layout & grabber styling
	_ensure_scrollbar_styling(custom)
	
	# Sync range properties (min, max, page, step) whenever internal changes
	var sync_ranges := func() -> void:
		if is_instance_valid(internal) and is_instance_valid(custom):
			custom.min_value = internal.min_value
			custom.max_value = internal.max_value
			custom.page = internal.page
			custom.step = internal.step
	
	if not internal.changed.is_connected(sync_ranges):
		internal.changed.connect(sync_ranges)
	sync_ranges.call()
	
	# Sync custom scrollbar dragging -> internal scrolling
	if not custom.value_changed.is_connected(_on_custom_scroll_changed.bind(internal)):
		custom.value_changed.connect(_on_custom_scroll_changed.bind(internal))
	
	# Sync internal scrolling (mouse wheel, caret navigation) -> custom scrollbar
	if not internal.value_changed.is_connected(_on_internal_scroll_changed.bind(custom)):
		internal.value_changed.connect(_on_internal_scroll_changed.bind(custom))

func _on_custom_scroll_changed(new_val: float, internal: VScrollBar) -> void:
	if is_instance_valid(internal) and not is_equal_approx(internal.value, new_val):
		internal.value = new_val

func _on_internal_scroll_changed(new_val: float, custom: VScrollBar) -> void:
	if is_instance_valid(custom) and not is_equal_approx(custom.value, new_val):
		custom.value = new_val

func _on_tree_item_collapsed(_item: TreeItem) -> void:
	call_deferred("_sync_tree_scrollbar_ranges")

func _sync_tree_scrollbar_ranges() -> void:
	if is_instance_valid(_internal_tree_scroll) and is_instance_valid(tree_scroll_bar):
		tree_scroll_bar.min_value = _internal_tree_scroll.min_value
		tree_scroll_bar.max_value = _internal_tree_scroll.max_value
		tree_scroll_bar.page = _internal_tree_scroll.page
		tree_scroll_bar.step = _internal_tree_scroll.step

func _ensure_scrollbar_styling(scrollbar: VScrollBar) -> void:
	if not scrollbar:
		return
		
	scrollbar.z_index = 2
	scrollbar.mouse_filter = Control.MOUSE_FILTER_STOP
	scrollbar.visible = true
	
	scrollbar.anchor_left = 1.0
	scrollbar.anchor_right = 1.0
	scrollbar.offset_left = -3.0
	scrollbar.offset_right = 0.0
	scrollbar.custom_minimum_size = Vector2(3, 0)
	
	if not scrollbar.has_theme_stylebox_override("grabber"):
		var grabber_box: StyleBoxFlat = StyleBoxFlat.new()
		grabber_box.bg_color = Color(0.65, 0.70, 0.85, 0.85)
		grabber_box.corner_radius_top_left = 1
		grabber_box.corner_radius_top_right = 1
		grabber_box.corner_radius_bottom_right = 1
		grabber_box.corner_radius_bottom_left = 1
		scrollbar.add_theme_stylebox_override("grabber", grabber_box)
	
	if not scrollbar.has_theme_stylebox_override("grabber_highlight"):
		var hl_box: StyleBoxFlat = StyleBoxFlat.new()
		hl_box.bg_color = Color(0.85, 0.90, 1.0, 1.0)
		hl_box.corner_radius_top_left = 1
		hl_box.corner_radius_top_right = 1
		hl_box.corner_radius_bottom_right = 1
		hl_box.corner_radius_bottom_left = 1
		scrollbar.add_theme_stylebox_override("grabber_highlight", hl_box)

	if not scrollbar.has_theme_stylebox_override("grabber_pressed"):
		var pr_box: StyleBoxFlat = StyleBoxFlat.new()
		pr_box.bg_color = Color(1.0, 1.0, 1.0, 1.0)
		pr_box.corner_radius_top_left = 1
		pr_box.corner_radius_top_right = 1
		pr_box.corner_radius_bottom_right = 1
		pr_box.corner_radius_bottom_left = 1
		scrollbar.add_theme_stylebox_override("grabber_pressed", pr_box)

func _create_arrow_texture(pointing_down: bool) -> ImageTexture:
	var size: int = 5
	var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var col: Color = Color(0.85, 0.88, 0.95, 0.9)
	
	if pointing_down:
		# 5x5 Down-pointing arrow
		for x in range(5):
			img.set_pixel(x, 1, col)
		for x in range(1, 4):
			img.set_pixel(x, 2, col)
		img.set_pixel(2, 3, col)
	else:
		# 5x5 Right-pointing arrow
		img.set_pixel(1, 0, col)
		img.set_pixel(1, 1, col)
		img.set_pixel(2, 1, col)
		img.set_pixel(1, 2, col)
		img.set_pixel(2, 2, col)
		img.set_pixel(3, 2, col)
		img.set_pixel(1, 3, col)
		img.set_pixel(2, 3, col)
		img.set_pixel(1, 4, col)
		
	return ImageTexture.create_from_image(img)

func _populate_tree() -> void:
	if not file_tree:
		return
	
	file_tree.clear()
	
	var root: TreeItem = file_tree.create_item()
	file_tree.hide_root = false
	root.set_text(0, "EV-DRIVE (E:)")
	root.set_metadata(0, "dir_root")
	
	# Root-level files
	_create_file_item(root, "Evidence_Manifest.txt", "manifest")
	_create_file_item(root, "README_INCIDENT.txt", "readme")
	
	# Documents folder
	var doc_folder: TreeItem = file_tree.create_item(root)
	doc_folder.set_text(0, "Documents")
	doc_folder.set_metadata(0, "dir_documents")
	_create_file_item(doc_folder, "Report_Final.docx", "report_docx")
	_create_file_item(doc_folder, "vba_extracted_macro.vba", "vba_macro")
	
	# Logs folder
	var log_folder: TreeItem = file_tree.create_item(root)
	log_folder.set_text(0, "Logs")
	log_folder.set_metadata(0, "dir_logs")
	_create_file_item(log_folder, "Windows_Event_Log.txt", "event_log")
	_create_file_item(log_folder, "Drive_Activity.log", "drive_log")
	
	# Malware_Artifacts folder
	var artifact_folder: TreeItem = file_tree.create_item(root)
	artifact_folder.set_text(0, "Malware_Artifacts")
	artifact_folder.set_metadata(0, "dir_artifacts")
	_create_file_item(artifact_folder, "Office_Update_Helper.dat", "helper_dat")
	_create_file_item(artifact_folder, "scheduled_task.xml", "scheduled_task")
	
	# Incident_Notes folder
	var notes_folder: TreeItem = file_tree.create_item(root)
	notes_folder.set_text(0, "Incident_Notes")
	notes_folder.set_metadata(0, "dir_notes")
	_create_file_item(notes_folder, "Ransom_Note.txt", "ransom_note")
	
	# Select manifest by default
	_display_content("manifest")

func _create_file_item(parent: TreeItem, display_name: String, key: String) -> TreeItem:
	var item: TreeItem = file_tree.create_item(parent)
	item.set_text(0, display_name)
	item.set_metadata(0, key)
	return item

func select_file(key: String) -> void:
	_display_content(key)

func _on_tree_item_selected() -> void:
	if not file_tree:
		return
	var selected: TreeItem = file_tree.get_selected()
	if not selected:
		return
	
	var metadata = selected.get_metadata(0)
	if metadata is String:
		_display_content(metadata)

func _display_content(key: String) -> void:
	if not file_content:
		return
	
	if EVIDENCE_DATA.has(key):
		file_content.text = EVIDENCE_DATA[key]["text"]
	elif key.begins_with("dir_"):
		_display_directory_info(key)
	else:
		file_content.text = "Select a file from the tree to view its contents."

	file_content.set_caret_line(0)
	if is_instance_valid(_internal_content_scroll):
		_internal_content_scroll.value = 0.0
	elif file_content:
		var internal_scroll := _get_internal_v_scrollbar(file_content)
		if internal_scroll:
			internal_scroll.value = 0.0
	if is_instance_valid(content_scroll_bar):
		content_scroll_bar.value = 0.0

func _display_directory_info(dir_key: String) -> void:
	match dir_key:
		"dir_root":
			file_content.text = """[DIRECTORY: EV-DRIVE (E:)]
File System : FAT32 / Forensic Raw Image
Volume Name : EVIDENCE_01
Capacity    : 16.0 GB (Write-Protected)
Description : Forensic disk image collected from May's workstation."""
		"dir_documents":
			file_content.text = """[DIRECTORY: Documents]
Contains primary documents recovered from May's download directory and extracted macro code."""
		"dir_logs":
			file_content.text = """[DIRECTORY: Logs]
Contains system audit events and Google Drive synchronization activity records."""
		"dir_artifacts":
			file_content.text = """[DIRECTORY: Malware_Artifacts]
Contains quarantined payload files, decrypted configuration parameters, and scheduled task definitions."""
		"dir_notes":
			file_content.text = """[DIRECTORY: Incident_Notes]
Contains triage notes, user notices, and recovered incident extortion messages."""
		_:
			file_content.text = "[DIRECTORY]\nSelect a child item to inspect file data."

func _on_close_pressed() -> void:
	hide()
	closed.emit()
