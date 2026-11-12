class_name TerminalApp
extends Control

signal closed()
signal hash_verified_via_cmd(file_name: String, md5_hash: String)

const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")
const FONT_THAI: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")

const FILE_HASHES: Dictionary = {
	"report_final.docx": "7d4a2b6e1f0c3a8e9d5b7a1c4e2f6a8b",
	"windows_event_log.txt": "3c9e1a7b4f2d8e0a6c5b9d3f1e4a7b2c",
	"drive_activity.log": "8a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d",
	"office_update_helper.dat": "a1b2c3d4e5f60718293a4b5c6d7e8f90",
	"evidence_manifest.txt": "4e7d1c2b5a8f0e3d9c6b1a7f2e4d8a0c"
}

const FILE_DISPLAY_NAMES: Dictionary = {
	"report_final.docx": "Report_Final.docx",
	"windows_event_log.txt": "Windows_Event_Log.txt",
	"drive_activity.log": "Drive_Activity.log",
	"office_update_helper.dat": "Office_Update_Helper.dat",
	"evidence_manifest.txt": "Evidence_Manifest.txt"
}

const MANIFEST_CONTENT: String = """=== EVIDENCE INTEGRITY MANIFEST (MD5) ===
Algorithm: MD5
Target Drive: E:\\ (Forensic Image: EV-DRIVE)
Verified Date: 2026-03-24

File Name                  MD5 Checksum
----------------------------------------------------------------------
Report_Final.docx          7d4a2b6e1f0c3a8e9d5b7a1c4e2f6a8b
Windows_Event_Log.txt      3c9e1a7b4f2d8e0a6c5b9d3f1e4a7b2c
Drive_Activity.log         8a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d
Office_Update_Helper.dat   a1b2c3d4e5f60718293a4b5c6d7e8f90
----------------------------------------------------------------------
[NOTICE]: Use 'certutil -hashfile <filename> MD5' to verify each file.
"""

@onready var window_panel: Panel = find_child("WindowPanel", true, false) as Panel
@onready var title_bar: Panel = find_child("TitleBar", true, false) as Panel
@onready var output_label: RichTextLabel = find_child("OutputLabel", true, false) as RichTextLabel
@onready var command_input: LineEdit = find_child("CommandInput", true, false) as LineEdit
@onready var prompt_label: Label = find_child("PromptLabel", true, false) as Label
@onready var minimize_button: Button = find_child("MinimizeButton", true, false) as Button
@onready var maximize_button: Button = find_child("MaximizeButton", true, false) as Button
@onready var exit_button: Button = find_child("ExitButton", true, false) as Button
@onready var quick_commands_hbox: HBoxContainer = find_child("QuickCommandsHBox", true, false) as HBoxContainer

var last_calculated_md5: String = ""
var last_calculated_file: String = ""

# Window dragging and maximizing state
var _is_dragging: bool = false
var _drag_start_mouse: Vector2 = Vector2.ZERO
var _drag_start_pos: Vector2 = Vector2.ZERO
var _is_maximized: bool = false

func _ready() -> void:
	add_to_group("terminal_apps")
	add_to_group("terminal")
	_setup_ui()
	_setup_quick_commands()
	_print_welcome()

func _setup_ui() -> void:
	if window_panel:
		var win_sb := StyleBoxFlat.new()
		win_sb.bg_color = Color(0.05, 0.05, 0.06, 0.98)
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
		win_sb.border_color = Color(0.24, 0.26, 0.32, 0.8)
		window_panel.add_theme_stylebox_override("panel", win_sb)
		window_panel.gui_input.connect(_on_window_gui_input)

	if title_bar:
		var title_sb := StyleBoxFlat.new()
		title_sb.bg_color = Color(0.12, 0.13, 0.16, 1.0)
		title_sb.corner_radius_top_left = 7
		title_sb.corner_radius_top_right = 7
		title_sb.corner_radius_bottom_left = 0
		title_sb.corner_radius_bottom_right = 0
		title_sb.border_width_bottom = 1
		title_sb.border_color = Color(0.18, 0.2, 0.25, 0.8)
		title_bar.add_theme_stylebox_override("panel", title_sb)

		var title_lbl := title_bar.find_child("TitleLabel", true, false) as Label
		if not title_lbl:
			title_lbl = title_bar.find_child("Label", true, false) as Label
		if title_lbl:
			title_lbl.add_theme_font_size_override("font_size", 9)

		var global_settings = get_node_or_null("/root/GlobalSettings")
		if global_settings and global_settings.has_method("make_window_draggable") and window_panel:
			global_settings.make_window_draggable(window_panel, title_bar)
		title_bar.gui_input.connect(_on_title_bar_gui_input)

	var status_bar := find_child("StatusBar", true, false) as Panel
	if status_bar:
		var stat_sb := StyleBoxFlat.new()
		stat_sb.bg_color = Color(0.08, 0.09, 0.11, 1.0)
		stat_sb.corner_radius_top_left = 0
		stat_sb.corner_radius_top_right = 0
		stat_sb.corner_radius_bottom_left = 7
		stat_sb.corner_radius_bottom_right = 7
		stat_sb.border_width_top = 1
		stat_sb.border_color = Color(0.18, 0.2, 0.25, 0.8)
		status_bar.add_theme_stylebox_override("panel", stat_sb)

	if output_label:
		output_label.add_theme_font_size_override("normal_font_size", 7)

	if command_input:
		command_input.add_theme_font_size_override("font_size", 7)
		command_input.text_submitted.connect(func(_t: String) -> void: _on_run_pressed())

	if prompt_label:
		prompt_label.add_theme_font_size_override("font_size", 7)

	if minimize_button:
		minimize_button.pressed.connect(_on_close_pressed)

	if maximize_button:
		maximize_button.pressed.connect(_toggle_maximize)

	if exit_button:
		exit_button.pressed.connect(_on_close_pressed)

func _setup_quick_commands() -> void:
	if not quick_commands_hbox:
		return
	for child in quick_commands_hbox.get_children():
		child.queue_free()

	var quick_cmds: Array[String] = [
		"dir",
		"type Evidence_Manifest.txt",
		"certutil -hashfile Report_Final.docx MD5",
		"certutil -hashfile Windows_Event_Log.txt MD5",
		"certutil -hashfile Drive_Activity.log MD5",
		"cls"
	]

	for cmd in quick_cmds:
		var btn := Button.new()
		btn.text = cmd
		btn.custom_minimum_size = Vector2(0, 13)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_font_override("font", FONT_MONO)
		btn.add_theme_font_size_override("font_size", 5)

		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.13, 0.16, 0.95)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(0.24, 0.28, 0.35, 0.8)
		sb.corner_radius_top_left = 7
		sb.corner_radius_top_right = 7
		sb.corner_radius_bottom_right = 7
		sb.corner_radius_bottom_left = 7
		sb.shadow_size = 6
		sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		sb.shadow_offset = Vector2(0, 3)
		sb.content_margin_left = 4.0
		sb.content_margin_right = 4.0
		btn.add_theme_stylebox_override("normal", sb)

		var sb_hover := sb.duplicate() as StyleBoxFlat
		sb_hover.bg_color = Color(0.2, 0.24, 0.3, 1.0)
		sb_hover.border_color = Color(0.4, 0.5, 0.65, 1.0)
		btn.add_theme_stylebox_override("hover", sb_hover)
		btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))

		btn.pressed.connect(func() -> void:
			if command_input:
				command_input.text = cmd
			_execute_command(cmd)
			if command_input:
				command_input.grab_focus()
		)
		quick_commands_hbox.add_child(btn)

func _print_welcome() -> void:
	if not output_label:
		return
	output_label.clear()
	output_label.append_text("[color=#cccccc]Microsoft Windows [Version 10.0.19045.3803][/color]\n")
	output_label.append_text("[color=#cccccc](c) Microsoft Corporation. All rights reserved.[/color]\n\n")

func open_terminal() -> void:
	show()
	move_to_front()
	if command_input:
		command_input.grab_focus()

func _on_close_pressed() -> void:
	hide()
	closed.emit()

func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				move_to_front()
				if event.double_click:
					_toggle_maximize()
				else:
					_is_dragging = true
					_drag_start_mouse = get_viewport().get_mouse_position()
					_drag_start_pos = window_panel.position
			else:
				_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging:
		if _is_maximized:
			_toggle_maximize()
		var current_mouse: Vector2 = get_viewport().get_mouse_position()
		window_panel.position = _drag_start_pos + (current_mouse - _drag_start_mouse)

func _on_window_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		move_to_front()
		if command_input:
			command_input.grab_focus()

func _toggle_maximize() -> void:
	if not window_panel:
		return
	_is_maximized = !_is_maximized
	if _is_maximized:
		window_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		window_panel.offset_left = 2.0
		window_panel.offset_top = 2.0
		window_panel.offset_right = -2.0
		window_panel.offset_bottom = -2.0
		if maximize_button:
			maximize_button.text = "❐"
	else:
		window_panel.set_anchors_preset(Control.PRESET_CENTER)
		window_panel.custom_minimum_size = Vector2(440, 194)
		window_panel.offset_left = -220.0
		window_panel.offset_top = -97.0
		window_panel.offset_right = 220.0
		window_panel.offset_bottom = 97.0
		if maximize_button:
			maximize_button.text = "□"

func _on_run_pressed() -> void:
	if not command_input:
		return
	var cmd: String = command_input.text.strip_edges()
	command_input.clear()
	if cmd.is_empty():
		output_label.append_text("[color=#cccccc]E:\\>[/color]\n")
		return
	_execute_command(cmd)

func _execute_command(raw_cmd: String) -> void:
	var cmd: String = raw_cmd.strip_edges()
	output_label.append_text("[color=#cccccc]E:\\>[/color] " + cmd + "\n")
	var lower_cmd: String = cmd.to_lower()

	# 1. Malicious execution or destructive command attempt (Trial-and-Error Security Alert)
	var destructive_keywords: Array[String] = ["del", "rm ", "format", "erase", "rd ", "rmdir"]
	var is_destructive: bool = false
	for kw in destructive_keywords:
		if lower_cmd.begins_with(kw) or lower_cmd == kw:
			is_destructive = true
			break

	var execution_targets: Array[String] = [
		"report_final.docx", "office_update_helper.dat", "vba_extracted_macro.vba",
		".\\report_final.docx", ".\\office_update_helper.dat", "helper.dat",
		"office_update_helper", "helper"
	]
	var is_exec_attempt: bool = false
	for target in execution_targets:
		if lower_cmd == target or lower_cmd == "start " + target or lower_cmd == ".\\" + target or lower_cmd == "run " + target:
			is_exec_attempt = true
			break

	if is_destructive or is_exec_attempt:
		output_label.append_text(
			"[color=#ff3333]💥 [SECURITY ALERT - WRITE BLOCKER]: ห้ามสั่งรันหรือลบไฟล์หลักฐานในไดรฟ์ E:\\ โดยตรง!\n"
			+ "หากไม่มีระบบกั้นการเขียน มัลแวร์จะทำงานและทำลายหลักฐานทันที!\n"
			+ "กรุณาใช้เฉพาะคำสั่งอ่านค่า (certutil / type) เท่านั้นเพื่อรักษาความสมบูรณ์ของหลักฐาน![/color]\n\n"
		)
		return

	# 2. help
	if lower_cmd == "help" or lower_cmd == "?":
		output_label.append_text(
			"[color=#ffffcc]Windows Command Prompt (Forensic Shell - Drive E:\\):[/color]\n"
			+ "  [color=#cccccc]dir / ls[/color]                 - แสดงรายการไฟล์หลักฐานในไดรฟ์ E:\\\n"
			+ "  [color=#cccccc]type <file>[/color]              - เปิดดูข้อความในไฟล์ (เช่น type Evidence_Manifest.txt)\n"
			+ "  [color=#cccccc]certutil -hashfile <file> MD5[/color] - คำนวณค่า MD5 Hash ของไฟล์เพื่อตรวจความสมบูรณ์\n"
			+ "  [color=#cccccc]cls[/color]                      - ล้างหน้าจอ Terminal\n"
			+ "  [color=#cccccc]exit[/color]                     - ปิดหน้าต่าง Command Prompt\n\n"
		)
		return

	# 3. cls / clear
	if lower_cmd == "cls" or lower_cmd == "clear":
		_print_welcome()
		return

	# 4. exit
	if lower_cmd == "exit" or lower_cmd == "quit":
		_on_close_pressed()
		return

	# 5. dir / ls
	if lower_cmd == "dir" or lower_cmd == "ls":
		output_label.append_text(
			" Volume in drive E is EV-DRIVE\n"
			+ " Volume Serial Number is 4A1C-9E2B\n\n"
			+ " Directory of E:\\\n\n"
			+ "24/03/2026  19:00    <DIR>          .\n"
			+ "24/03/2026  19:00    <DIR>          ..\n"
			+ "24/03/2026  19:01            48,230 Report_Final.docx\n"
			+ "24/03/2026  19:05            15,155 Windows_Event_Log.txt\n"
			+ "24/03/2026  19:08             5,324 Drive_Activity.log\n"
			+ "24/03/2026  19:02            12,288 Office_Update_Helper.dat\n"
			+ "24/03/2026  19:15             1,228 Evidence_Manifest.txt\n"
			+ "               5 File(s)         82,225 bytes\n"
			+ "               2 Dir(s)   7,842,119,680 bytes free\n\n"
		)
		return

	# 6. type / cat
	if lower_cmd.begins_with("type ") or lower_cmd.begins_with("cat "):
		var target_file: String = cmd.substr(cmd.find(" ") + 1).strip_edges().to_lower()
		if target_file.ends_with(".txt") or target_file == "evidence_manifest" or target_file == "manifest":
			if "manifest" in target_file:
				output_label.append_text("[color=#cccccc]" + MANIFEST_CONTENT + "[/color]\n\n")
				return
			elif "event" in target_file:
				output_label.append_text(
					"=== Windows_Event_Log.txt Preview ===\n"
					+ "19:02:14 EventID: 4104 Script Block: TriggerStaging -> Office_Update_Helper\n"
					+ "19:02:18 EventID: 106 Task Scheduler: \\Microsoft\\Windows\\Office_Update_Helper registered\n\n"
				)
				return
			elif "drive" in target_file:
				output_label.append_text(
					"=== Drive_Activity.log Preview ===\n"
					+ "18:45:00 Share access from mesasohot.sukj@universcity.example (Typosquatting spoofed sender)\n\n"
				)
				return
		output_label.append_text("[color=#ff9900]The system cannot find the file specified: " + target_file + "[/color]\n\n")
		return

	# 7. certutil -hashfile <file> MD5 / md5sum <file>
	if lower_cmd.begins_with("certutil") or lower_cmd.begins_with("md5sum"):
		var filename_part: String = ""
		if lower_cmd.begins_with("certutil"):
			# certutil -hashfile Report_Final.docx MD5
			var parts := cmd.split(" ", false)
			for p in parts:
				var p_low := p.to_lower()
				if p_low != "certutil" and not p_low.begins_with("-") and p_low != "md5" and p_low != "sha256" and p_low != "sha1":
					filename_part = p_low
					break
		else:
			# md5sum Report_Final.docx
			filename_part = cmd.substr(cmd.find(" ") + 1).strip_edges().to_lower()

		var matched_key: String = ""
		for k in FILE_HASHES.keys():
			if k == filename_part or k.get_slice(".", 0) == filename_part.get_slice(".", 0):
				matched_key = k
				break

		if not matched_key.is_empty():
			var hash_val: String = str(FILE_HASHES[matched_key])
			var display_name: String = str(FILE_DISPLAY_NAMES.get(matched_key, matched_key))
			last_calculated_md5 = hash_val
			last_calculated_file = display_name
			DisplayServer.clipboard_set(hash_val)

			output_label.append_text("MD5 hash of E:\\" + display_name + ":\n")
			output_label.append_text("[color=#ffff00][b]" + hash_val + "[/b][/color]\n")
			output_label.append_text("CertUtil: -hashfile command completed successfully. (คัดลอกค่า MD5 ลงคลิปบอร์ดแล้ว)\n\n")

			hash_verified_via_cmd.emit(display_name, hash_val)
			return
		else:
			output_label.append_text("[color=#ff4d4d]CertUtil: -hashfile command FAILED: 0x80070002 (WIN32: 2 ERROR_FILE_NOT_FOUND)[/color]\n\n")
			return

	# Default: unknown command
	output_label.append_text("[color=#ff9900]'" + cmd.get_slice(" ", 0) + "' is not recognized as an internal or external command, operable program or batch file.\nType 'help' for available commands.[/color]\n\n")
