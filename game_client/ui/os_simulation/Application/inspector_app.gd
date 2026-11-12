class_name InspectorApp extends Control

## Controller for Inspector Application (TaoDam Forensic OS Simulation)
## Displays evidence file tree and inspected file content for investigation puzzles.

signal closed()
signal puzzle_shortcut_requested(task_key: String)

const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

@onready var file_tree: Tree = find_child("Tree", true, false) as Tree
@onready var file_content: TextEdit = find_child("TextEdit", true, false) as TextEdit
@onready var minimize_button: Button = find_child("Minimize", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button
var maximize_button: Button = null

var _is_maximized: bool = false
var _pre_maximize_pos: Vector2 = Vector2(40, 30)
var _pre_maximize_size: Vector2 = Vector2(400, 200)
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
	_apply_modern_styling()
	_setup_controls()
	_style_window()
	_setup_window_dragging()
	_populate_tree()
	call_deferred("_post_init_scrollbars")

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
		win_sb.bg_color = Color(0.12, 0.10, 0.16, 0.98)
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
		win_sb.border_color = Color(0.4, 0.25, 0.55, 0.65)
		bg_panel.add_theme_stylebox_override("panel", win_sb)
		
		var title_bar: Panel = window_box.get_node_or_null("AppTitle") as Panel
		if not title_bar:
			title_bar = window_box.find_child("AppTitle", true, false) as Panel
		if title_bar:
			var title_sb := StyleBoxFlat.new()
			title_sb.bg_color = Color(0.18, 0.12, 0.24, 1.0)
			title_sb.corner_radius_top_left = 7
			title_sb.corner_radius_top_right = 7
			title_sb.corner_radius_bottom_left = 0
			title_sb.corner_radius_bottom_right = 0
			title_sb.border_width_bottom = 1
			title_sb.border_color = Color(0.3, 0.2, 0.4, 0.8)
			title_bar.add_theme_stylebox_override("panel", title_sb)

		var title_lbl := window_box.find_child("Label", true, false) as Label
		if title_lbl:
			title_lbl.add_theme_font_size_override("font_size", 9)

	var tree_panel := find_child("FileTree", true, false) as Control
	if tree_panel:
		var tree_sb := StyleBoxFlat.new()
		tree_sb.bg_color = Color(0.14, 0.11, 0.19, 0.9)
		tree_sb.corner_radius_top_left = 7
		tree_sb.corner_radius_top_right = 7
		tree_sb.corner_radius_bottom_left = 7
		tree_sb.corner_radius_bottom_right = 7
		tree_sb.shadow_size = 6
		tree_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		tree_sb.shadow_offset = Vector2(0, 3)
		tree_sb.border_width_left = 1
		tree_sb.border_width_top = 1
		tree_sb.border_width_right = 1
		tree_sb.border_width_bottom = 1
		tree_sb.border_color = Color(0.32, 0.22, 0.45, 0.6)
		tree_panel.add_theme_stylebox_override("panel", tree_sb)

	var content_panel := find_child("FileContent", true, false) as Control
	if content_panel:
		var content_sb := StyleBoxFlat.new()
		content_sb.bg_color = Color(0.10, 0.08, 0.14, 0.95)
		content_sb.corner_radius_top_left = 7
		content_sb.corner_radius_top_right = 7
		content_sb.corner_radius_bottom_left = 7
		content_sb.corner_radius_bottom_right = 7
		content_sb.shadow_size = 6
		content_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		content_sb.shadow_offset = Vector2(0, 3)
		content_sb.border_width_left = 1
		content_sb.border_width_top = 1
		content_sb.border_width_right = 1
		content_sb.border_width_bottom = 1
		content_sb.border_color = Color(0.32, 0.22, 0.45, 0.6)
		content_panel.add_theme_stylebox_override("panel", content_sb)

	if file_tree:
		file_tree.add_theme_font_size_override("font_size", 7)
	if file_content:
		file_content.add_theme_font_size_override("font_size", 7)

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
	
	_setup_window_buttons()
	_setup_custom_scrollbars()

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

	_update_shortcuts_for_key(key)

var _shortcut_bar: HBoxContainer = null

func _ensure_shortcut_bar() -> HBoxContainer:
	if _shortcut_bar and is_instance_valid(_shortcut_bar):
		return _shortcut_bar
	_shortcut_bar = HBoxContainer.new()
	_shortcut_bar.name = "InspectorShortcutBar"
	_shortcut_bar.custom_minimum_size = Vector2(0, 20)
	_shortcut_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_shortcut_bar.offset_top = -22.0
	_shortcut_bar.offset_left = 6.0
	_shortcut_bar.offset_right = -14.0
	_shortcut_bar.offset_bottom = -2.0
	_shortcut_bar.add_theme_constant_override("separation", 6)
	_shortcut_bar.z_index = 5
	var parent_panel: Node = file_content.get_parent() if file_content else self
	if parent_panel:
		parent_panel.add_child(_shortcut_bar)
	return _shortcut_bar

func _update_shortcuts_for_key(key: String) -> void:
	var bar := _ensure_shortcut_bar()
	for child in bar.get_children():
		child.queue_free()

	match key:
		"manifest":
			_add_shortcut_btn(bar, "💻 เปิด CMD เช็ค Hash & ยืนยันความสมบูรณ์ (T08)", "T08")
		"event_log":
			_add_shortcut_btn(bar, "🕒 ระบุเวลาที่โปรเซสเริ่มทำงานจาก Log นี้ (T06)", "T06")
		"drive_log":
			_add_shortcut_btn(bar, "📧 ระบุอีเมลผู้ส่งที่ปลอมแปลงโดเมนจาก Log นี้ (T07)", "T07")
		"report_docx", "vba_macro":
			_add_shortcut_btn(bar, "🔍 ระบุส่วนประกอบไฟล์ที่ฝัง Macro (T09)", "T09")
			_add_shortcut_btn(bar, "🔐 เปิด Decoder ถอดรหัสเพย์โหลด (T10-T11)", "T10")
		"scheduled_task", "helper_dat":
			_add_shortcut_btn(bar, "🛡️ วางแผนลำดับหยุด Persistence 7 ขั้นตอน (T12)", "T12")
			if key == "helper_dat":
				_add_shortcut_btn(bar, "🔐 เปิด Decoder ถอดรหัส Helper (T10-T11)", "T10")

func _add_shortcut_btn(bar: HBoxContainer, text: String, task_key: String) -> void:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 16)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
	if thai_font:
		btn.add_theme_font_override("font", thai_font)
	btn.add_theme_font_size_override("font_size", 6)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.25, 0.4, 0.95)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.3, 0.75, 1.0, 0.9)
	sb.corner_radius_top_left = 7
	sb.corner_radius_top_right = 7
	sb.corner_radius_bottom_right = 7
	sb.corner_radius_bottom_left = 7
	sb.shadow_size = 6
	sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
	sb.shadow_offset = Vector2(0, 3)
	sb.content_margin_left = 6.0
	sb.content_margin_right = 6.0
	btn.add_theme_stylebox_override("normal", sb)
	var sb_hover := sb.duplicate() as StyleBoxFlat
	sb_hover.bg_color = Color(0.18, 0.4, 0.65, 1.0)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.pressed.connect(func() -> void:
		puzzle_shortcut_requested.emit(task_key)
	)
	bar.add_child(btn)

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
