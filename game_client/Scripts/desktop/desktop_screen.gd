class_name DesktopScreenController extends Control

## Simulated OS desktop for May's PC (Story Scenes 2-5).

const BEDROOM_SCENE_PATH: String = "res://Scenes/Scene_02_Tutorial.tscn"

# System fonts & textures
const TEX_WIFI_CONNECTED: Texture2D = preload("res://assets/Icon32x32/world_enable.png")
const TEX_WIFI_DISCONNECTED: Texture2D = preload("res://assets/Icon32x32/world_disable.png")
const TEX_DISK_SAVE: Texture2D = preload("res://assets/Icon32x32/disk_save.png")
const TEX_FOLDER: Texture2D = preload("res://assets/Icon32x32/folder.png")
const TEX_DRIVE: Texture2D = preload("res://assets/Icon/Google Drive.png")
const TEX_WORD: Texture2D = preload("res://assets/Icon/Microsoft Word.png")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")
const FONT_PIXEL: FontFile = preload("res://assets/fonts/Press_Start_2P/PressStart2P-Regular.ttf")
const FONT_THAI_MEDIUM: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Medium.ttf")
const FONT_THAI_BOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")

# Signals
signal wifi_toggled(is_connected: bool)
signal task2_step_completed(step_name: String)
signal report_saved
signal scene_2_completed
signal scene_3_cutscene_started
signal scene_3_cutscene_completed
signal phone_toggle_requested

# Tutorial 5 / Task 2 State Machine
enum Task2State {
	WAIT_GG_DOWNLOAD,    # Step 1: Download from GG Disk
	WAIT_FOLDER_OPEN,    # Step 2: Open folder & Report_Final.docx
	TYPING_REPORT,       # Step 3: Typing mini-game (0-100 words)
	REPORT_SAVED         # Step 4: Report saved, completed
}

# Scene 3: Incident Cutscene State Machine (21:21 - 21:25)
enum IncidentCutsceneState {
	IDLE,
	PANEL_1_TYPING_TIMELAPSE,
	PANEL_2_FILES_NORMAL,
	PANEL_3_GLITCH_LOCKING,
	PANEL_4_RANSOMWARE_NOTE,
	PANEL_5_MARCH_SIGNAL,
	SCENE_3_COMPLETED
}

var current_task2_state: Task2State = Task2State.WAIT_GG_DOWNLOAD
var current_incident_state: IncidentCutsceneState = IncidentCutsceneState.IDLE
var is_incident_cutscene_running: bool = false
var is_gg_downloaded: bool = false
var is_report_opened: bool = false
var is_report_saved: bool = false
var is_standalone_scene_3: bool = false
var words_typed: int = 0
const MAX_WORDS: int = 100
const WORD_TARGET: int = 100

const REPORT_FULL_TEXT: String = """1. บทนำและความสำคัญ (Introduction to Cybersecurity)
ความมั่นคงปลอดภัยไซเบอร์ เป็นหัวใจสำคัญ ในการปกป้องข้อมูล และระบบสารสนเทศ ขององค์กร จากภัยคุกคาม ทางไซเบอร์ ที่เพิ่มขึ้น อย่างต่อเนื่อง
ในยุคดิจิทัล ผู้ไม่หวังดี มักใช้เทคนิค วิศวกรรมสังคม Social Engineering ในการหลอกลวง ผู้ใช้งาน ผ่านทาง อีเมลฟิชชิ่ง (Phishing Email) เพื่อแพร่กระจาย มัลแวร์ อันตราย

2. กลไกการโจมตีของ Macro Ransomware
เมื่อผู้ใช้งาน หลงเชื่อ เปิดไฟล์เอกสาร และกดปุ่ม Enable Content เพื่อรัน Macro สคริปต์ อันตรายจะทำงาน ในเบื้องหลัง ทันที
สคริปต์ จะทำการ ดาวน์โหลด มัลแวร์เรียกค่าไถ่ เข้าสู่ระบบ และเริ่มกระบวนการ เข้ารหัสลับ ไฟล์เอกสาร ทั้งหมด พร้อมเปลี่ยน นามสกุลไฟล์ เป็น .locked อย่างรวดเร็ว

3. การป้องกันและกู้คืนข้อมูล (3-2-1 Backup Strategy)
องค์กร ควรถือปฏิบัติตาม กฎสำรองข้อมูล 3-2-1 อย่างเคร่งครัด
- สำรองข้อมูล อย่างน้อย 3 ชุด
- จัดเก็บบน สื่อบันทึก 2 รูปแบบ ที่แตกต่างกัน
- เก็บข้อมูล สำรอง ออฟไลน์ ไว้นอกสถานที่ อย่างน้อย 1 ชุด

4. สรุปแนวทางปฏิบัติ (Best Practices)
ผู้ใช้ ต้องตรวจสอบ แหล่งที่มา ของไฟล์ และห้ามกด เปิดใช้งาน Macro โดยเด็ดขาด"""

# Report content chunks for progressive typewriter simulation
const REPORT_PARAGRAPHS: Array[String] = [
	"1. บทนำและความสำคัญ (Introduction)\nความมั่นคงปลอดภัยไซเบอร์ (Cybersecurity) เป็นหัวใจสำคัญในการปกป้องข้อมูลและระบบสารสนเทศขององค์กรจากการถูกคุกคาม...",
	"\nในยุคปัจจุบัน ผู้ไม่หวังดีมักใช้เทคนิควิศวกรรมสังคม (Social Engineering) เช่น การส่งอีเมลฟิชชิ่งแนบไฟล์เอกสารที่ฝังโค้ดอันตรายเพื่อหลอกให้ผู้ใช้เปิดใช้งาน...",
	"\n2. กลไกการแพร่ระบาดของ Macro Ransomware\nเมื่อเหยื่อหลงเชื่อกด 'Enable Content' หรือเปิดใช้งาน Macro มัลแวร์จะดาวน์โหลดเพย์โหลดเข้ารหัสไฟล์ข้อมูลทั้งหมดในเครื่องทันที...",
	"\n3. การรับมือตามหลัก 3-2-1 Backup Rule\n- เก็บข้อมูลสำรอง 3 ชุด ในสื่อบันทึก 2 แบบ และเก็บสำรองแบบออฟไลน์ 1 แห่ง...",
	"\n4. สรุปข้อปฏิบัติเพื่อความปลอดภัย\n- ตรวจสอบอีเมลผู้ส่งอย่างรอบคอบ ไม่เปิดไฟล์จากแหล่งที่ไม่มั่นใจ และห้ามเปิดใช้งาน Macro เด็ดขาด",
	"\n[ เอกสารรายงานวิชาความมั่นคงปลอดภัยไซเบอร์ สมบูรณ์ครบ 100 คำ พร้อมกดปุ่ม Save ]"
]

# March chat history by narrative timeline phases
const CHAT_MARCH_PHASE1: String = """[Direct Message - M4rchupikchu_inw101]
เมื่อวาน 20:15 | M4rchupikchu_inw101:
"Roblox ป่าวน้อง"

เมื่อวาน 20:18 | Mayicomeinpls:
"ทำการบ้านก่อนพี่ พรุ่งนี้เดดไลน์"

เมื่อวาน 20:20 | M4rchupikchu_inw101:
"เคๆ พรุ่งนี้ค่อยเล่น" """

const CHAT_MARCH_POST_INCIDENT: String = """

21:25 | M4rchupikchu_inw101:
"Roblox ป่าวน้อง"

21:26 | Mayicomeinpls:
"พี่มาร์ชคะ คอมเปิดไฟล์ไม่ได้ค่ะ"

21:28 | M4rchupikchu_inw101:
"ไฟล์อะไร"

21:28 | Mayicomeinpls:
"ไฟล์ docx แล้ว .locked ค่ะ"

21:30 | M4rchupikchu_inw101:
"อืมม ตัดเน็ตคอมพิวเตอร์ก่อน" """

# Drive activity logs in English
const DRIVE_ACTIVITY_LOG: String = """Activity Log - Group Project

14:30 | Mesa uploaded Network_Diagram.png
14:32 | Mesa uploaded Research_Data.xlsx
17:45 | Mesa uploaded Presentation.pptx
18:50 | Mesa uploaded Report_Final.docx
19:00 | May accessed shared folder"""

# Containers & Desktop Icons
var icons_container: Control
var window_container: Control
var icon_files: DesktopIcon
var icon_gg_disk: DesktopIcon
var icon_word: DesktopIcon
var icon_notepad: DesktopIcon
var icon_discord: DesktopIcon
var icon_recycle_bin: DesktopIcon
var discord_desktop_badge: PanelContainer

# Application windows
var gg_disk_window: DesktopWindow
var ms_word_window: DesktopWindow
var files_window: DesktopWindow
var text_editor_window: DesktopWindow
var discord_window: DesktopWindow
var recycle_bin_window: DesktopWindow

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
var menu_notepad: Button
var menu_discord: Button
var menu_recycle_bin: Button

# Wi-Fi tray & modal controls
var wifi_tray_btn: Button
var wifi_popup: PanelContainer
var wifi_toggle_btn: Button
var wifi_status_label: Label
var wifi_cloud_sync_label: Label
var wifi_close_btn: Button

# In-app references: GG Disk
var gg_tab_files_btn: Button
var gg_tab_history_btn: Button
var gg_files_panel: Control
var gg_history_panel: Control
var gg_open_word_btn: Button

# In-app references: Word
var word_macro_banner: PanelContainer
var enable_content_btn: Button
var word_doc_status: Label
var word_save_btn: Button
var word_save_prompt: Label
var word_counter_label: Label
var word_paper_panel: PanelContainer
var word_body_label: Label
var word_save_tween: Tween
var word_scroll_container: ScrollContainer
var word_scroll_tween: Tween
var typing_tween: Tween
var typed_char_count: int = 0
var target_char_count: int = 0
var is_cursor_visible: bool = true
var cursor_blink_timer: float = 0.0

# In-app references: File Explorer
var file_item_report_label: Label
var file_item_diagram_label: Label
var file_item_data_label: Label
var file_item_pres_label: Label
var file_item_readme: Control
var file_item_report_open_btn: Button
var file_item_readme_open_btn: Button
var file_item_4: Control

# In-app references: Discord
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

# In-app references: Notepad / Text Editor
var notepad_alert_banner: Label
var notepad_body_text: Label

# Top-Right Objective Panel (Task 2)
var objective_panel: PanelContainer
var objective_header_label: Label
var objective_item1_label: Label
var objective_item2_label: Label

# Audio synthesizer player
var sfx_player: AudioStreamPlayer

# Scene 3 Incident Cutscene UI Nodes
var dialogue_toast_panel: PanelContainer
var dialogue_toast_speaker: Label
var dialogue_toast_text: Label
var dialogue_toast_tween: Tween
var notif_stack_container: VBoxContainer
var glitch_overlay: ColorRect

# Incident timeline state (starts at 19:02)
var is_wifi_connected: bool = true
var is_ransomware_triggered: bool = false
var story_time_string: String = "19:02"

# Taskbar tab styles
var _tab_style_active: StyleBoxFlat
var _tab_style_inactive: StyleBoxFlat

func _exit_tree() -> void:
	if word_save_tween and word_save_tween.is_valid():
		word_save_tween.kill()
	if word_scroll_tween and word_scroll_tween.is_valid():
		word_scroll_tween.kill()
	if typing_tween and typing_tween.is_valid():
		typing_tween.kill()
	if dialogue_toast_tween and dialogue_toast_tween.is_valid():
		dialogue_toast_tween.kill()

func _ready() -> void:
	# 1.1 Root Node Layout: ensure Full Rect with zero offsets (480x270 viewport)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH

	_resolve_all_nodes()
	_setup_audio()
	_init_taskbar_styles()
	_init_taskbar()
	_connect_icons()
	_connect_windows()
	_setup_objective_panel()
	_setup_files_explorer()
	_setup_gg_disk()
	_setup_word_window()
	_setup_text_editor()
	_setup_discord_window()
	_setup_incident_cutscene_ui()
	_hide_all_windows()
	_update_clock()
	_update_file_status_ui()
	_update_wifi_ui()
	
	# Initial desktop state for Task 2: Hide 'งานกลุ่ม' folder
	if icon_files:
		icon_files.visible = false

# Safe node lookup (unique name -> subtree -> fallback)
func _find_node_safe(node_name: String, search_roots: Array = []) -> Node:
	if has_node("%" + node_name):
		return get_node("%" + node_name)
	
	for root_node in search_roots:
		if root_node and is_instance_valid(root_node):
			var found: Node = root_node.find_child(node_name, true, false)
			if found:
				return found
	
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
	
	# Desktop Icons
	icon_files = _find_node_safe("Icon_Files") as DesktopIcon
	icon_gg_disk = _find_node_safe("Icon_GGDisk") as DesktopIcon
	icon_word = _find_node_safe("Icon_Word") as DesktopIcon
	icon_notepad = _find_node_safe("Icon_Notepad") as DesktopIcon
	icon_discord = _find_node_safe("Icon_Discord") as DesktopIcon
	icon_recycle_bin = _find_node_safe("Icon_RecycleBin") as DesktopIcon
	
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
	
	# Notepad internal nodes
	notepad_alert_banner = _find_node_safe("AlertBanner", [text_editor_window]) as Label
	notepad_body_text = _find_node_safe("BodyText", [text_editor_window]) as Label

# --- Procedural Audio Synthesizer ---
func _setup_audio() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "DesktopSfxPlayer"
	sfx_player.volume_db = -8.0
	add_child(sfx_player)

func _play_sfx_download_complete() -> void:
	if not sfx_player or not sfx_player.is_inside_tree():
		return
	var sample_rate: int = 22050
	var dur: float = 0.36
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	
	var chord_notes: Array[float] = [523.25, 659.25, 783.99]
	var seg_len: float = dur / 3.0
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var note_idx: int = clampi(int(t / seg_len), 0, 2)
		var freq: float = chord_notes[note_idx]
		var local_t: float = fmod(t, seg_len)
		var decay: float = 1.0 - (local_t / seg_len)
		var wave: float = sin(2.0 * PI * freq * t) * decay * 0.7
		data[i] = int(clampf(128.0 + (wave * 45.0), 0.0, 255.0))
	
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _play_sfx_folder_open() -> void:
	if not sfx_player or not sfx_player.is_inside_tree():
		return
	var sample_rate: int = 22050
	var sample_count: int = int(sample_rate * 0.05)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_count)
		var decay: float = 1.0 - t
		var wave: float = sin(2.0 * PI * 680.0 * (float(i) / float(sample_rate))) * decay
		data[i] = int(clampf(128.0 + (wave * 35.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _play_sfx_typewriter() -> void:
	if not sfx_player or not sfx_player.is_inside_tree():
		return
	var sample_rate: int = 22050
	var sample_count: int = int(sample_rate * 0.02)
	var data := PackedByteArray()
	data.resize(sample_count)
	var freq: float = 1200.0 + randf_range(-150.0, 150.0)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_count)
		var decay: float = 1.0 - t
		var wave: float = sin(2.0 * PI * freq * (float(i) / float(sample_rate))) * decay
		data[i] = int(clampf(128.0 + (wave * 30.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _play_sfx_save_complete() -> void:
	if not sfx_player or not sfx_player.is_inside_tree():
		return
	var sample_rate: int = 22050
	var dur: float = 0.4
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var decay: float = 1.0 - (float(i) / float(sample_count))
		var wave1: float = sin(2.0 * PI * 587.33 * t)
		var wave2: float = sin(2.0 * PI * 880.00 * t)
		var wave: float = (wave1 + wave2) * 0.5 * decay
		data[i] = int(clampf(128.0 + (wave * 45.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _play_sfx_popup() -> void:
	if not sfx_player or not sfx_player.is_inside_tree():
		return
	var sample_rate: int = 22050
	var dur: float = 0.22
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var decay: float = exp(-t * 14.0)
		var wave: float = sin(2.0 * PI * 880.0 * t) * 0.6 + sin(2.0 * PI * 1320.0 * t) * 0.4
		data[i] = int(clampf(128.0 + (wave * decay * 40.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _play_sfx_glitch() -> void:
	if not sfx_player or not sfx_player.is_inside_tree():
		return
	var sample_rate: int = 22050
	var dur: float = 0.45
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var decay: float = 1.0 - (t / dur)
		var freq: float = 120.0 + (90.0 if (int(t * 60.0) % 2 == 0) else -40.0)
		var wave: float = 1.0 if sin(2.0 * PI * freq * t) > 0.0 else -1.0
		wave += (randf() * 2.0 - 1.0) * 0.35
		data[i] = int(clampf(128.0 + (wave * decay * 38.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _play_sfx_error_buzzer() -> void:
	if not sfx_player or not sfx_player.is_inside_tree():
		return
	var sample_rate: int = 22050
	var dur: float = 0.18
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var decay: float = 1.0 - (t / dur)
		var wave: float = 1.0 if sin(2.0 * PI * 180.0 * t) > 0.0 else -1.0
		data[i] = int(clampf(128.0 + (wave * decay * 36.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _play_sfx_ransomware_alert() -> void:
	if not sfx_player or not sfx_player.is_inside_tree():
		return
	var sample_rate: int = 22050
	var dur: float = 0.55
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var decay: float = exp(-t * 4.0)
		var freq: float = 240.0 - (t * 80.0)
		var wave: float = sin(2.0 * PI * freq * t) * 0.7 + sin(2.0 * PI * (freq * 0.5) * t) * 0.3
		data[i] = int(clampf(128.0 + (wave * decay * 46.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _play_sfx_chat_ding() -> void:
	if not sfx_player or not sfx_player.is_inside_tree():
		return
	var sample_rate: int = 22050
	var dur: float = 0.38
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var decay: float = exp(-t * 7.5)
		var freq: float = 659.25 if t < 0.12 else 783.99
		var wave: float = sin(2.0 * PI * freq * t)
		data[i] = int(clampf(128.0 + (wave * decay * 45.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

# --- Top-Right Objective Panel (Task 2) ---
func _setup_objective_panel() -> void:
	if objective_panel and is_instance_valid(objective_panel):
		return
	
	objective_panel = PanelContainer.new()
	objective_panel.name = "ObjectivePanel"
	objective_panel.z_index = 25
	objective_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Theme colors: Navy #0E152B, Cream #DEB887
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.082, 0.169, 0.94)
	panel_style.border_color = Color(0.87, 0.72, 0.53, 1.0)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.content_margin_left = 8.0
	panel_style.content_margin_right = 8.0
	panel_style.content_margin_top = 5.0
	panel_style.content_margin_bottom = 5.0
	panel_style.shadow_color = Color(0, 0, 0, 0.45)
	panel_style.shadow_size = 3
	objective_panel.add_theme_stylebox_override("panel", panel_style)
	
	var vbox := VBoxContainer.new()
	vbox.name = "ObjectiveVBox"
	vbox.add_theme_constant_override("separation", 2)
	objective_panel.add_child(vbox)
	
	objective_header_label = Label.new()
	objective_header_label.name = "ObjectiveHeader"
	objective_header_label.text = "• Task 2 ทำรายงานต่อ"
	objective_header_label.add_theme_font_override("font", FONT_THAI_BOLD)
	objective_header_label.add_theme_font_size_override("font_size", 8)
	objective_header_label.add_theme_color_override("font_color", Color(0.87, 0.72, 0.53, 1.0))
	vbox.add_child(objective_header_label)
	
	objective_item1_label = Label.new()
	objective_item1_label.name = "ObjectiveItem1"
	objective_item1_label.add_theme_font_override("font", FONT_THAI_MEDIUM)
	objective_item1_label.add_theme_font_size_override("font_size", 7)
	objective_item1_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_item1_label.custom_minimum_size.x = 120.0
	vbox.add_child(objective_item1_label)
	
	objective_item2_label = Label.new()
	objective_item2_label.name = "ObjectiveItem2"
	objective_item2_label.add_theme_font_override("font", FONT_THAI_MEDIUM)
	objective_item2_label.add_theme_font_size_override("font_size", 7)
	objective_item2_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_item2_label.custom_minimum_size.x = 120.0
	vbox.add_child(objective_item2_label)
	
	add_child(objective_panel)
	_update_objective_panel()

func _update_objective_panel() -> void:
	if not objective_panel or not is_instance_valid(objective_panel):
		return
	
	if current_incident_state == IncidentCutsceneState.SCENE_3_COMPLETED or current_incident_state == IncidentCutsceneState.PANEL_5_MARCH_SIGNAL:
		objective_header_label.text = "• ติดต่อขอความช่วยเหลือจากพี่มาร์ช"
		objective_item1_label.text = "- [ ] ตอบแชตพี่มาร์ช (กด [P] หรือเปิด Discord)"
		objective_item1_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))
		objective_item2_label.text = ""
		objective_item2_label.visible = false
	else:
		match current_task2_state:
			Task2State.WAIT_GG_DOWNLOAD:
				objective_header_label.text = "• Task 2 ทำรายงานต่อ"
				objective_item1_label.text = "- [ ] โหลดงานจาก GG Disk"
				objective_item1_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
				objective_item2_label.text = "- [ ] เปิดและแก้รายงานจาก folder กลุ่ม"
				objective_item2_label.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85, 0.8))
				objective_item2_label.visible = true
				
			Task2State.WAIT_FOLDER_OPEN:
				objective_header_label.text = "• Task 2 ทำรายงานต่อ"
				objective_item1_label.text = "- [x] โหลดงานจาก GG Disk"
				objective_item1_label.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5, 1.0))
				objective_item2_label.text = "- [ ] เปิดและแก้รายงานจาก folder กลุ่ม"
				objective_item2_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
				objective_item2_label.visible = true
				
			Task2State.TYPING_REPORT:
				objective_header_label.text = "• Task 2 ทำรายงานต่อ"
				if words_typed < MAX_WORDS:
					objective_item1_label.text = "- [ ] พิมพ์ด้วย keyboard (%d/%d words)" % [words_typed, MAX_WORDS]
					objective_item1_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45, 1.0))
				else:
					objective_item1_label.text = "- [ ] กดบันทึกเอกสาร (Save)"
					objective_item1_label.add_theme_color_override("font_color", Color(0.45, 0.88, 1.0, 1.0))
				objective_item2_label.visible = false
				
			Task2State.REPORT_SAVED:
				if current_incident_state == IncidentCutsceneState.IDLE or current_incident_state == IncidentCutsceneState.PANEL_1_TYPING_TIMELAPSE:
					# Replace scene debug title with story objective
					objective_header_label.text = "• บันทึกเอกสารเรียบร้อย"
					objective_item1_label.text = "- [x] พิมพ์ด้วย keyboard 100 words"
					objective_item1_label.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5, 1.0))
					objective_item2_label.visible = false
				elif current_incident_state == IncidentCutsceneState.PANEL_2_FILES_NORMAL:
					objective_header_label.text = "• กำลังเตรียมอัปโหลดไฟล์งานกลุ่ม"
					objective_item1_label.text = "เตรียมอัปโหลดไฟล์งานกลุ่มกลับ"
					objective_item1_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0, 1.0))
					objective_item2_label.visible = false
				elif current_incident_state == IncidentCutsceneState.PANEL_3_GLITCH_LOCKING or current_incident_state == IncidentCutsceneState.PANEL_4_RANSOMWARE_NOTE:
					objective_header_label.text = "• ⚠️ ระบบถูกโจมตี"
					objective_item1_label.text = "ไฟล์ทั้งหมดถูกเข้ารหัส .locked"
					objective_item1_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
					objective_item2_label.visible = false
				elif current_incident_state == IncidentCutsceneState.PANEL_5_MARCH_SIGNAL or current_incident_state == IncidentCutsceneState.SCENE_3_COMPLETED:
					objective_header_label.text = "• 💬 ข้อความจากพี่มาร์ช"
					objective_item1_label.text = "เปิด Discord คุยกับพี่มาร์ช"
					objective_item1_label.add_theme_color_override("font_color", Color(0.4, 0.75, 1.0, 1.0))
					objective_item2_label.visible = false

	# Tight fit geometry at top-right
	objective_panel.reset_size()
	var min_size: Vector2 = objective_panel.get_combined_minimum_size()
	var target_w: float = maxf(min_size.x, 130.0)
	objective_panel.size = Vector2(target_w, min_size.y)
	objective_panel.position = Vector2(480.0 - target_w - 8.0, 7.0)

# Update Task panel objective text directly
func set_custom_objective(header: String, item1: String = "", item2: String = "") -> void:
	if not objective_header_label or not is_instance_valid(objective_header_label):
		return
	objective_header_label.text = header
	if objective_item1_label and is_instance_valid(objective_item1_label):
		objective_item1_label.text = item1
		objective_item1_label.visible = (item1 != "")
		objective_item1_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		objective_item1_label.custom_minimum_size.x = 120.0
		if item1.begins_with("- [x]"):
			objective_item1_label.add_theme_color_override("font_color", Color(0.35, 0.95, 0.5, 1.0))
		else:
			objective_item1_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0, 0.95))
	if objective_item2_label and is_instance_valid(objective_item2_label):
		objective_item2_label.text = item2
		objective_item2_label.visible = (item2 != "")
		objective_item2_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		objective_item2_label.custom_minimum_size.x = 120.0
		if item2.begins_with("- [x]"):
			objective_item2_label.add_theme_color_override("font_color", Color(0.35, 0.95, 0.5, 1.0))
		else:
			objective_item2_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0, 0.95))
	if objective_panel and is_instance_valid(objective_panel):
		objective_panel.reset_size()
		var t_w: float = 138.0
		objective_panel.custom_minimum_size.x = t_w
		objective_panel.size = Vector2(t_w, 0)
		objective_panel.position = Vector2(480.0 - t_w - 6.0, 7.0)

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
	# 1.2 Taskbar Anchor: Bottom Wide with standard height 18-20px, offset_bottom = 0
	var taskbar: PanelContainer = _find_node_safe("Taskbar") as PanelContainer
	if taskbar:
		taskbar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		taskbar.anchor_left = 0.0
		taskbar.anchor_top = 1.0
		taskbar.anchor_right = 1.0
		taskbar.anchor_bottom = 1.0
		taskbar.offset_left = 0.0
		taskbar.offset_right = 0.0
		taskbar.offset_top = -18.0
		taskbar.offset_bottom = 0.0
		taskbar.grow_horizontal = Control.GROW_DIRECTION_BOTH
		taskbar.grow_vertical = Control.GROW_DIRECTION_BEGIN
		taskbar.custom_minimum_size = Vector2(0, 18)
		taskbar.visible = true

	# Verify elements: Left Start, Right Wi-Fi, Clock (19:02 / GameState), Power
	var tray_container: Control = wifi_tray_btn.get_parent() as Control if wifi_tray_btn else null
	if tray_container and not tray_container.get_node_or_null("PhoneTrayBtn"):
		var phone_btn := Button.new()
		phone_btn.name = "PhoneTrayBtn"
		phone_btn.text = "📱"
		phone_btn.tooltip_text = "เปิดมือถือ [P]"
		phone_btn.flat = true
		phone_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		phone_btn.custom_minimum_size = Vector2(16, 14)
		phone_btn.add_theme_font_size_override("font_size", 7)
		phone_btn.pressed.connect(func(): phone_toggle_requested.emit())
		tray_container.add_child(phone_btn)
		tray_container.move_child(phone_btn, 0)
	if start_button:
		start_button.visible = true
	if wifi_tray_btn:
		wifi_tray_btn.visible = true
	if clock_label:
		var time_str: String = story_time_string
		var gs: Node = null
		if is_inside_tree() and get_tree() and get_tree().root:
			gs = get_tree().root.get_node_or_null("GameState")
		if gs and "clock" in gs:
			time_str = gs.clock
		clock_label.text = time_str
		clock_label.visible = true
	if leave_pc_button:
		leave_pc_button.visible = true
	if start_menu_popup:
		start_menu_popup.visible = false
	if wifi_popup:
		wifi_popup.visible = false
	
	# Connect taskbar buttons
	if start_button and not start_button.pressed.is_connected(_toggle_start_menu):
		start_button.pressed.connect(_toggle_start_menu)
	if wifi_tray_btn and not wifi_tray_btn.pressed.is_connected(_toggle_wifi_popup):
		wifi_tray_btn.pressed.connect(_toggle_wifi_popup)
	if wifi_toggle_btn and not wifi_toggle_btn.pressed.is_connected(_on_wifi_toggle_pressed):
		wifi_toggle_btn.pressed.connect(_on_wifi_toggle_pressed)
	if wifi_close_btn and not wifi_close_btn.pressed.is_connected(_close_wifi_popup):
		wifi_close_btn.pressed.connect(_close_wifi_popup)
	
	# Power button: leave PC and return to bedroom
	if leave_pc_button and not leave_pc_button.pressed.is_connected(_on_leave_pc_pressed):
		leave_pc_button.pressed.connect(_on_leave_pc_pressed)
	if start_menu_leave_btn and not start_menu_leave_btn.pressed.is_connected(_on_leave_pc_pressed):
		start_menu_leave_btn.pressed.connect(_on_leave_pc_pressed)
	
	# Start Menu app launchers
	if menu_gg_disk and not menu_gg_disk.pressed.is_connected(_on_app_activated.bind("gg_disk")):
		menu_gg_disk.pressed.connect(_on_app_activated.bind("gg_disk"))
	if menu_word and not menu_word.pressed.is_connected(_on_app_activated.bind("ms_word")):
		menu_word.pressed.connect(_on_app_activated.bind("ms_word"))
	if menu_files and not menu_files.pressed.is_connected(_on_app_activated.bind("files")):
		menu_files.pressed.connect(_on_app_activated.bind("files"))
	if menu_notepad and not menu_notepad.pressed.is_connected(_on_app_activated.bind("notepad")):
		menu_notepad.pressed.connect(_on_app_activated.bind("notepad"))
	if menu_discord and not menu_discord.pressed.is_connected(_on_app_activated.bind("discord")):
		menu_discord.pressed.connect(_on_app_activated.bind("discord"))
	if menu_recycle_bin and not menu_recycle_bin.pressed.is_connected(_on_app_activated.bind("recycle_bin")):
		menu_recycle_bin.pressed.connect(_on_app_activated.bind("recycle_bin"))

func _close_wifi_popup() -> void:
	if wifi_popup:
		wifi_popup.visible = false

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

func _process(delta: float) -> void:
	if current_task2_state == Task2State.TYPING_REPORT and ms_word_window and ms_word_window.visible:
		if words_typed < MAX_WORDS:
			cursor_blink_timer += delta
			if cursor_blink_timer >= 0.45:
				cursor_blink_timer = 0.0
				is_cursor_visible = !is_cursor_visible
				_refresh_word_cursor()

# Keyboard typing simulation for Word report (Tutorial 5 - Step 3)
func _unhandled_input(event: InputEvent) -> void:
	if current_task2_state == Task2State.TYPING_REPORT and ms_word_window and ms_word_window.visible:
		if event is InputEventKey and event.pressed:
			var kc: int = event.keycode
			if kc != KEY_SHIFT and kc != KEY_CTRL and kc != KEY_ALT and kc != KEY_META and kc != KEY_CAPSLOCK:
				var bonus: int = 24 if (kc == KEY_ENTER or kc == KEY_SPACE) else 14
				_advance_word_typing(bonus)
				get_viewport().set_input_as_handled()

# Sync taskbar clock to incident timeline (19:02 -> 21:25)
func _update_clock() -> void:
	if clock_label:
		var time_str: String = story_time_string
		var gs: Node = null
		if is_inside_tree() and get_tree() and get_tree().root:
			gs = get_tree().root.get_node_or_null("GameState")
		if gs and "clock" in gs:
			time_str = gs.clock
		clock_label.text = time_str

func _get_all_desktop_icons() -> Array[DesktopIcon]:
	var result: Array[DesktopIcon] = []
	if not icons_container:
		return result
	for node in icons_container.find_children("*", "DesktopIcon", true, false):
		if node is DesktopIcon:
			result.append(node)
	return result

# Connect desktop icon click and activate signals
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

# Connect DesktopWindow management events (focus, minimize, close)
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

# --- File Explorer window setup (Tutorial 5 - Step 2) ---
func _setup_files_explorer() -> void:
	if not files_window:
		return
	
	files_window.window_title = "File EXP - งานกลุ่ม"
	
	# Connect Open buttons
	if file_item_report_open_btn and not file_item_report_open_btn.pressed.is_connected(_on_report_open_btn_pressed):
		file_item_report_open_btn.pressed.connect(_on_report_open_btn_pressed)
	if file_item_readme_open_btn and not file_item_readme_open_btn.pressed.is_connected(_on_readme_open_btn_pressed):
		file_item_readme_open_btn.pressed.connect(_on_readme_open_btn_pressed)
	
	# Allow clicking on Report_Final file card row to open Word
	var file_item_1: Control = _find_node_safe("FileItem1", [files_window]) as Control
	if file_item_1 and not file_item_1.gui_input.is_connected(_on_file_item_1_gui_input):
		file_item_1.mouse_filter = Control.MOUSE_FILTER_STOP
		file_item_1.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		file_item_1.gui_input.connect(_on_file_item_1_gui_input)
	
	var file_item_2: Control = _find_node_safe("FileItem2", [files_window]) as Control
	if file_item_2 and not file_item_2.gui_input.is_connected(_on_file_item_2_gui_input):
		file_item_2.mouse_filter = Control.MOUSE_FILTER_STOP
		file_item_2.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		file_item_2.gui_input.connect(_on_file_item_2_gui_input)
	
	var file_item_3: Control = _find_node_safe("FileItem3", [files_window]) as Control
	if file_item_3 and not file_item_3.gui_input.is_connected(_on_file_item_3_gui_input):
		file_item_3.mouse_filter = Control.MOUSE_FILTER_STOP
		file_item_3.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		file_item_3.gui_input.connect(_on_file_item_3_gui_input)
	
	# Ensure Network_Diagram.png is in FilesList as File 4
	var files_list: VBoxContainer = _find_node_safe("FilesList", [files_window]) as VBoxContainer
	if files_list and not files_list.has_node("FileItem4"):
		var item4 := PanelContainer.new()
		item4.name = "FileItem4"
		file_item_4 = item4
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(0.06, 0.08, 0.13, 0.75)
		flat.border_width_left = 1
		flat.border_width_top = 1
		flat.border_width_right = 1
		flat.border_width_bottom = 1
		flat.border_color = Color(0.2, 0.32, 0.5, 0.6)
		flat.corner_radius_top_left = 2
		flat.corner_radius_top_right = 2
		flat.corner_radius_bottom_right = 2
		flat.corner_radius_bottom_left = 2
		flat.content_margin_left = 4.0
		flat.content_margin_right = 4.0
		flat.content_margin_top = 3.0
		flat.content_margin_bottom = 3.0
		item4.add_theme_stylebox_override("panel", flat)
		
		var lbl4 := Label.new()
		lbl4.name = "FileItemDiagramLabel"
		lbl4.text = "Network_Diagram.png"
		lbl4.add_theme_font_override("font", FONT_MONO)
		lbl4.add_theme_font_size_override("font_size", 7)
		lbl4.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		item4.add_child(lbl4)
		files_list.add_child(item4)
		file_item_diagram_label = lbl4
		
		item4.mouse_filter = Control.MOUSE_FILTER_STOP
		item4.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		item4.gui_input.connect(_on_file_item_4_gui_input)
	elif files_list and files_list.has_node("FileItem4"):
		file_item_4 = files_list.get_node("FileItem4") as Control
		file_item_diagram_label = file_item_4.find_child("FileItemDiagramLabel", true, false) as Label

func _on_report_open_btn_pressed() -> void:
	_on_file_item_clicked("report", file_item_report_open_btn)

func _on_readme_open_btn_pressed() -> void:
	_on_file_item_clicked("readme", file_item_readme_open_btn)

func _on_file_item_2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var file_item_2: Control = _find_node_safe("FileItem2", [files_window]) as Control
		_on_file_item_clicked("data", file_item_2)

func _on_file_item_3_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var file_item_3: Control = _find_node_safe("FileItem3", [files_window]) as Control
		_on_file_item_clicked("pres", file_item_3)

func _on_file_item_4_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_file_item_clicked("diagram", file_item_4)

func _on_file_item_1_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var file_item_1: Control = _find_node_safe("FileItem1", [files_window]) as Control
		_on_file_item_clicked("report", file_item_1)

func _on_file_item_clicked(item_id: String, item_node: Control = null) -> void:
	if is_ransomware_triggered and item_id != "readme":
		_play_sfx_error_buzzer()
		if item_node and is_instance_valid(item_node):
			var tw := create_tween()
			tw.tween_property(item_node, "modulate", Color(1.5, 0.3, 0.3, 1.0), 0.1)
			tw.tween_property(item_node, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
		_show_dialogue_toast("เมย์", "เปิดไม่ได้เลย... ทุกไฟล์กลายเป็น .locked หมดแล้ว", 2.2)
		if text_editor_window and text_editor_window.visible:
			text_editor_window.focus_window()
		return
	
	if item_id == "report":
		_on_report_file_opened()
	elif item_id == "readme":
		_on_app_activated("notepad")

# Open Report_Final.docx from group folder (Tutorial 5 - Step 2)
func _on_report_file_opened() -> void:
	is_report_opened = true
	if current_task2_state == Task2State.WAIT_FOLDER_OPEN or current_task2_state == Task2State.WAIT_GG_DOWNLOAD:
		current_task2_state = Task2State.TYPING_REPORT
	
	_play_sfx_folder_open()
	
	# Close/minimize File Explorer window
	if files_window and files_window.visible:
		files_window.minimize_window()
	
	# Open MS Word window centered
	_open_app_window(ms_word_window, "MS Word", Vector2(110, 32))
	if ms_word_window:
		ms_word_window.focus_window()
	
	_refresh_word_document_view()
	_update_objective_panel()
	task2_step_completed.emit("open_group_folder")

# --- Google Drive Setup & Resiliency (Tutorial 5 - Step 1) ---
# Clean up redundant download buttons in GG Drive
func _setup_gg_disk() -> void:
	if not gg_disk_window:
		return
	
	gg_disk_window.window_title = "Google Drive - Shared/Project/งานกลุ่ม/"
	gg_disk_window.position = Vector2(110, 45)
	
	# Tab switching
	if gg_tab_files_btn and not gg_tab_files_btn.pressed.is_connected(_show_gg_files_tab):
		gg_tab_files_btn.pressed.connect(_show_gg_files_tab)
	if gg_tab_history_btn and not gg_tab_history_btn.pressed.is_connected(_show_gg_history_tab):
		gg_tab_history_btn.pressed.connect(_show_gg_history_tab)
	
	# Hide redundant download button on FileRow1 (Report_Final.docx)
	if gg_open_word_btn and is_instance_valid(gg_open_word_btn):
		gg_open_word_btn.visible = false
	
	# Clean up file row labels so they clearly show name and size without action buttons
	var file_row_1_label: Label = _find_node_safe("Name", [gg_disk_window]) as Label
	if file_row_1_label:
		file_row_1_label.text = "📄 Report_Final.docx (1.2 MB)"
		file_row_1_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
	
	var file_row_2: Node = _find_node_safe("FileRow2", [gg_disk_window])
	if file_row_2:
		var lbl: Label = file_row_2.find_child("Label", true, false) as Label
		if lbl: lbl.text = "🖼 Network_Diagram.png (4.9 MB)"
	
	var file_row_3: Node = _find_node_safe("FileRow3", [gg_disk_window])
	if file_row_3:
		var lbl: Label = file_row_3.find_child("Label", true, false) as Label
		if lbl: lbl.text = "📊 Research_Data.xlsx (3.4 MB)"
	
	var file_row_4: Node = _find_node_safe("FileRow4", [gg_disk_window])
	if file_row_4:
		var lbl: Label = file_row_4.find_child("Label", true, false) as Label
		if lbl: lbl.text = "📊 Presentation.pptx (8.9 MB)"
	
	# Format Drive activity logs in English
	var history_label: Label = _find_node_safe("HistoryText", [gg_disk_window]) as Label
	if history_label:
		history_label.text = DRIVE_ACTIVITY_LOG
		history_label.add_theme_font_override("font", FONT_MONO)
		history_label.add_theme_font_size_override("font_size", 6)
		history_label.add_theme_color_override("font_color", Color(0.85, 0.95, 0.88, 1.0))
		# Add vertical spacing between log entries
		history_label.add_theme_constant_override("line_spacing", 7)
		
		# Add horizontal margin and padding from window edges
		var hist_style := StyleBoxEmpty.new()
		hist_style.content_margin_left = 10.0
		hist_style.content_margin_right = 10.0
		hist_style.content_margin_top = 8.0
		hist_style.content_margin_bottom = 8.0
		history_label.add_theme_stylebox_override("normal", hist_style)
	
	_build_gg_disk_ui()

func _build_gg_disk_ui() -> void:
	var gg_content: VBoxContainer = _find_node_safe("GGDiskContent", [gg_disk_window]) as VBoxContainer
	if not gg_content:
		return
	
	# Simplify GG Drive path bar without icon
	# Remove redundant action buttons from drive header
	if not gg_content.has_node("GGGreenHeader"):
		var green_header := PanelContainer.new()
		green_header.name = "GGGreenHeader"
		var green_style := StyleBoxFlat.new()
		green_style.bg_color = Color(0.1, 0.42, 0.24, 0.95)
		green_style.border_width_bottom = 1
		green_style.border_color = Color(0.25, 0.8, 0.45, 0.8)
		green_style.content_margin_left = 6.0
		green_style.content_margin_right = 6.0
		green_style.content_margin_top = 2.0
		green_style.content_margin_bottom = 2.0
		green_style.corner_radius_top_left = 2
		green_style.corner_radius_top_right = 2
		green_header.add_theme_stylebox_override("panel", green_style)
		
		# Show only pure path text without any leading icon or extra buttons
		var path_lbl := Label.new()
		path_lbl.name = "GGPathLabel"
		path_lbl.text = "Shared/Project/งานกลุ่ม/"
		path_lbl.add_theme_font_override("font", FONT_MONO)
		path_lbl.add_theme_font_size_override("font_size", 6)
		path_lbl.add_theme_color_override("font_color", Color(0.9, 1.0, 0.9, 1.0))
		path_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		path_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		green_header.add_child(path_lbl)
		
		gg_content.add_child(green_header)
		gg_content.move_child(green_header, 0)
	
	# Use compact folder icon for group project
	if gg_files_panel and not gg_files_panel.has_node("FolderRowGroup"):
		var folder_card := PanelContainer.new()
		folder_card.name = "FolderRowGroup"
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color(0.08, 0.16, 0.24, 0.9)
		card_style.border_width_left = 1
		card_style.border_width_top = 1
		card_style.border_width_right = 1
		card_style.border_width_bottom = 1
		card_style.border_color = Color(0.3, 0.6, 0.45, 0.9)
		card_style.corner_radius_top_left = 3
		card_style.corner_radius_top_right = 3
		card_style.corner_radius_bottom_right = 3
		card_style.corner_radius_bottom_left = 3
		card_style.content_margin_left = 5.0
		card_style.content_margin_right = 5.0
		card_style.content_margin_top = 3.0
		card_style.content_margin_bottom = 3.0
		folder_card.add_theme_stylebox_override("panel", card_style)
		
		var row_hbox := HBoxContainer.new()
		row_hbox.add_theme_constant_override("separation", 5)
		folder_card.add_child(row_hbox)
		
		# Compact pixel folder icon replacing the old large square icon
		var f_icon_lbl := Label.new()
		f_icon_lbl.name = "FolderIconLabel"
		f_icon_lbl.text = "📁"
		f_icon_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
		f_icon_lbl.add_theme_font_size_override("font_size", 9)
		f_icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		f_icon_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row_hbox.add_child(f_icon_lbl)
		
		var f_vbox := VBoxContainer.new()
		f_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		f_vbox.add_theme_constant_override("separation", 0)
		row_hbox.add_child(f_vbox)
		
		var f_title := Label.new()
		f_title.text = "งานกลุ่ม (CS Group Project)"
		f_title.add_theme_font_override("font", FONT_THAI_BOLD)
		f_title.add_theme_font_size_override("font_size", 7)
		f_title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
		f_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		f_vbox.add_child(f_title)
		
		var f_sub := Label.new()
		f_sub.text = "แชร์โดย mesasohot... (4 ไฟล์, 18.4 MB)"
		f_sub.add_theme_font_override("font", FONT_THAI_MEDIUM)
		f_sub.add_theme_font_size_override("font_size", 6)
		f_sub.add_theme_color_override("font_color", Color(0.65, 0.8, 0.95, 0.8))
		f_vbox.add_child(f_sub)
		
		var dl_btn := Button.new()
		dl_btn.name = "BtnDownloadGroupFolder"
		dl_btn.text = "ดาวน์โหลด"
		dl_btn.custom_minimum_size = Vector2(50, 15)
		dl_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		dl_btn.add_theme_font_override("font", FONT_THAI_MEDIUM)
		dl_btn.add_theme_font_size_override("font_size", 6)
		var dl_style := StyleBoxFlat.new()
		dl_style.bg_color = Color(0.12, 0.45, 0.25, 0.95)
		dl_style.border_width_left = 1
		dl_style.border_width_top = 1
		dl_style.border_width_right = 1
		dl_style.border_width_bottom = 1
		dl_style.border_color = Color(0.3, 0.85, 0.5, 0.9)
		dl_style.corner_radius_top_left = 2
		dl_style.corner_radius_top_right = 2
		dl_style.corner_radius_bottom_right = 2
		dl_style.corner_radius_bottom_left = 2
		dl_btn.add_theme_stylebox_override("normal", dl_style)
		dl_btn.add_theme_stylebox_override("hover", dl_style)
		dl_btn.add_theme_stylebox_override("pressed", dl_style)
		dl_btn.pressed.connect(_on_gg_download_pressed)
		row_hbox.add_child(dl_btn)
		
		gg_files_panel.add_child(folder_card)
		gg_files_panel.move_child(folder_card, 0)

# Download group folder from GG Disk (Tutorial 5 - Step 1)
func _on_gg_download_pressed() -> void:
	if is_gg_downloaded:
		return
	is_gg_downloaded = true
	current_task2_state = Task2State.WAIT_FOLDER_OPEN
	_play_sfx_download_complete()
	
	# Close GG Disk window
	if gg_disk_window and gg_disk_window.visible:
		gg_disk_window.close_window()
	
	# Unhide and animate 'งานกลุ่ม' folder icon on desktop
	if icon_files:
		icon_files.visible = true
		icon_files.modulate = Color(1.8, 1.8, 1.4, 0.0)
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(icon_files, "modulate", Color.WHITE, 0.4)
	
	_update_objective_panel()
	task2_step_completed.emit("download_gg_disk")

func _show_gg_files_tab() -> void:
	if gg_files_panel: gg_files_panel.visible = true
	if gg_history_panel: gg_history_panel.visible = false

func _show_gg_history_tab() -> void:
	if gg_files_panel: gg_files_panel.visible = false
	if gg_history_panel: gg_history_panel.visible = true

# --- MS Word Window Setup & Typing Mini-Game (Tutorial 5 - Step 3) ---
func _setup_word_window() -> void:
	if not ms_word_window:
		return
	
	ms_word_window.window_title = "Word - Report_Final.docx"
	ms_word_window.custom_minimum_size = Vector2(260, 175)
	
	if word_macro_banner and is_instance_valid(word_macro_banner):
		word_macro_banner.visible = false
	
	if enable_content_btn and not enable_content_btn.pressed.is_connected(_on_enable_content_pressed):
		enable_content_btn.pressed.connect(_on_enable_content_pressed)
	
	_build_word_ui()
	_refresh_word_document_view()

func _build_word_ui() -> void:
	var word_content: VBoxContainer = _find_node_safe("WordContent", [ms_word_window]) as VBoxContainer
	if not word_content:
		return
	
	if word_content.has_node("WordToolbar"):
		return
	
	# Toolbar (Save button, Prompt arrow, Word counter)
	var toolbar := PanelContainer.new()
	toolbar.name = "WordToolbar"
	var tb_style := StyleBoxFlat.new()
	tb_style.bg_color = Color(0.12, 0.16, 0.24, 0.95)
	tb_style.border_width_bottom = 1
	tb_style.border_color = Color(0.2, 0.3, 0.45, 0.8)
	tb_style.content_margin_left = 4.0
	tb_style.content_margin_right = 4.0
	tb_style.content_margin_top = 2.0
	tb_style.content_margin_bottom = 2.0
	toolbar.add_theme_stylebox_override("panel", tb_style)
	
	var tb_hbox := HBoxContainer.new()
	tb_hbox.add_theme_constant_override("separation", 4)
	toolbar.add_child(tb_hbox)
	
	# Green Save button
	word_save_btn = Button.new()
	word_save_btn.name = "WordSaveBtn"
	word_save_btn.text = "บันทึก (Save)"
	word_save_btn.icon = TEX_DISK_SAVE
	word_save_btn.expand_icon = true
	word_save_btn.set("theme_override_constants/icon_max_width", 12)
	word_save_btn.set("theme_override_constants/h_separation", 3)
	word_save_btn.custom_minimum_size = Vector2(70, 16)
	word_save_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	word_save_btn.add_theme_font_override("font", FONT_THAI_MEDIUM)
	word_save_btn.add_theme_font_size_override("font_size", 7)
	
	var save_style := StyleBoxFlat.new()
	save_style.bg_color = Color(0.1, 0.35, 0.2, 0.9)
	save_style.border_width_left = 1
	save_style.border_width_top = 1
	save_style.border_width_right = 1
	save_style.border_width_bottom = 1
	save_style.border_color = Color(0.3, 0.75, 0.45, 0.9)
	save_style.corner_radius_top_left = 2
	save_style.corner_radius_top_right = 2
	save_style.corner_radius_bottom_right = 2
	save_style.corner_radius_bottom_left = 2
	word_save_btn.add_theme_stylebox_override("normal", save_style)
	word_save_btn.add_theme_stylebox_override("hover", save_style)
	word_save_btn.add_theme_stylebox_override("pressed", save_style)
	word_save_btn.pressed.connect(_on_word_save_pressed)
	tb_hbox.add_child(word_save_btn)
	
	# Save prompt arrow (hidden until 100 words reached)
	word_save_prompt = Label.new()
	word_save_prompt.name = "WordSavePrompt"
	word_save_prompt.text = "⬅ กดบันทึก (Save)"
	word_save_prompt.add_theme_font_override("font", FONT_THAI_BOLD)
	word_save_prompt.add_theme_font_size_override("font_size", 7)
	word_save_prompt.add_theme_color_override("font_color", Color(1.0, 0.88, 0.2, 1.0))
	word_save_prompt.visible = false
	tb_hbox.add_child(word_save_prompt)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tb_hbox.add_child(spacer)
	
	# Word Counter Badge
	word_counter_label = Label.new()
	word_counter_label.name = "WordCounterLabel"
	word_counter_label.text = "📝 0 / 100 คำ"
	word_counter_label.add_theme_font_override("font", FONT_THAI_MEDIUM)
	word_counter_label.add_theme_font_size_override("font_size", 7)
	word_counter_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0, 0.95))
	tb_hbox.add_child(word_counter_label)
	
	word_content.add_child(toolbar)
	word_content.move_child(toolbar, 0)
	
	# White Document Paper
	word_paper_panel = PanelContainer.new()
	word_paper_panel.name = "WordPaperPanel"
	word_paper_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	word_paper_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	word_paper_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	word_paper_panel.gui_input.connect(_on_paper_gui_input)
	
	var paper_style := StyleBoxFlat.new()
	paper_style.bg_color = Color(0.97, 0.98, 1.0, 1.0)
	paper_style.border_width_left = 1
	paper_style.border_width_top = 1
	paper_style.border_width_right = 1
	paper_style.border_width_bottom = 1
	paper_style.border_color = Color(0.78, 0.82, 0.88, 1.0)
	paper_style.corner_radius_top_left = 2
	paper_style.corner_radius_top_right = 2
	paper_style.corner_radius_bottom_right = 2
	paper_style.corner_radius_bottom_left = 2
	paper_style.content_margin_left = 8.0
	paper_style.content_margin_right = 8.0
	paper_style.content_margin_top = 6.0
	paper_style.content_margin_bottom = 6.0
	paper_style.shadow_color = Color(0, 0, 0, 0.25)
	paper_style.shadow_size = 2
	word_paper_panel.add_theme_stylebox_override("panel", paper_style)
	
	var paper_vbox := VBoxContainer.new()
	paper_vbox.add_theme_constant_override("separation", 2)
	word_paper_panel.add_child(paper_vbox)
	
	var doc_title := Label.new()
	doc_title.text = "รายงาน: การป้องกันและรับมือมัลแวร์ในองค์กร"
	doc_title.add_theme_font_override("font", FONT_THAI_BOLD)
	doc_title.add_theme_font_size_override("font_size", 8)
	doc_title.add_theme_color_override("font_color", Color(0.08, 0.12, 0.22, 1.0))
	paper_vbox.add_child(doc_title)
	
	var doc_sub := Label.new()
	doc_sub.text = "ผู้จัดทำ: เมษา และ เมย์ (กลุ่ม 4 CS-KMUTT)"
	doc_sub.add_theme_font_override("font", FONT_THAI_MEDIUM)
	doc_sub.add_theme_font_size_override("font_size", 6)
	doc_sub.add_theme_color_override("font_color", Color(0.4, 0.45, 0.55, 1.0))
	paper_vbox.add_child(doc_sub)
	
	var div := HSeparator.new()
	div.add_theme_constant_override("separation", 3)
	paper_vbox.add_child(div)
	
	word_scroll_container = ScrollContainer.new()
	word_scroll_container.name = "WordScrollContainer"
	word_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	word_scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	# Pixel-minimal vertical scrollbar
	var v_bar := word_scroll_container.get_v_scroll_bar()
	if v_bar:
		v_bar.custom_minimum_size.x = 3.0
		var sb_grabber := StyleBoxFlat.new()
		sb_grabber.bg_color = Color(0.4, 0.5, 0.65, 0.6)
		sb_grabber.corner_radius_top_left = 1
		sb_grabber.corner_radius_top_right = 1
		sb_grabber.corner_radius_bottom_right = 1
		sb_grabber.corner_radius_bottom_left = 1
		v_bar.add_theme_stylebox_override("grabber", sb_grabber)
		v_bar.add_theme_stylebox_override("grabber_highlight", sb_grabber)
		v_bar.add_theme_stylebox_override("grabber_pressed", sb_grabber)
		var sb_scroll := StyleBoxFlat.new()
		sb_scroll.bg_color = Color(0.9, 0.92, 0.96, 0.4)
		v_bar.add_theme_stylebox_override("scroll", sb_scroll)
	paper_vbox.add_child(word_scroll_container)
	
	word_body_label = Label.new()
	word_body_label.name = "WordBodyLabel"
	word_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	word_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_body_label.add_theme_font_override("font", FONT_THAI_MEDIUM)
	word_body_label.add_theme_font_size_override("font_size", 6)
	word_body_label.add_theme_color_override("font_color", Color(0.15, 0.18, 0.24, 1.0))
	word_body_label.text = "[ กดพิมพ์บนแป้นพิมพ์เพื่อเขียนรายงานต่อ... ]"
	word_scroll_container.add_child(word_body_label)
	
	var hint_lbl := Label.new()
	hint_lbl.text = "[ ⌨ พิมพ์บนแป้นพิมพ์ หรือคลิกที่หน้ากระดาษเพื่อเขียนรายงาน ]"
	hint_lbl.add_theme_font_override("font", FONT_THAI_MEDIUM)
	hint_lbl.add_theme_font_size_override("font_size", 5)
	hint_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65, 0.75))
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	paper_vbox.add_child(hint_lbl)
	
	# Hide legacy Scroll & status label if present
	var legacy_scroll: Node = _find_node_safe("Scroll", [ms_word_window])
	if legacy_scroll and legacy_scroll != word_scroll_container and legacy_scroll is Control:
		(legacy_scroll as Control).visible = false
	var legacy_status: Node = _find_node_safe("WordDocStatus", [ms_word_window])
	if legacy_status and legacy_status is Control:
		(legacy_status as Control).visible = false
	
	word_content.add_child(word_paper_panel)

func _on_paper_gui_input(event: InputEvent) -> void:
	if current_task2_state == Task2State.TYPING_REPORT and ms_word_window and ms_word_window.visible:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_advance_word_typing(18)

func _count_words(text: String) -> int:
	var count: int = 0
	for line in text.split("\n"):
		for token in line.split(" "):
			if token.strip_edges().length() > 0:
				count += 1
	return mini(count, MAX_WORDS)

# Simulate typewriter text reveal on keystroke
func _advance_word_typing(step: int = 14) -> void:
	if words_typed >= MAX_WORDS:
		return
	
	_play_sfx_typewriter()
	is_cursor_visible = true
	cursor_blink_timer = 0.0
	
	target_char_count = mini(target_char_count + step, REPORT_FULL_TEXT.length())
	
	if typing_tween and typing_tween.is_valid():
		typing_tween.kill()
	
	var chars_left: int = target_char_count - typed_char_count
	var duration: float = clampf(float(chars_left) * 0.01, 0.03, 0.14)
	
	typing_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	typing_tween.tween_method(_on_typing_tween_step, typed_char_count, target_char_count, duration)

func _on_typing_tween_step(val: Variant) -> void:
	typed_char_count = int(val)
	_refresh_word_document_view()

func _refresh_word_cursor() -> void:
	if not word_body_label or words_typed >= MAX_WORDS:
		return
	if typed_char_count <= 0:
		word_body_label.text = "[ กดพิมพ์บนแป้นพิมพ์เพื่อเขียนรายงานต่อ... ]" + (" _" if is_cursor_visible else "")
	else:
		var current_text: String = REPORT_FULL_TEXT.substr(0, typed_char_count)
		word_body_label.text = current_text + (" _" if is_cursor_visible else "")

func _refresh_word_document_view() -> void:
	if not word_body_label:
		return
	
	# Keep typed_char_count in sync if words_typed was set externally (e.g. tests)
	if words_typed >= MAX_WORDS and typed_char_count < REPORT_FULL_TEXT.length():
		typed_char_count = REPORT_FULL_TEXT.length()
	
	if typed_char_count <= 0:
		word_body_label.add_theme_color_override("font_color", Color(0.45, 0.5, 0.6, 0.8))
		word_body_label.text = "[ กดพิมพ์บนแป้นพิมพ์เพื่อเขียนรายงานต่อ... ]" + (" _" if is_cursor_visible else "")
		words_typed = 0
	else:
		word_body_label.add_theme_color_override("font_color", Color(0.12, 0.15, 0.2, 1.0))
		var current_text: String = REPORT_FULL_TEXT.substr(0, typed_char_count)
		words_typed = _count_words(current_text)
		
		if words_typed >= MAX_WORDS or typed_char_count >= REPORT_FULL_TEXT.length():
			words_typed = MAX_WORDS
			word_body_label.text = current_text
		else:
			word_body_label.text = current_text + (" _" if is_cursor_visible else "")
	
	# Update Word window counter badge
	if word_counter_label:
		if words_typed >= MAX_WORDS:
			word_counter_label.text = "📝 100 / 100 คำ (ครบแล้ว)"
			word_counter_label.add_theme_color_override("font_color", Color(0.35, 0.9, 0.45, 1.0))
		else:
			word_counter_label.text = "📝 %d / 100 คำ" % words_typed
			word_counter_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0, 0.95))
	
	# Update top-right task objective
	_update_objective_panel()
	
	# Smooth auto-scroll to active typing line
	_auto_scroll_word_to_bottom()
	
	# Enable save button upon reaching 100 words
	if words_typed >= MAX_WORDS:
		_trigger_save_prompt()

func _update_word_document_view() -> void:
	_refresh_word_document_view()

# Smooth auto-scroll to active typing line
func _auto_scroll_word_to_bottom() -> void:
	if not word_scroll_container or not is_inside_tree():
		return
	_do_smooth_scroll.call_deferred()

func _do_smooth_scroll() -> void:
	if not word_scroll_container or not is_inside_tree():
		return
	var v_bar := word_scroll_container.get_v_scroll_bar()
	if not v_bar:
		return
	var max_scroll: int = int(v_bar.max_value - v_bar.page)
	if max_scroll <= 0 or word_scroll_container.scroll_vertical >= max_scroll:
		return
	
	if word_scroll_tween and word_scroll_tween.is_valid():
		word_scroll_tween.kill()
	word_scroll_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	word_scroll_tween.tween_property(word_scroll_container, "scroll_vertical", max_scroll, 0.22)

# Enable save button upon reaching 100 words
func _trigger_save_prompt() -> void:
	is_cursor_visible = false
	if word_save_prompt:
		word_save_prompt.visible = true
	if word_save_btn:
		if word_save_tween and word_save_tween.is_valid():
			word_save_tween.kill()
		word_save_tween = create_tween().set_loops()
		word_save_tween.tween_property(word_save_btn, "modulate", Color(0.35, 1.5, 0.6, 1.0), 0.45)
		word_save_tween.tween_property(word_save_btn, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.45)

# Word Save Action
func _on_word_save_pressed() -> void:
	if current_task2_state == Task2State.REPORT_SAVED:
		return
	if words_typed < MAX_WORDS:
		if word_counter_label:
			word_counter_label.text = "⚠️ พิมพ์ให้ครบ 100 คำก่อน (%d/100)" % words_typed
			var tw := create_tween()
			tw.tween_interval(1.2)
			tw.tween_callback(_reset_word_counter_label)
		return
	
	is_report_saved = true
	current_task2_state = Task2State.REPORT_SAVED
	_play_sfx_save_complete()
	
	if word_save_tween and word_save_tween.is_valid():
		word_save_tween.kill()
	if word_save_btn:
		word_save_btn.modulate = Color.WHITE
		word_save_btn.text = "✔ บันทึกแล้ว"
		word_save_btn.add_theme_color_override("font_color", Color(0.35, 0.9, 0.45, 1.0))
	if word_save_prompt:
		word_save_prompt.visible = false
	
	_update_objective_panel()
	report_saved.emit()
	task2_step_completed.emit("report_saved")
	scene_2_completed.emit()
	
	# Transition to Scene 3 Incident Cutscene
	if not is_standalone_scene_3:
		if has_node("/root/SceneRouter"):
			SceneRouter.goto_scene_3_incident()
			return
		elif ResourceLoader.exists("res://Scenes/Scene_03_Incident.tscn"):
			get_tree().change_scene_to_file("res://Scenes/Scene_03_Incident.tscn")
			return
	
	# Fallback if running standalone or within same scene
	_start_incident_cutscene()

# Direct launch for Scene 3 Incident Cutscene standalone mode
func start_incident_cutscene_direct() -> void:
	is_standalone_scene_3 = true
	if gg_disk_window and is_instance_valid(gg_disk_window):
		gg_disk_window.close_window()
	if ms_word_window and is_instance_valid(ms_word_window):
		ms_word_window.close_window()
	is_report_saved = true
	words_typed = MAX_WORDS
	typed_char_count = REPORT_FULL_TEXT.length()
	current_task2_state = Task2State.REPORT_SAVED
	_start_incident_cutscene()

func _reset_word_counter_label() -> void:
	if word_counter_label:
		word_counter_label.text = "📝 %d / 100 คำ" % words_typed

func _on_enable_content_pressed() -> void:
	if not is_standalone_scene_3:
		if has_node("/root/SceneRouter"):
			SceneRouter.goto_scene_3_incident()
			return
		elif ResourceLoader.exists("res://Scenes/Scene_03_Incident.tscn"):
			get_tree().change_scene_to_file("res://Scenes/Scene_03_Incident.tscn")
			return
	_start_incident_cutscene()

# Configure desktop for Scene 4 Investigation mode
func setup_scene_4_investigation_mode() -> void:
	is_standalone_scene_3 = false
	is_incident_cutscene_running = false
	is_ransomware_triggered = true
	is_report_saved = true
	words_typed = MAX_WORDS
	typed_char_count = REPORT_FULL_TEXT.length()
	current_task2_state = Task2State.REPORT_SAVED
	current_incident_state = IncidentCutsceneState.SCENE_3_COMPLETED
	story_time_string = "21:25"
	_update_clock()
	
	# Close Word & Google Drive
	if ms_word_window and is_instance_valid(ms_word_window):
		ms_word_window.close_window()
	if gg_disk_window and is_instance_valid(gg_disk_window):
		gg_disk_window.close_window()
	
	# Show locked files in group folder
	_update_file_status_ui()
	_open_app_window(files_window, "งานกลุ่ม", Vector2(115, 38))
	
	# Open Notepad with ransomware README
	_update_notepad_content()
	_open_app_window(text_editor_window, "Notepad - README", Vector2(125, 48))
	
	# Clean start March chat without old 20:20 messages and without desktop Discord badge
	if chat_log_march and is_instance_valid(chat_log_march):
		chat_log_march.text = "[Direct Message - M4rchupikchu_inw101]"
		if chat_scroll_march and is_instance_valid(chat_scroll_march):
			_scroll_to_bottom(chat_scroll_march)
	
	set_custom_objective("• ติดต่อขอความช่วยเหลือจากพี่มาร์ช", "- [ ] ตอบแชตพี่มาร์ช (กด [P])")

# Setup Notepad text editor (Normal vs Ransomware mode)
func _setup_text_editor() -> void:
	if not text_editor_window:
		return
	_update_notepad_content()

# Lock ransomware note behind incident trigger
func _update_notepad_content() -> void:
	if not text_editor_window:
		return
	
	if is_ransomware_triggered:
		text_editor_window.window_title = "Notepad - README_TO_RECOVER_FILES.txt"
		text_editor_window.custom_minimum_size = Vector2(220, 145)
		text_editor_window.size = Vector2(220, 145)
		if notepad_alert_banner:
			notepad_alert_banner.visible = true
			notepad_alert_banner.text = "⚠️ YOUR FILES HAVE BEEN ENCRYPTED! ⚠️"
			notepad_alert_banner.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
		if notepad_body_text:
			notepad_body_text.add_theme_font_override("font", FONT_MONO)
			notepad_body_text.add_theme_font_size_override("font_size", 5)
			notepad_body_text.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
			notepad_body_text.text = """====================================================
           YOUR FILES HAVE BEEN ENCRYPTED!          
====================================================

DO NOT MODIFY OR DELETE FILES.
WAIT FOR FURTHER INSTRUCTIONS.

All personal files on this system:
  - Report_Final.docx
  - Network_Diagram.png
  - Research_Data.xlsx
  - Presentation.pptx

have been locked with AES-256 + RSA-4096 encryption.
Contact ransomware operator to recover your data.
===================================================="""
	else:
		text_editor_window.window_title = "Notepad - ToDo.txt"
		if notepad_alert_banner:
			notepad_alert_banner.visible = false
		if notepad_body_text:
			notepad_body_text.add_theme_font_override("font", FONT_THAI_MEDIUM)
			notepad_body_text.add_theme_font_size_override("font_size", 6)
			notepad_body_text.add_theme_color_override("font_color", Color(0.88, 0.92, 0.98, 0.95))
			notepad_body_text.text = "[ บันทึกเตือนความจำของเมย์ ]\n\n- โหลดงานจาก GG Disk มาทำต่อให้เสร็จ\n- ตรวจสอบไฟล์รายงานวิชา Cybersecurity\n- ส่งรายงานก่อนเที่ยงคืนวันนี้!\n- เคลียร์ฮาร์ดดิสก์ คอมเริ่มช้าแล้ว"

# --- Discord Window Setup ---
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
	
	# Show casual past chat for March in phase 1
	if chat_log_march:
		chat_log_march.text = CHAT_MARCH_PHASE1
		chat_log_march.add_theme_font_override("font", FONT_THAI_MEDIUM)
		chat_log_march.add_theme_font_size_override("font_size", 6)
	if chat_log_mesa:
		chat_log_mesa.add_theme_font_override("font", FONT_THAI_MEDIUM)
		chat_log_mesa.add_theme_font_size_override("font_size", 6)
	
	_select_discord_chat(_current_discord_channel)

# Switch Discord chat tab and clear unread badge
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
		# Dismiss notification badge once user clicks March's chat
		if march_notif_badge and is_instance_valid(march_notif_badge):
			march_notif_badge.visible = false
			_show_discord_desktop_badge(false)
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

# App launcher router
func _on_app_activated(app_id: String) -> void:
	if start_menu_popup:
		start_menu_popup.visible = false
	if wifi_popup:
		wifi_popup.visible = false
	match app_id:
		"gg_disk":
			_open_app_window(gg_disk_window, "GG Disk", Vector2(110, 45))
		"ms_word":
			_open_app_window(ms_word_window, "MS Word", Vector2(110, 32))
			if current_task2_state == Task2State.WAIT_FOLDER_OPEN:
				_on_report_file_opened()
		"files":
			_open_app_window(files_window, "งานกลุ่ม", Vector2(115, 38))
		"notepad":
			_update_notepad_content()
			var win_title: String = "Notepad - README" if is_ransomware_triggered else "Notepad - ToDo.txt"
			_open_app_window(text_editor_window, win_title, Vector2(130, 48))
		"discord":
			_open_app_window(discord_window, "Discord", Vector2(125, 46))
			_select_discord_chat(_current_discord_channel)
			_show_discord_desktop_badge(false)
			# Minimize Notepad to taskbar when Discord is opened
			if text_editor_window and is_instance_valid(text_editor_window) and text_editor_window.visible:
				text_editor_window.minimize_window()
		"recycle_bin":
			_open_app_window(recycle_bin_window, "Trash", Vector2(140, 60))
		_:
			print("[Desktop] Unknown app id: ", app_id)

# Open window and register taskbar tab
func _open_app_window(win: DesktopWindow, tab_title: String, default_pos: Vector2 = Vector2(125, 45)) -> void:
	if not win:
		return
	if not win.visible:
		win.position = default_pos
	win.open_window()
	_update_taskbar_tab(win, tab_title, true)
	_highlight_active_tab(win)

# Sync taskbar tabs with open/closed windows
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
		
		new_tab.pressed.connect(_on_taskbar_tab_pressed.bind(win))
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

func _on_taskbar_tab_pressed(win: DesktopWindow) -> void:
	if not win or not is_instance_valid(win):
		return
	if win.visible:
		var is_top: bool = (win.get_index() == window_container.get_child_count() - 1)
		if is_top:
			win.minimize_window()
		else:
			win.focus_window()
	else:
		win.open_window()

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

# Power button / Leave PC: return to bedroom
func _on_leave_pc_pressed() -> void:
	if has_node("/root/SceneRouter"):
		SceneRouter.goto_scene_2_tutorial()
	elif ResourceLoader.exists(BEDROOM_SCENE_PATH):
		get_tree().change_scene_to_file(BEDROOM_SCENE_PATH)
	else:
		push_error("Bedroom scene not found: " + BEDROOM_SCENE_PATH)

# Ransomware trigger: Macro executes, locks files, advances clock to 21:25
func trigger_macro_infection() -> void:
	if is_ransomware_triggered or is_incident_cutscene_running:
		return
	_start_incident_cutscene()

# Update File Explorer items (.locked file extensions)
func _update_file_status_ui() -> void:
	if is_ransomware_triggered:
		if file_item_report_label and is_instance_valid(file_item_report_label):
			file_item_report_label.text = "Report_Final.docx.locked"
			file_item_report_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
		if file_item_diagram_label and is_instance_valid(file_item_diagram_label):
			file_item_diagram_label.text = "Network_Diagram.png.locked"
			file_item_diagram_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
		if file_item_data_label and is_instance_valid(file_item_data_label):
			file_item_data_label.text = "Research_Data.xlsx.locked"
			file_item_data_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
		if file_item_pres_label and is_instance_valid(file_item_pres_label):
			file_item_pres_label.text = "Presentation.pptx.locked"
			file_item_pres_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
		if file_item_readme and is_instance_valid(file_item_readme):
			file_item_readme.visible = true
	else:
		if file_item_report_label and is_instance_valid(file_item_report_label):
			file_item_report_label.text = "Report_Final.docx"
			file_item_report_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		if file_item_diagram_label and is_instance_valid(file_item_diagram_label):
			file_item_diagram_label.text = "Network_Diagram.png"
			file_item_diagram_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		if file_item_data_label and is_instance_valid(file_item_data_label):
			file_item_data_label.text = "Research_Data.xlsx"
			file_item_data_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		if file_item_pres_label and is_instance_valid(file_item_pres_label):
			file_item_pres_label.text = "Presentation.pptx"
			file_item_pres_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		if file_item_readme and is_instance_valid(file_item_readme):
			file_item_readme.visible = false

# --- Scene 3 Cutscene UI Setup & Helpers ---
func _setup_incident_cutscene_ui() -> void:
	if not dialogue_toast_panel:
		dialogue_toast_panel = PanelContainer.new()
		dialogue_toast_panel.name = "DialogueToastPanel"
		dialogue_toast_panel.visible = false
		dialogue_toast_panel.modulate.a = 0.0
		dialogue_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Prevent dialogue box from overlapping bottom-right popups
		dialogue_toast_panel.custom_minimum_size = Vector2(250, 44)
		dialogue_toast_panel.size = Vector2(250, 44)
		dialogue_toast_panel.position = Vector2(16, 202)
		dialogue_toast_panel.z_index = 40
		
		var box_style := StyleBoxFlat.new()
		box_style.bg_color = Color(0.06, 0.09, 0.16, 0.94)
		box_style.border_width_left = 1
		box_style.border_width_top = 1
		box_style.border_width_right = 1
		box_style.border_width_bottom = 1
		box_style.border_color = Color(0.87, 0.72, 0.53, 0.85)
		box_style.corner_radius_top_left = 3
		box_style.corner_radius_top_right = 3
		box_style.corner_radius_bottom_right = 3
		box_style.corner_radius_bottom_left = 3
		box_style.content_margin_left = 8.0
		box_style.content_margin_right = 8.0
		box_style.content_margin_top = 4.0
		box_style.content_margin_bottom = 4.0
		dialogue_toast_panel.add_theme_stylebox_override("panel", box_style)
		
		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 1)
		dialogue_toast_panel.add_child(vbox)
		
		dialogue_toast_speaker = Label.new()
		dialogue_toast_speaker.name = "SpeakerLabel"
		dialogue_toast_speaker.add_theme_font_override("font", FONT_THAI_BOLD)
		dialogue_toast_speaker.add_theme_font_size_override("font_size", 7)
		dialogue_toast_speaker.add_theme_color_override("font_color", Color(0.95, 0.8, 0.5, 1.0))
		vbox.add_child(dialogue_toast_speaker)
		
		dialogue_toast_text = Label.new()
		dialogue_toast_text.name = "ContentLabel"
		dialogue_toast_text.add_theme_font_override("font", FONT_THAI_MEDIUM)
		dialogue_toast_text.add_theme_font_size_override("font_size", 7)
		dialogue_toast_text.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
		dialogue_toast_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(dialogue_toast_text)
		
		add_child(dialogue_toast_panel)
	
	if not notif_stack_container:
		notif_stack_container = VBoxContainer.new()
		notif_stack_container.name = "NotificationStackContainer"
		notif_stack_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Position popups above taskbar on bottom-right, clear of dialogue
		notif_stack_container.position = Vector2(285, 138)
		notif_stack_container.size = Vector2(185, 108)
		notif_stack_container.alignment = BoxContainer.ALIGNMENT_END
		notif_stack_container.add_theme_constant_override("separation", 3)
		notif_stack_container.z_index = 45
		add_child(notif_stack_container)
	
	if not glitch_overlay:
		glitch_overlay = ColorRect.new()
		glitch_overlay.name = "GlitchOverlay"
		glitch_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		glitch_overlay.color = Color(0, 0, 0, 0)
		glitch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glitch_overlay.visible = false
		glitch_overlay.z_index = 50
		add_child(glitch_overlay)

# Prevent dialogue box from overlapping bottom-right popups
func _show_dialogue_toast(speaker: String, text: String, hold_duration: float = 1.5) -> void:
	if not dialogue_toast_panel:
		return
	dialogue_toast_speaker.text = "[ " + speaker + " ]"
	dialogue_toast_text.text = text
	dialogue_toast_panel.visible = true
	dialogue_toast_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	
	if dialogue_toast_tween and dialogue_toast_tween.is_valid():
		dialogue_toast_tween.kill()
	dialogue_toast_tween = create_tween()
	dialogue_toast_tween.tween_property(dialogue_toast_panel, "modulate:a", 1.0, 0.15)
	dialogue_toast_tween.tween_interval(hold_duration)
	# Fade out dialogue box after monologue ends
	dialogue_toast_tween.tween_property(dialogue_toast_panel, "modulate:a", 0.0, 0.3)
	dialogue_toast_tween.tween_callback(func() -> void:
		if dialogue_toast_panel:
			dialogue_toast_panel.visible = false
			dialogue_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)

func _spawn_toast_popup(title: String, subtitle: String, accent_color: Color, icon_char: String, lifespan: float = 2.5) -> PanelContainer:
	_play_sfx_popup()
	var popup := PanelContainer.new()
	popup.mouse_filter = Control.MOUSE_FILTER_PASS
	var p_style := StyleBoxFlat.new()
	p_style.bg_color = Color(0.08, 0.11, 0.18, 0.96)
	p_style.border_width_left = 2
	p_style.border_width_top = 1
	p_style.border_width_right = 1
	p_style.border_width_bottom = 1
	p_style.border_color = accent_color
	p_style.corner_radius_top_left = 3
	p_style.corner_radius_top_right = 3
	p_style.corner_radius_bottom_right = 3
	p_style.corner_radius_bottom_left = 3
	p_style.content_margin_left = 5.0
	p_style.content_margin_right = 5.0
	p_style.content_margin_top = 2.0
	p_style.content_margin_bottom = 2.0
	popup.add_theme_stylebox_override("panel", p_style)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	popup.add_child(hbox)
	
	var icon_lbl := Label.new()
	icon_lbl.text = icon_char
	icon_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	icon_lbl.add_theme_font_size_override("font_size", 9)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_lbl)
	
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 0)
	hbox.add_child(vbox)
	
	var title_lbl := Label.new()
	title_lbl.text = title
	title_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	title_lbl.add_theme_font_size_override("font_size", 6)
	title_lbl.add_theme_color_override("font_color", accent_color)
	vbox.add_child(title_lbl)
	
	var sub_lbl := Label.new()
	sub_lbl.text = subtitle
	sub_lbl.add_theme_font_override("font", FONT_THAI_MEDIUM)
	sub_lbl.add_theme_font_size_override("font_size", 5)
	sub_lbl.add_theme_color_override("font_color", Color(0.9, 0.92, 0.98, 0.9))
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(sub_lbl)
	
	popup.modulate.a = 0.0
	if notif_stack_container:
		notif_stack_container.add_child(popup)
	
	var tw := create_tween()
	tw.tween_property(popup, "modulate:a", 1.0, 0.15)
	tw.tween_interval(lifespan)
	tw.tween_property(popup, "modulate:a", 0.0, 0.3)
	tw.tween_callback(popup.queue_free)
	return popup

func _spawn_discord_preview_popup(sender: String, message: String) -> void:
	_play_sfx_chat_ding()
	var popup := PanelContainer.new()
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	popup.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var p_style := StyleBoxFlat.new()
	p_style.bg_color = Color(0.1, 0.13, 0.24, 0.98)
	p_style.border_width_left = 2
	p_style.border_width_top = 1
	p_style.border_width_right = 1
	p_style.border_width_bottom = 1
	p_style.border_color = Color(0.45, 0.6, 1.0, 1.0)
	p_style.corner_radius_top_left = 3
	p_style.corner_radius_top_right = 3
	p_style.corner_radius_bottom_right = 3
	p_style.corner_radius_bottom_left = 3
	p_style.content_margin_left = 5.0
	p_style.content_margin_right = 5.0
	p_style.content_margin_top = 3.0
	p_style.content_margin_bottom = 3.0
	popup.add_theme_stylebox_override("panel", p_style)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	popup.add_child(hbox)
	
	var icon_lbl := Label.new()
	icon_lbl.text = "💬"
	icon_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	icon_lbl.add_theme_font_size_override("font_size", 9)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_lbl)
	
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 0)
	hbox.add_child(vbox)
	
	var title_lbl := Label.new()
	title_lbl.text = sender + " • 21:25"
	title_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	title_lbl.add_theme_font_size_override("font_size", 6)
	title_lbl.add_theme_color_override("font_color", Color(0.45, 0.75, 1.0, 1.0))
	vbox.add_child(title_lbl)
	
	var msg_lbl := Label.new()
	msg_lbl.text = message
	msg_lbl.add_theme_font_override("font", FONT_THAI_MEDIUM)
	msg_lbl.add_theme_font_size_override("font_size", 6)
	msg_lbl.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(msg_lbl)
	
	popup.gui_input.connect(_on_discord_preview_popup_gui_input.bind(popup))
	
	popup.modulate.a = 0.0
	if notif_stack_container:
		notif_stack_container.add_child(popup)
	var tw := create_tween()
	tw.tween_property(popup, "modulate:a", 1.0, 0.15)
	tw.tween_interval(6.0)
	tw.tween_property(popup, "modulate:a", 0.0, 0.3)
	tw.tween_callback(popup.queue_free)

func _on_discord_preview_popup_gui_input(event: InputEvent, popup: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_open_app_window(discord_window, "Discord", Vector2(125, 46))
		_select_discord_chat("march")
		_show_discord_desktop_badge(false)
		# Minimize Notepad to taskbar when Discord preview is opened
		if text_editor_window and is_instance_valid(text_editor_window) and text_editor_window.visible:
			text_editor_window.minimize_window()
		if is_instance_valid(popup):
			popup.queue_free()

func _show_discord_desktop_badge(_show_badge: bool) -> void:
	# Disabled on desktop icon per UI guidelines (notifications shown on mobile only)
	if discord_desktop_badge and is_instance_valid(discord_desktop_badge):
		discord_desktop_badge.visible = false

func _play_screen_glitch(duration: float = 0.5) -> void:
	_play_sfx_glitch()
	if glitch_overlay:
		glitch_overlay.visible = true
	var orig_pos: Vector2 = Vector2.ZERO
	if window_container:
		orig_pos = window_container.position
	
	var tw := create_tween()
	var steps: int = int(duration / 0.05)
	for i in range(steps):
		tw.tween_callback(func() -> void:
			if glitch_overlay:
				var r_col := randi() % 3
				if r_col == 0: glitch_overlay.color = Color(1.0, 0.2, 0.2, 0.35)
				elif r_col == 1: glitch_overlay.color = Color(0.1, 0.8, 1.0, 0.3)
				else: glitch_overlay.color = Color(0.1, 0.1, 0.1, 0.5)
			if window_container:
				window_container.position = orig_pos + Vector2(randf_range(-3.0, 3.0), randf_range(-2.0, 2.0))
		)
		tw.tween_interval(0.05)
	
	tw.tween_callback(func() -> void:
		if glitch_overlay:
			glitch_overlay.color = Color(0, 0, 0, 0)
			glitch_overlay.visible = false
		if window_container:
			window_container.position = orig_pos
	)

# --- Scene 3: Incident Cutscene Orchestration (21:21 - 21:25) ---
func _start_incident_cutscene() -> void:
	if is_incident_cutscene_running or is_ransomware_triggered:
		return
	is_incident_cutscene_running = true
	scene_3_cutscene_started.emit()
	_panel_1_timelapse_and_popups()

# Panel 1: Save report & trigger timelapse popups
func _panel_1_timelapse_and_popups() -> void:
	current_incident_state = IncidentCutsceneState.PANEL_1_TYPING_TIMELAPSE
	_update_objective_panel()
	
	# Timelapse clock: 19:02 -> 21:21 -> 21:22
	var tw := create_tween()
	tw.tween_interval(0.3)
	tw.tween_callback(func() -> void:
		story_time_string = "21:21"
		_update_clock()
	)
	tw.tween_interval(0.4)
	tw.tween_callback(func() -> void:
		story_time_string = "21:22"
		_update_clock()
		_show_dialogue_toast("เมย์ (ในใจ)", "ใกล้เสร็จแล้ว... เหลือแค่จัดรูปแบบกับอัปโหลดกลับก็จบแล้ว!", 1.5)
	)
	
	# Staggered popups in bottom-right corner
	tw.tween_interval(0.3)
	tw.tween_callback(func() -> void:
		_spawn_toast_popup("NEWS ข่าวด่วน !", "อากาศร้อนจัด อุณหภูมิสูงแตะ 40 องศาอีกครั้ง", Color(1.0, 0.45, 0.2), "📰", 2.6)
	)
	tw.tween_interval(0.5)
	tw.tween_callback(func() -> void:
		_spawn_toast_popup("Browser Update", "มีอัปเดตโปรแกรมเวอร์ชันใหม่ คลิกเพื่ออัปเดต", Color(0.3, 0.65, 1.0), "🌐", 2.6)
	)
	tw.tween_interval(0.5)
	tw.tween_callback(func() -> void:
		_spawn_toast_popup("Security Center", "ไม่พบภัยคุกคาม เครื่องของคุณปลอดภัย", Color(0.35, 0.85, 0.45), "🛡️", 2.6)
	)
	
	# Close MS Word window automatically
	tw.tween_interval(1.2)
	tw.tween_callback(func() -> void:
		if ms_word_window and ms_word_window.visible:
			ms_word_window.close_window()
	)
	
	tw.tween_interval(1.0)
	tw.tween_callback(func() -> void:
		_panel_2_show_clean_folder()
	)

# Panel 2: Open folder and display clean files
func _panel_2_show_clean_folder() -> void:
	current_incident_state = IncidentCutsceneState.PANEL_2_FILES_NORMAL
	_update_objective_panel()
	
	# Ensure clean folder view
	_update_file_status_ui()
	_open_app_window(files_window, "งานกลุ่ม", Vector2(115, 38))
	if files_window:
		files_window.focus_window()
	
	_show_dialogue_toast("เมย์", "เหลือแค่ upload files กลับก็เสร็จแล้ว~", 2.4)
	
	var tw := create_tween()
	tw.tween_interval(2.2)
	tw.tween_callback(func() -> void:
		_panel_3_glitch_and_locking()
	)

# Panel 2-3: Glitch screen and append .locked extension
func _panel_3_glitch_and_locking() -> void:
	current_incident_state = IncidentCutsceneState.PANEL_3_GLITCH_LOCKING
	story_time_string = "21:23"
	_update_clock()
	_update_objective_panel()
	
	_play_screen_glitch(0.55)
	
	var tw := create_tween()
	tw.tween_interval(0.6)
	
	# Animate files locking sequentially one by one
	tw.tween_callback(func() -> void:
		if file_item_report_label:
			file_item_report_label.text = "Report_Final.docx.locked"
			file_item_report_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
			_play_sfx_typewriter()
	)
	tw.tween_interval(0.35)
	tw.tween_callback(func() -> void:
		if file_item_diagram_label:
			file_item_diagram_label.text = "Network_Diagram.png.locked"
			file_item_diagram_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
			_play_sfx_typewriter()
	)
	tw.tween_interval(0.35)
	tw.tween_callback(func() -> void:
		if file_item_data_label:
			file_item_data_label.text = "Research_Data.xlsx.locked"
			file_item_data_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
			_play_sfx_typewriter()
	)
	tw.tween_interval(0.35)
	tw.tween_callback(func() -> void:
		if file_item_pres_label:
			file_item_pres_label.text = "Presentation.pptx.locked"
			file_item_pres_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
			_play_sfx_typewriter()
		if file_item_readme:
			file_item_readme.visible = true
		is_ransomware_triggered = true
		_update_wifi_ui()
	)
	tw.tween_interval(0.8)
	tw.tween_callback(func() -> void:
		_panel_4_ransomware_note()
	)

# Panel 4: Auto-pop Ransomware README.txt
func _panel_4_ransomware_note() -> void:
	current_incident_state = IncidentCutsceneState.PANEL_4_RANSOMWARE_NOTE
	_update_objective_panel()
	
	_play_sfx_ransomware_alert()
	_update_notepad_content()
	_open_app_window(text_editor_window, "Notepad - README", Vector2(115, 36))
	if text_editor_window:
		text_editor_window.focus_window()
	
	_show_dialogue_toast("เมย์", "ท่าทางรายงานที่ฉันทำ จะปลอดภัยจริงๆ ...จากตัวฉันด้วย", 3.2)
	
	var tw := create_tween()
	tw.tween_interval(3.5)
	tw.tween_callback(func() -> void:
		_show_dialogue_toast("เมย์", "ท่าทางฉันคงต้องหาคนช่วย...", 2.2)
	)
	tw.tween_interval(2.5)
	tw.tween_callback(func() -> void:
		_panel_5_march_signal()
	)

# Panel 5: March Discord message at 21:25
func _panel_5_march_signal() -> void:
	current_incident_state = IncidentCutsceneState.PANEL_5_MARCH_SIGNAL
	story_time_string = "21:25"
	_update_clock()
	
	# Discord notification chime and badges
	_play_sfx_chat_ding()
	_show_discord_desktop_badge(true)
	if march_notif_badge and is_instance_valid(march_notif_badge):
		march_notif_badge.visible = true
	
	# Unlock post-incident chat in March Discord channel
	if chat_log_march and is_instance_valid(chat_log_march):
		chat_log_march.text = CHAT_MARCH_PHASE1 + CHAT_MARCH_POST_INCIDENT
		if chat_scroll_march and is_instance_valid(chat_scroll_march):
			_scroll_to_bottom(chat_scroll_march)
	
	# Spawn clickable Discord preview pop-up
	_spawn_discord_preview_popup("M4rchupikchu_inw101 (พี่มาร์ช)", "\"Roblox ป่าวน้อง\"")
	
	_show_dialogue_toast("เมย์", "ทักมาได้จังหวะเหมาะมาก!", 3.0)
	
	# Standby for Scene 4: Investigation Intro
	current_incident_state = IncidentCutsceneState.SCENE_3_COMPLETED
	is_incident_cutscene_running = false
	_update_objective_panel()
	scene_3_cutscene_completed.emit()
