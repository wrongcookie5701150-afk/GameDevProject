extends Control

const SCENE_04_PATH: String = "res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn"

# Desktop Windows & Containers
@onready var window_container: Control = %WindowContainer
@onready var ms_word: Control = $WindowContainer/MsWord
@onready var downloaded_folder: Control = $WindowContainer/DownloadedFolder
@onready var gg_disk: Control = $WindowContainer/GgDisk
@onready var discord_app: Control = $WindowContainer/DiscordApp

# Taskbar & System Tray
@onready var clock_label: Label = %ClockLabel
@onready var taskbar_tabs: HBoxContainer = %TaskbarTabsContainer
@onready var leave_pc_button: Button = %LeavePCButton
@onready var start_menu_leave_btn: Button = %StartMenuLeaveBtn

# Cutscene Controls & Overlays
@onready var notification_toast: PanelContainer = %NotificationToast
@onready var toast_label: Label = %ToastLabel
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
	_init_ui_state()
	_setup_taskbar()
	_connect_signals()
	_start_cutscene()

func _init_ui_state() -> void:
	if notification_panel:
		notification_panel.hide()
	if notification_toast:
		notification_toast.hide()
	if march_chat_panel:
		march_chat_panel.hide()
	if ransom_note:
		ransom_note.hide()
	if glitch_overlay:
		glitch_overlay.hide()
	if downloaded_folder:
		downloaded_folder.hide()
	if gg_disk:
		gg_disk.hide()
	if discord_app:
		discord_app.hide()

	# Configure MS Word for the timelapse cutscene
	if ms_word:
		ms_word.show()
		ms_word.move_to_front()
		
		var macro_banner: Node = ms_word.find_child("MacroBanner", true, false)
		if macro_banner and macro_banner is CanvasItem:
			macro_banner.hide()
		
		# Ensure TypingPuzzle is shown so PassageLabel is visible
		var typing_puzzle: Node = ms_word.find_child("TypingPuzzle", true, false)
		if typing_puzzle and typing_puzzle is CanvasItem:
			typing_puzzle.show()
			var feedback_lbl: Node = typing_puzzle.find_child("FeedbackLabel", true, false)
			if feedback_lbl and feedback_lbl is CanvasItem:
				feedback_lbl.hide()
		
		# Find PassageLabel for cutscene text streaming
		_passage_label = ms_word.find_child("PassageLabel", true, false) as RichTextLabel
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
		
		# Disable player input on TextEdit during cutscene
		var editor_input: TextEdit = ms_word.find_child("TextEdit", true, false) as TextEdit
		if editor_input:
			editor_input.text = ""
			editor_input.editable = false
		
		if ms_word.has_method("scroll_to_top"):
			ms_word.call("scroll_to_top")

	if clock_label:
		clock_label.text = "19:15"

func _setup_taskbar() -> void:
	if not taskbar_tabs:
		return
	
	var tab_word: Button = taskbar_tabs.find_child("Tab_MsWord", true, false) as Button
	if tab_word:
		tab_word.show()

func _connect_signals() -> void:
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)
	if ransom_continue_btn:
		ransom_continue_btn.pressed.connect(_on_ransom_dismissed)
	
	# Connect Word Save button
	if ms_word:
		if ms_word.has_signal("save_pressed"):
			ms_word.connect("save_pressed", Callable(self, "_on_save_clicked"))
		else:
			var save_btn: Button = ms_word.find_child("SaveButton", true, false) as Button
			if not save_btn:
				save_btn = ms_word.find_child("Button", true, false) as Button
			if save_btn and not save_btn.pressed.is_connected(_on_save_clicked):
				save_btn.pressed.connect(_on_save_clicked)
	
	# Connect Leave PC buttons
	if leave_pc_button:
		leave_pc_button.pressed.connect(_on_leave_pc_pressed)
	if start_menu_leave_btn:
		start_menu_leave_btn.pressed.connect(_on_leave_pc_pressed)

func _start_cutscene() -> void:
	_is_cutscene_running = true
	_run_timelapse_sequence()

func _run_timelapse_sequence() -> void:
	await get_tree().create_timer(0.4).timeout
	
	for section: Dictionary in CUTSCENE_SECTIONS:
		if _is_skipped:
			break
		
		# Update clock
		if clock_label:
			clock_label.text = section["time"]
		
		# Show background notification while May continues typing
		_show_toast(section["notification"])
		
		# Stream text into Word editor
		await _stream_text(section["text"])
		
		_hide_toast()
		await get_tree().create_timer(0.25).timeout
	
	# Wait for player to press Save button
	_ready_for_save_event()

func _stream_text(text: String) -> void:
	if not _passage_label:
		return
	
	var chunk_size: int = 5
	var index: int = 0
	while index < text.length():
		if _is_skipped:
			break
		
		var chunk: String = text.substr(index, chunk_size)
		_passage_label.text += chunk
		
		# Auto-scroll to follow text smoothly without overshooting
		if ms_word and ms_word.has_method("scroll_following_content"):
			ms_word.scroll_following_content()
		
		index += chunk_size
		await get_tree().create_timer(0.04).timeout

func _show_toast(message: String) -> void:
	if not notification_toast or not toast_label:
		return
	toast_label.text = message
	notification_toast.show()
	notification_toast.move_to_front()

func _hide_toast() -> void:
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
	
	if ms_word and ms_word.has_method("scroll_to_bottom"):
		ms_word.scroll_to_bottom()
	
	if clock_label:
		clock_label.text = "21:23"
	
	if ms_word and ms_word.has_method("highlight_save_button"):
		ms_word.call("highlight_save_button")
	
	_show_toast("💡 เมย์: พิมพ์รายงานเสร็จแล้ว! กดปุ่ม 'Save' ด้านบนเพื่อบันทึกงาน")

func _on_save_clicked() -> void:
	if not _is_waiting_for_save or _is_ransomware_triggered:
		return
	_is_waiting_for_save = false
	_is_ransomware_triggered = true
	
	_hide_toast()
	_show_toast("☁️ CloudSync: ซิงค์ Report_Final.docx ขึ้น Cloud อัตโนมัติ...")
	await get_tree().create_timer(1.2).timeout
	_hide_toast()
	
	# Sudden glitch / ransomware infection flash
	if glitch_overlay:
		glitch_overlay.show()
		await get_tree().create_timer(0.18).timeout
		glitch_overlay.hide()
		await get_tree().create_timer(0.08).timeout
		glitch_overlay.show()
		await get_tree().create_timer(0.18).timeout
		glitch_overlay.hide()
	
	# Lock project folder files
	_show_locked_files()
	
	# Pop up the Ransom Note
	await get_tree().create_timer(0.4).timeout
	if ransom_note:
		ransom_note.show()
		ransom_note.move_to_front()

func _show_locked_files() -> void:
	if not downloaded_folder:
		return
	
	downloaded_folder.show()
	downloaded_folder.move_to_front()
	
	var title_lbl: Label = downloaded_folder.find_child("Label", true, false) as Label
	if title_lbl:
		title_lbl.text = "งานกลุ่มล้านแปด (4 files - ALL .LOCKED)"
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
	
	var file_labels: Array[Node] = downloaded_folder.find_children("FileName", "Label", true, false)
	var locked_names: Array[String] = [
		"Report_Final.docx.locked",
		"Presentation.pptx.locked",
		"Network_Diagram.png.locked"
	]
	
	for i: int in range(mini(file_labels.size(), locked_names.size())):
		var lbl: Label = file_labels[i] as Label
		if lbl:
			lbl.text = locked_names[i]
			lbl.add_theme_color_override("font_color", Color(0.95, 0.2, 0.2, 1.0))

func _on_ransom_dismissed() -> void:
	if ransom_note:
		ransom_note.hide()
	
	_can_exit_pc = true
	
	# March message notification appears on desktop screen
	_show_toast("💬 Discord: M4rchupikchu_inw101: Roblox ป่าวน้อง หรือทำการบ้านอยู่?")
	
	await get_tree().create_timer(1.5).timeout
	
	# Prompt player to exit desktop to use their phone in the bedroom (Scene 4)
	_show_toast("⚠️ เมย์: ไม่นะ! ไฟล์งานโดนล็อกหมดแล้ว! ต้องออกจากคอมไปคุยกับพี่มาร์ชในมือถือ (กด 'ออก' ที่ Taskbar)")
	
	# Highlight the Leave PC button
	if leave_pc_button:
		leave_pc_button.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2, 1.0))
		leave_pc_button.text = "ออก (Exit)"

func _on_leave_pc_pressed() -> void:
	if not _can_exit_pc:
		_show_toast("เมย์: ยังทำงานไม่เสร็จเลย ต้องพิมพ์และบันทึกรายงานก่อน!")
		return
	
	# Telemetry for scene completion
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
	
	# Transition to Scene 04
	var result: Error = get_tree().change_scene_to_file(SCENE_04_PATH)
	if result != OK:
		push_error("Unable to load Scene 4: %s (error %d)" % [SCENE_04_PATH, result])
