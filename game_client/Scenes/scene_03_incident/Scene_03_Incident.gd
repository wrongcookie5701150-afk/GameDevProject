extends DesktopScreenController

const SCENE_04_PATH: String = "res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn"

# Cutscene Controls & Overlays
@onready var ransom_note: PanelContainer = %RansomNote
@onready var ransom_continue_btn: Button = $RansomNote/VBox/Body/ContentVBox/ContinueButton
@onready var march_chat_panel: Panel = get_node_or_null("MarchChatPanel")
@onready var skip_button: Button = %SkipCutsceneButton
@onready var glitch_overlay: ColorRect = %GlitchOverlay

# Backward compatibility nodes
@onready var notification_panel: Panel = get_node_or_null("NotificationPanel")
@onready var notification_label: Label = get_node_or_null("NotificationPanel/NotificationLabel")

# Cutscene state
var _is_skipped: bool = false
var _is_cutscene_running: bool = false
var _is_waiting_for_save: bool = false
var _is_ransomware_triggered: bool = false
var _can_exit_pc: bool = false

var _passage_label: RichTextLabel

const FULL_REPORT_TEXT: String = """=== Cybersecurity Group Assignment: Incident Analysis & Recovery ===
Author: May (CS Year 2) | Group 8
Course: Network & Cyber Security Fundamentals
--------------------------------------------------------------

[1] Phishing Delivery & Email Provenance
- Attackers register typosquatting domains (e.g. subtle misspellings in sender emails or shared drives).
- Always verify sender domains character-by-character before trusting attachments.
- Macro-enabled documents (VBA AutoOpen / Document_Open) execute hidden helper binaries directly in AppData/Temp.

[2] Payload Obfuscation & Decoding Techniques
- Attackers obfuscate critical strings using Base64 and Hexadecimal encoding to bypass signature scanners.
- Base64 Decoding: Stripping padding and decoding strings exposes dropped helper tools (e.g. 'Office_Update_Helper.exe').
- Hexadecimal Decoding: Hex strings (e.g. 46 49 4C 45...) decode to ASCII commands such as 'FILE_WIPE'.
- Crucial Rule: Analysts must determine whether malware is reversible encryption or a destructive wiper before restoration!

[3] Windows Event Log Forensics & Timelines
- Windows Security and System Event Logs track process creation and network beacons with exact timestamps.
- Cross-referencing timestamps (e.g. initial execution at 19:02:10) isolates patient zero and affected files.

[4] Incident Containment & 3-2-1 Safe Backup Recovery
- First response: Immediately isolate infected devices from the network to halt automated CloudSync!
- Terminate persistence: Inspect Scheduled Tasks (schtasks) and Registry Run keys before recovery.
- Safe Restoration: Apply the 3-2-1 backup rule - restore clean versions prior to infection to an isolated destination.
--------------------------------------------------------------
[Report draft complete. All 4 group files ready for submission.]"""

const CUTSCENE_SECTIONS: Array[Dictionary] = [
	{
		"time": "19:30",
		"text": "=== Cybersecurity Group Assignment: Incident Analysis & Recovery ===\nAuthor: May (CS Year 2) | Group 8\nCourse: Network & Cyber Security Fundamentals\n--------------------------------------------------------------\n\n[1] Phishing Delivery & Email Provenance\n- Attackers register typosquatting domains (e.g. subtle misspellings in sender emails or shared drives).\n- Always verify sender domains character-by-character before trusting attachments.\n- Macro-enabled documents (VBA AutoOpen / Document_Open) execute hidden helper binaries directly in AppData/Temp.\n\n",
		"notification": "⛅ Weather Alert: คาดว่าคืนนี้อากาศจะร้อนจัดและมีความชื้นสูง"
	},
	{
		"time": "20:15",
		"text": "[2] Payload Obfuscation & Decoding Techniques\n- Attackers obfuscate critical strings using Base64 and Hexadecimal encoding to bypass signature scanners.\n- Base64 Decoding: Stripping padding and decoding strings exposes dropped helper tools (e.g. 'Office_Update_Helper.exe').\n- Hexadecimal Decoding: Hex strings (e.g. 46 49 4C 45...) decode to ASCII commands such as 'FILE_WIPE'.\n- Crucial Rule: Analysts must determine whether malware is reversible encryption or a destructive wiper before restoration!\n\n",
		"notification": "⚠️ System Alert: ดาวน์โหลดอัปเดต 'Office_Update_Helper' พร้อมติดตั้งในพื้นหลัง"
	},
	{
		"time": "21:00",
		"text": "[3] Windows Event Log Forensics & Timelines\n- Windows Security and System Event Logs track process creation and network beacons with exact timestamps.\n- Cross-referencing timestamps (e.g. initial execution at 19:02:10) isolates patient zero and affected files.\n\n",
		"notification": "🛡️ Windows Defender: ตรวจสอบระบบแล้ว - ไม่พบภัยคุกคาม (Active Content Allowed)"
	},
	{
		"time": "21:20",
		"text": "[4] Incident Containment & 3-2-1 Safe Backup Recovery\n- First response: Immediately isolate infected devices from the network to halt automated CloudSync!\n- Terminate persistence: Inspect Scheduled Tasks (schtasks) and Registry Run keys before recovery.\n- Safe Restoration: Apply the 3-2-1 backup rule - restore clean versions prior to infection to an isolated destination.\n--------------------------------------------------------------\n[Report draft complete. All 4 group files ready for submission.]\n",
		"notification": "☁️ CloudSync: กำลังซิงค์ Report_Final.docx และเอกสารงานกลุ่มขึ้น Cloud อัตโนมัติ..."
	}
]

func _ready() -> void:
	super._ready()
	_init_incident_overlays()
	_connect_incident_signals()
	_show_toast("💡 ภารกิจ: เปิดแอป 'GG Disk' เพื่อดาวน์โหลดโฟลเดอร์ 'งานกลุ่ม' มาทำรายงาน")

func _init_incident_overlays() -> void:
	if notification_panel:
		notification_panel.hide()
	if march_chat_panel:
		march_chat_panel.hide()
	if ransom_note:
		ransom_note.hide()
	if glitch_overlay:
		glitch_overlay.hide()
	if skip_button:
		skip_button.hide()
	if clock_label:
		clock_label.text = "19:02"

func _connect_incident_signals() -> void:
	if skip_button and not skip_button.pressed.is_connected(_on_skip_pressed):
		skip_button.pressed.connect(_on_skip_pressed)
	if ransom_continue_btn and not ransom_continue_btn.pressed.is_connected(_on_ransom_dismissed):
		ransom_continue_btn.pressed.connect(_on_ransom_dismissed)
	
	if ms_word_window:
		if ms_word_window.has_signal("typing_completed") and not ms_word_window.typing_completed.is_connected(_on_typing_game_completed):
			ms_word_window.typing_completed.connect(_on_typing_game_completed)
		if ms_word_window.has_signal("macro_enabled") and not ms_word_window.macro_enabled.is_connected(_on_word_macro_enabled):
			ms_word_window.macro_enabled.connect(_on_word_macro_enabled)
		if ms_word_window.has_signal("save_pressed") and not ms_word_window.save_pressed.is_connected(_on_save_clicked):
			ms_word_window.save_pressed.connect(_on_save_clicked)
		else:
			var save_btn: Button = ms_word_window.find_child("SaveButton", true, false) as Button
			if not save_btn:
				save_btn = ms_word_window.find_child("Button", true, false) as Button
			if save_btn and not save_btn.pressed.is_connected(_on_save_clicked):
				save_btn.pressed.connect(_on_save_clicked)

func _on_folder_downloaded_from_disk() -> void:
	super._on_folder_downloaded_from_disk()
	if clock_label:
		clock_label.text = "19:02"

func _on_word_macro_enabled() -> void:
	if clock_label:
		clock_label.text = "19:03"
	TelemetryManager.track_event("Scene_02", "T03", "macro_enabled", 0.0, true)

func _on_typing_game_completed() -> void:
	# Transition smoothly from interactive typing game into the timelapse incident cutscene
	_prepare_word_for_cutscene()
	_start_cutscene()

func _prepare_word_for_cutscene() -> void:
	if not ms_word_window:
		return
	ms_word_window.show()
	ms_word_window.move_to_front()
	_update_taskbar_tab(ms_word_window, "MS Word", true)
	
	var macro_banner: Node = ms_word_window.find_child("MacroBanner", true, false)
	if macro_banner and macro_banner is CanvasItem:
		macro_banner.hide()
	
	var typing_puzzle: Node = ms_word_window.find_child("TypingPuzzle", true, false)
	if typing_puzzle:
		if "is_resolved" in typing_puzzle:
			typing_puzzle.is_resolved = true
		if typing_puzzle is CanvasItem:
			typing_puzzle.show()
		var feedback_lbl: Node = typing_puzzle.find_child("FeedbackLabel", true, false)
		if feedback_lbl and feedback_lbl is CanvasItem:
			feedback_lbl.hide()
	
	_passage_label = ms_word_window.find_child("PassageLabel", true, false) as RichTextLabel
	if not _passage_label and typing_puzzle:
		_passage_label = typing_puzzle.find_child("PassageLabel", true, false) as RichTextLabel
	if not _passage_label:
		_passage_label = find_child("PassageLabel", true, false) as RichTextLabel
	
	if _passage_label:
		_passage_label.show()
		_passage_label.bbcode_enabled = true
		_passage_label.scroll_following = false
		_passage_label.scroll_active = false
		_passage_label.text = ""
	
	var editor_input: TextEdit = ms_word_window.find_child("TextEdit", true, false) as TextEdit
	if editor_input:
		editor_input.text = ""
		editor_input.editable = false
		editor_input.release_focus()
	
	if ms_word_window.has_method("scroll_to_top"):
		ms_word_window.call("scroll_to_top")

func _start_cutscene() -> void:
	if _is_cutscene_running:
		return
	_is_cutscene_running = true
	if skip_button:
		skip_button.show()
		skip_button.move_to_front()
	_run_timelapse_sequence()

func _run_timelapse_sequence() -> void:
	await get_tree().create_timer(0.4).timeout
	if not is_instance_valid(self) or not is_inside_tree():
		return
	
	for section: Dictionary in CUTSCENE_SECTIONS:
		if _is_skipped or not is_instance_valid(self) or not is_inside_tree():
			break
		
		if clock_label:
			clock_label.text = section["time"]
		
		_show_cutscene_toast(section["notification"])
		await _stream_text(section["text"])
		if not is_instance_valid(self) or not is_inside_tree():
			return
		_hide_toast()
		await get_tree().create_timer(0.25).timeout
		if not is_instance_valid(self) or not is_inside_tree():
			return
	
	_ready_for_save_event()

func _stream_text(text: String) -> void:
	if not _passage_label:
		return
	
	var chunk_size: int = 5
	var index: int = 0
	while index < text.length():
		if _is_skipped or not is_instance_valid(self) or not is_inside_tree() or not is_instance_valid(_passage_label):
			break
		
		var chunk: String = text.substr(index, chunk_size)
		_passage_label.text += chunk
		
		if ms_word_window and ms_word_window.has_method("scroll_following_content"):
			ms_word_window.scroll_following_content()
		
		index += chunk_size
		await get_tree().create_timer(0.04).timeout

func _show_cutscene_toast(message: String) -> void:
	if not notification_toast or not toast_label:
		return
	_toast_id += 1
	toast_label.text = message
	notification_toast.show()
	notification_toast.move_to_front()

func _hide_toast() -> void:
	_toast_id += 1
	if notification_toast:
		notification_toast.hide()

func _on_skip_pressed() -> void:
	if _is_skipped:
		return
	_is_skipped = true
	_ready_for_save_event()

func _ready_for_save_event() -> void:
	if _is_waiting_for_save or _is_ransomware_triggered:
		return
	_is_waiting_for_save = true
	_is_cutscene_running = false
	
	if skip_button:
		skip_button.hide()
	
	if _passage_label:
		_passage_label.text = FULL_REPORT_TEXT
	
	if ms_word_window and ms_word_window.has_method("scroll_to_bottom"):
		ms_word_window.scroll_to_bottom()
	
	if clock_label:
		clock_label.text = "21:23"
	
	if ms_word_window and ms_word_window.has_method("highlight_save_button"):
		ms_word_window.call("highlight_save_button")
	
	_show_cutscene_toast("💡 เมย์: พิมพ์รายงานเสร็จแล้ว! กดปุ่ม 'Save' ด้านบนเพื่อบันทึกงาน")

func _on_save_clicked() -> void:
	if _is_ransomware_triggered:
		return
	if not _is_waiting_for_save:
		if ms_word_window and ms_word_window.has_method("is_macro_enabled") and not ms_word_window.call("is_macro_enabled"):
			_show_toast("💡 เมย์: ต้องกดปุ่ม 'Enable' ที่แถบสีเหลืองด้านบนเพื่อเปิดเนื้อหาและพิมพ์รายงานก่อนบันทึก!")
		elif _is_cutscene_running:
			_show_toast("💡 เมย์: รอพิมพ์รายงานให้เสร็จก่อน หรือกด 'Skip Cutscene' มุมขวาบน")
		else:
			_show_toast("💡 เมย์: ต้องพิมพ์ข้อความในรายงานให้ครบก่อนถึงจะกด Save ได้!")
		return
	_is_waiting_for_save = false
	_is_ransomware_triggered = true
	is_ransomware_triggered = true
	
	_hide_toast()
	_show_cutscene_toast("☁️ CloudSync: กำลังบันทึกและซิงค์ Report_Final.docx ขึ้น Cloud อัตโนมัติ...")
	# รอพักหนึ่ง 2.5 วินาที (2-3 วินาที) ค่อย alert ตามข้อกำหนด
	await get_tree().create_timer(2.5).timeout
	if not is_instance_valid(self) or not is_inside_tree():
		return
	_hide_toast()
	
	# ปิดหน้าต่าง MS Word (หลังจากนี้จะไม่สามารถเปิด Word ได้อีก)
	if ms_word_window:
		_close_app_window(ms_word_window)
	
	if glitch_overlay:
		glitch_overlay.show()
		await get_tree().create_timer(0.18).timeout
		if not is_instance_valid(self) or not is_inside_tree():
			return
		glitch_overlay.hide()
		await get_tree().create_timer(0.08).timeout
		if not is_instance_valid(self) or not is_inside_tree():
			return
		glitch_overlay.show()
		await get_tree().create_timer(0.18).timeout
		if not is_instance_valid(self) or not is_inside_tree():
			return
		glitch_overlay.hide()
	
	_show_locked_files()
	
	await get_tree().create_timer(0.4).timeout
	if not is_instance_valid(self) or not is_inside_tree():
		return
	if ransom_note:
		ransom_note.show()
		ransom_note.move_to_front()

func _show_locked_files() -> void:
	if not downloaded_folder_window:
		return
	
	downloaded_folder_window.show()
	downloaded_folder_window.move_to_front()
	_update_taskbar_tab(downloaded_folder_window, "งานกลุ่ม", true)
	_highlight_active_tab(downloaded_folder_window)
	
	# ซ่อน Report_Final.docx ตามคำสั่ง "hide report ไปเลย"
	var report_panel: Control = downloaded_folder_window.find_child("MSWordReport", true, false) as Control
	if not report_panel:
		report_panel = downloaded_folder_window.find_child("PanelContainer", true, false) as Control
	if report_panel:
		report_panel.visible = false
	
	# แสดง AlertFile (ReadMe_to_recovery.txt)
	var alert_panel: Control = downloaded_folder_window.find_child("AlertFile", true, false) as Control
	if alert_panel:
		alert_panel.visible = true
	
	var title_lbl: Label = downloaded_folder_window.find_child("Label", true, false) as Label
	if title_lbl:
		title_lbl.text = "งานกลุ่มล้านแปด (ALL .LOCKED)"
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
	
	var pp_panel: Control = downloaded_folder_window.find_child("PPPresentation", true, false) as Control
	if pp_panel:
		var pp_lbl: Label = pp_panel.find_child("FileName", true, false) as Label
		if pp_lbl:
			pp_lbl.text = "Presentation.pptx.locked"
			pp_lbl.add_theme_color_override("font_color", Color(0.95, 0.2, 0.2, 1.0))
	
	var png_panel: Control = downloaded_folder_window.find_child("PNGNetworkDiagram", true, false) as Control
	if png_panel:
		var png_lbl: Label = png_panel.find_child("FileName", true, false) as Label
		if png_lbl:
			png_lbl.text = "Network_Diagram.png.locked"
			png_lbl.add_theme_color_override("font_color", Color(0.95, 0.2, 0.2, 1.0))

# บล็อกไม่ให้เปิด MS Word อีกเด็ดขาดหลังจาก Ransomware ทำงาน
func _on_app_activated(app_id: String) -> void:
	if app_id == "ms_word" and _is_ransomware_triggered:
		_show_cutscene_toast("⚠️ ไม่สามารถเปิด Microsoft Word ได้: โปรแกรมถูกล็อกและไฟล์เสียหาย (.locked)")
		return
	if app_id == "discord" and _is_ransomware_triggered:
		_show_cutscene_toast("💬 Discord (M4rch): Roblox ป่าวน้อง หรือทำการบ้านอยู่? (ไปคุยต่อในมือถือ)")
		return
	super._on_app_activated(app_id)

func _open_app_window(win: Control, tab_title: String) -> void:
	if win == ms_word_window and _is_ransomware_triggered:
		_show_cutscene_toast("⚠️ ไม่สามารถเปิด Microsoft Word ได้: โปรแกรมถูกล็อกและไฟล์เสียหาย (.locked)")
		return
	super._open_app_window(win, tab_title)

func _on_file_opened_from_folder(file_name: String) -> void:
	if _is_ransomware_triggered:
		if file_name.to_lower().contains("readme"):
			if ransom_note:
				ransom_note.show()
				ransom_note.move_to_front()
			return
		_show_cutscene_toast("⚠️ ไม่สามารถเปิดไฟล์นี้ได้: ไฟล์ถูกเข้ารหัสโดย Ransomware (.locked)")
		return
	super._on_file_opened_from_folder(file_name)

func _on_ransom_dismissed() -> void:
	if ransom_note:
		ransom_note.hide()
	
	_can_exit_pc = true
	
	if leave_pc_button:
		leave_pc_button.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2, 1.0))
		leave_pc_button.text = "ออก (Exit)"
	
	# ข้อความจากพี่มาร์ชในหน้าจอคอมขึ้นแค่อันเดียวคือ Roblox ป่าว
	_show_cutscene_toast("💬 Discord: M4rchupikchu_inw101: Roblox ป่าวน้อง หรือทำการบ้านอยู่?")
	
	await get_tree().create_timer(2.0).timeout
	if not is_instance_valid(self) or not is_inside_tree():
		return
	
	# ชี้แนะให้เมย์ออกจากคอมไปอ่านและคุยต่อในมือถือ
	_show_cutscene_toast("⚠️ เมย์: ไม่นะ! ไฟล์งานโดนล็อกหมดแล้ว! ต้องออกจากคอมไปคุยกับพี่มาร์ชในมือถือ (กด 'ออก' ที่ Taskbar)")

func _on_leave_pc_pressed() -> void:
	if not _can_exit_pc:
		_show_cutscene_toast("เมย์: ยังทำงานไม่เสร็จเลย ต้องดาวน์โหลดไฟล์ พิมพ์รายงาน และกด Save ก่อน!")
		return
	
	TelemetryManager.track_event(
		"Scene_03",
		"incident_ransomware",
		"cutscene_completed",
		0.0,
		true,
		1,
		false,
		{"files_locked": 4, "incident_time": "21:23"}
	)
	
	var result: Error = get_tree().change_scene_to_file(SCENE_04_PATH)
	if result != OK:
		push_error("Unable to load Scene 4: %s (error %d)" % [SCENE_04_PATH, result])
