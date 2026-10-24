class_name InvestigationScreen extends Control

## Scene 4: investigation_screen (Time: 21:25 onwards)
## Step 1: Sequential chat via Mobile Phone ([P] key only)
## Step 2: Compact incoming phone call from March cutscene (Ringtone, answer, dialogue, hangup)
## Step 3: Enter Task 3: หาสาเหตุ (Desktop Event Viewer double-click)

signal scene_4_started
signal chat_message_sent(sender: String, message: String)
signal incoming_call_started
signal phone_call_answered
signal phone_call_ended
signal event_log_opened
signal event_log_completed(timestamp: String)

# Preloaded fonts and assets
const FONT_THAI_BOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")
const FONT_THAI_MEDIUM: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Medium.ttf")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")
const PUZZLE_EVENT_LOG_SCENE: PackedScene = preload("res://Scenes/Puzzle_Event_Log.tscn")
const DESKTOP_WINDOW_SCENE: PackedScene = preload("res://Scenes/desktop/DesktopWindow.tscn")
const DESKTOP_ICON_SCENE: PackedScene = preload("res://Scenes/desktop/DesktopIcon.tscn")
const ICON_COMPUTER: Texture2D = preload("res://assets/Icon32x32/computer.png")

# Chat progression state machine
enum ChatPhase {
	IDLE,
	MARCH_1_WAIT,        # 21:25 | Typing indicator before "Roblox ป่าวน้อง"
	MAY_1_INPUT,         # 21:26 | Waiting for May: "พี่มาร์ชคะ คอมเปิดไฟล์ไม่ได้ค่ะ"
	MARCH_2_WAIT,        # 21:28 | Typing indicator before "ไฟล์อะไร"
	MAY_2_INPUT,         # 21:28 | Waiting for May: "ไฟล์ docx แล้ว .locked ค่ะ"
	MARCH_3_WAIT,        # 21:28 | Typing indicator before "ยังไงนะ ถ่ายรูปมาหน่อย"
	MAY_3_SCREENSHOT,    # 21:29 | Waiting for May 1-click screenshot button
	MARCH_4_WAIT,        # 21:30 | Typing indicator before "อืมม ตัดเน็ตคอมพิวเตอร์ก่อน"
	CHAT_COMPLETED,      # Chat done, ready for incoming call
	CALL_RINGING,        # Looping telephone ringtone & call screen
	CALL_CONNECTED,      # Active conversation dialogue with March
	TASK_3_EVENT_LOG     # Task 3 active, inspecting Event Log
}

@onready var desktop: Control = $Desktop

# Audio players for SFX and Ringtone loop
var sfx_player: AudioStreamPlayer
var ringtone_player: AudioStreamPlayer

# UI Layer & Mobile Phone Components
var ui_layer: CanvasLayer
var phone_dimmer: ColorRect
var phone_modal: PanelContainer
var phone_time_lbl: Label
var phone_chat_container: VBoxContainer
var phone_chat_scroll: ScrollContainer
var phone_messages_vbox: VBoxContainer
var phone_typing_indicator: PanelContainer
var phone_typing_label: Label
var phone_input_panel: PanelContainer
var phone_input_line: LineEdit
var phone_send_btn: Button
var phone_screenshot_btn: Button

# Phone Call Screen Components (Compact Fit)
var phone_call_container: VBoxContainer
var call_status_lbl: Label
var call_timer_lbl: Label
var call_dialogue_vbox: VBoxContainer
var call_decline_btn: Button
var call_answer_btn: Button
var call_hangup_btn: Button

# Event Viewer Desktop Components
var investigation_window: DesktopWindow
var event_viewer_icon: DesktopIcon

# State tracking variables
var current_phase: ChatPhase = ChatPhase.IDLE
var is_phone_open: bool = false
var is_event_log_done: bool = false
var game_state_node: Node = null
var call_seconds: int = 0
var call_timer_tween: Tween

# Setup Scene 4 on enter tree
func _ready() -> void:
	scene_4_started.emit()
	_setup_game_state()
	_setup_audio_players()
	_setup_ui_layer()
	_setup_phone_modal()
	_setup_desktop_environment()
	_setup_event_viewer_window()
	
	# Start dialogue sequence after brief opening delay
	var tw := create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(_start_chat_step_1_march)

# Sync with GameState singleton or create persistent root instance
func _setup_game_state() -> void:
	if is_inside_tree() and get_tree().root:
		game_state_node = get_tree().root.get_node_or_null("GameState")
		if not game_state_node:
			game_state_node = Node.new()
			game_state_node.name = "GameState"
			game_state_node.set("clock", "21:25")
			get_tree().root.call_deferred("add_child", game_state_node)
		else:
			game_state_node.set("clock", "21:25")

# Update clock across GameState, Taskbar, and Phone
func _update_game_time(time_str: String) -> void:
	if game_state_node and is_instance_valid(game_state_node):
		game_state_node.set("clock", time_str)
	if desktop and desktop.has_method("_update_clock"):
		desktop.set("story_time_string", time_str)
		desktop._update_clock()
	if phone_time_lbl and is_instance_valid(phone_time_lbl):
		phone_time_lbl.text = " %s" % time_str

# Setup standalone procedural audio players
func _setup_audio_players() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)
	
	ringtone_player = AudioStreamPlayer.new()
	ringtone_player.name = "RingtonePlayer"
	add_child(ringtone_player)

# Synthesize dual-frequency looping telephone ringtone
func _play_phone_ringtone() -> void:
	var sample_rate: int = 22050
	var dur: float = 2.4
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		# 1.1 second ring tone, 1.3 second silence
		if t < 1.1:
			var wave: float = (sin(2.0 * PI * 440.0 * t) * 0.5) + (sin(2.0 * PI * 480.0 * t) * 0.5)
			var env: float = sin(PI * (t / 1.1))
			data[i] = int(clampf(128.0 + (wave * env * 48.0), 0.0, 255.0))
		else:
			data[i] = 128
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = sample_count
	wav.data = data
	ringtone_player.stream = wav
	ringtone_player.play()

# Stop looping telephone ringtone
func _stop_phone_ringtone() -> void:
	if ringtone_player and ringtone_player.playing:
		ringtone_player.stop()

# Synthesize chat ding notification chime
func _play_sfx_chat_ding() -> void:
	if not sfx_player:
		return
	var sample_rate: int = 22050
	var dur: float = 0.35
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var decay: float = exp(-t * 8.0)
		var freq: float = 659.25 if t < 0.12 else 783.99
		var wave: float = sin(2.0 * PI * freq * t)
		data[i] = int(clampf(128.0 + (wave * decay * 45.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

# Synthesize camera shutter screenshot click
func _play_sfx_camera_click() -> void:
	if not sfx_player:
		return
	var sample_rate: int = 22050
	var dur: float = 0.22
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var noise: float = ((randf() * 2.0) - 1.0) * exp(-t * 30.0)
		var tone: float = sin(2.0 * PI * 587.33 * t) * exp(-t * 12.0)
		var combined: float = (noise * 0.7) + (tone * 0.3)
		data[i] = int(clampf(128.0 + (combined * 60.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

# Synthesize call end disconnect beeps
func _play_sfx_call_end() -> void:
	if not sfx_player:
		return
	var sample_rate: int = 22050
	var dur: float = 0.6
	var sample_count: int = int(sample_rate * dur)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var is_beep: bool = (t < 0.12) or (t > 0.20 and t < 0.32) or (t > 0.40 and t < 0.52)
		if is_beep:
			var wave: float = sin(2.0 * PI * 425.0 * t)
			data[i] = int(clampf(128.0 + (wave * 40.0), 0.0, 255.0))
		else:
			data[i] = 128
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

# Setup CanvasLayer for phone modal and alerts
func _setup_ui_layer() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "Scene4UILayer"
	ui_layer.layer = 10
	add_child(ui_layer)
	
	# Background dimmer overlay
	phone_dimmer = ColorRect.new()
	phone_dimmer.name = "PhoneDimmer"
	phone_dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	phone_dimmer.color = Color(0.0, 0.0, 0.0, 0.45)
	phone_dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	phone_dimmer.visible = false
	phone_dimmer.gui_input.connect(_on_dimmer_gui_input)
	ui_layer.add_child(phone_dimmer)

# Build simulated smartphone modal chassis (compact dimensions fitting 480x270 viewport)
func _setup_phone_modal() -> void:
	phone_modal = PanelContainer.new()
	phone_modal.name = "PhoneModal"
	phone_modal.clip_contents = true
	phone_modal.custom_minimum_size = Vector2(164, 226)
	phone_modal.size = Vector2(164, 226)
	phone_modal.position = Vector2(158, 12)
	phone_modal.visible = false
	
	var phone_style := StyleBoxFlat.new()
	phone_style.bg_color = Color(0.07, 0.09, 0.14, 0.98)
	phone_style.border_width_left = 2
	phone_style.border_width_top = 2
	phone_style.border_width_right = 2
	phone_style.border_width_bottom = 2
	phone_style.border_color = Color(0.35, 0.45, 0.60, 1.0)
	phone_style.corner_radius_top_left = 10
	phone_style.corner_radius_top_right = 10
	phone_style.corner_radius_bottom_right = 10
	phone_style.corner_radius_bottom_left = 10
	phone_style.content_margin_left = 4.0
	phone_style.content_margin_right = 4.0
	phone_style.content_margin_top = 3.0
	phone_style.content_margin_bottom = 3.0
	phone_modal.add_theme_stylebox_override("panel", phone_style)
	ui_layer.add_child(phone_modal)
	
	var phone_main_vbox := VBoxContainer.new()
	phone_main_vbox.add_theme_constant_override("separation", 2)
	phone_modal.add_child(phone_main_vbox)
	
	# Status bar (Clock & battery)
	var status_bar := HBoxContainer.new()
	status_bar.custom_minimum_size.y = 11
	phone_main_vbox.add_child(status_bar)
	
	phone_time_lbl = Label.new()
	phone_time_lbl.text = " 21:25"
	phone_time_lbl.add_theme_font_override("font", FONT_MONO)
	phone_time_lbl.add_theme_font_size_override("font_size", 6)
	phone_time_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95, 0.9))
	status_bar.add_child(phone_time_lbl)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_bar.add_child(spacer)
	
	var battery_lbl := Label.new()
	battery_lbl.text = "📶 100% "
	battery_lbl.add_theme_font_override("font", FONT_MONO)
	battery_lbl.add_theme_font_size_override("font_size", 6)
	battery_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95, 0.9))
	status_bar.add_child(battery_lbl)
	
	# Header with March contact info
	var header_panel := PanelContainer.new()
	var h_style := StyleBoxFlat.new()
	h_style.bg_color = Color(0.12, 0.16, 0.25, 0.95)
	h_style.border_width_bottom = 1
	h_style.border_color = Color(0.28, 0.35, 0.48, 0.8)
	h_style.content_margin_left = 4.0
	h_style.content_margin_right = 4.0
	h_style.content_margin_top = 2.0
	h_style.content_margin_bottom = 2.0
	header_panel.add_theme_stylebox_override("panel", h_style)
	phone_main_vbox.add_child(header_panel)
	
	var contact_hbox := HBoxContainer.new()
	contact_hbox.add_theme_constant_override("separation", 5)
	header_panel.add_child(contact_hbox)
	
	# March avatar thumbnail
	var av_frame := PanelContainer.new()
	av_frame.custom_minimum_size = Vector2(18, 18)
	var av_style := StyleBoxFlat.new()
	av_style.bg_color = Color(0.25, 0.45, 0.75, 1.0)
	av_style.corner_radius_top_left = 9
	av_style.corner_radius_top_right = 9
	av_style.corner_radius_bottom_right = 9
	av_style.corner_radius_bottom_left = 9
	av_frame.add_theme_stylebox_override("panel", av_style)
	contact_hbox.add_child(av_frame)
	
	var av_icon := Label.new()
	av_icon.text = "👤"
	av_icon.add_theme_font_size_override("font_size", 8)
	av_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	av_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	av_frame.add_child(av_icon)
	
	var name_vbox := VBoxContainer.new()
	name_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_vbox.add_theme_constant_override("separation", 0)
	contact_hbox.add_child(name_vbox)
	
	var contact_name := Label.new()
	contact_name.text = "พี่มาร์ช"
	contact_name.add_theme_font_override("font", FONT_THAI_BOLD)
	contact_name.add_theme_font_size_override("font_size", 7)
	name_vbox.add_child(contact_name)
	
	var contact_sub := Label.new()
	contact_sub.text = "M4rchupikchu_inw101"
	contact_sub.add_theme_font_override("font", FONT_MONO)
	contact_sub.add_theme_font_size_override("font_size", 5)
	contact_sub.add_theme_color_override("font_color", Color(0.65, 0.78, 0.92, 0.8))
	name_vbox.add_child(contact_sub)
	
	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(14, 14)
	close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_btn.add_theme_font_size_override("font_size", 6)
	close_btn.pressed.connect(_close_phone)
	contact_hbox.add_child(close_btn)
	
	# Chat message view container
	phone_chat_container = VBoxContainer.new()
	phone_chat_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phone_main_vbox.add_child(phone_chat_container)
	
	phone_chat_scroll = ScrollContainer.new()
	phone_chat_scroll.custom_minimum_size.y = 146
	phone_chat_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phone_chat_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	phone_chat_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_style_slim_scrollbar(phone_chat_scroll)
	phone_chat_container.add_child(phone_chat_scroll)
	
	# Adjust right padding for message bubbles
	var chat_margin := MarginContainer.new()
	chat_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chat_margin.add_theme_constant_override("margin_left", 2)
	chat_margin.add_theme_constant_override("margin_right", 5)
	chat_margin.add_theme_constant_override("margin_top", 2)
	chat_margin.add_theme_constant_override("margin_bottom", 2)
	phone_chat_scroll.add_child(chat_margin)
	
	phone_messages_vbox = VBoxContainer.new()
	phone_messages_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phone_messages_vbox.add_theme_constant_override("separation", 3)
	chat_margin.add_child(phone_messages_vbox)
	
	var today_label := Label.new()
	today_label.text = "— วันนี้ (Today) —"
	today_label.add_theme_font_override("font", FONT_THAI_MEDIUM)
	today_label.add_theme_font_size_override("font_size", 5)
	today_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8, 0.7))
	today_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phone_messages_vbox.add_child(today_label)
	
	# Typing indicator bubble on phone
	phone_typing_indicator = PanelContainer.new()
	var type_style := StyleBoxFlat.new()
	type_style.bg_color = Color(0.15, 0.20, 0.30, 0.9)
	type_style.corner_radius_top_left = 6
	type_style.corner_radius_top_right = 6
	type_style.corner_radius_bottom_right = 6
	type_style.corner_radius_bottom_left = 6
	type_style.content_margin_left = 6.0
	type_style.content_margin_right = 6.0
	type_style.content_margin_top = 2.0
	type_style.content_margin_bottom = 2.0
	phone_typing_indicator.add_theme_stylebox_override("panel", type_style)
	phone_typing_indicator.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	phone_typing_indicator.visible = false
	
	phone_typing_label = Label.new()
	phone_typing_label.text = "พี่มาร์ชกำลังพิมพ์..."
	phone_typing_label.add_theme_font_override("font", FONT_THAI_MEDIUM)
	phone_typing_label.add_theme_font_size_override("font_size", 6)
	phone_typing_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0, 0.9))
	phone_typing_indicator.add_child(phone_typing_label)
	phone_messages_vbox.add_child(phone_typing_indicator)
	
	# Bottom input panel on mobile phone
	phone_input_panel = PanelContainer.new()
	var in_style := StyleBoxFlat.new()
	in_style.bg_color = Color(0.10, 0.13, 0.20, 0.95)
	in_style.border_width_top = 1
	in_style.border_color = Color(0.25, 0.32, 0.45, 0.8)
	in_style.corner_radius_bottom_left = 8
	in_style.corner_radius_bottom_right = 8
	in_style.content_margin_left = 4.0
	in_style.content_margin_right = 4.0
	in_style.content_margin_top = 2.0
	in_style.content_margin_bottom = 2.0
	phone_input_panel.add_theme_stylebox_override("panel", in_style)
	phone_chat_container.add_child(phone_input_panel)
	
	var input_hbox := HBoxContainer.new()
	input_hbox.add_theme_constant_override("separation", 3)
	phone_input_panel.add_child(input_hbox)
	
	phone_input_line = LineEdit.new()
	phone_input_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phone_input_line.custom_minimum_size.y = 15
	phone_input_line.add_theme_font_override("font", FONT_THAI_MEDIUM)
	phone_input_line.add_theme_font_size_override("font_size", 6)
	phone_input_line.placeholder_text = "พิมพ์ข้อความ..."
	phone_input_line.text_submitted.connect(_on_phone_send_pressed)
	input_hbox.add_child(phone_input_line)
	
	phone_send_btn = Button.new()
	phone_send_btn.text = "ส่ง"
	phone_send_btn.custom_minimum_size = Vector2(24, 15)
	phone_send_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	phone_send_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	phone_send_btn.add_theme_font_size_override("font_size", 6)
	phone_send_btn.pressed.connect(_on_phone_send_pressed.bind(""))
	input_hbox.add_child(phone_send_btn)
	
	phone_screenshot_btn = Button.new()
	phone_screenshot_btn.text = "📷 ส่งรูปหลักฐาน"
	phone_screenshot_btn.custom_minimum_size = Vector2(90, 15)
	phone_screenshot_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	phone_screenshot_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	phone_screenshot_btn.add_theme_font_size_override("font_size", 6)
	phone_screenshot_btn.visible = false
	phone_screenshot_btn.pressed.connect(_on_screenshot_sent)
	input_hbox.add_child(phone_screenshot_btn)
	
	# Construct compact Phone Call UI Screen Container
	_setup_phone_call_screen(phone_main_vbox)

# Compact incoming call and in-call screen container (Single language 'พี่มาร์ช', fits cleanly in mobile frame)
func _setup_phone_call_screen(parent: VBoxContainer) -> void:
	phone_call_container = VBoxContainer.new()
	phone_call_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phone_call_container.add_theme_constant_override("separation", 3)
	phone_call_container.visible = false
	parent.add_child(phone_call_container)
	
	var top_gap := Control.new()
	top_gap.custom_minimum_size.y = 4
	phone_call_container.add_child(top_gap)
	
	# Compact Avatar circle (No redundant English text)
	var call_avatar_frame := PanelContainer.new()
	call_avatar_frame.custom_minimum_size = Vector2(28, 28)
	call_avatar_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var c_av_style := StyleBoxFlat.new()
	c_av_style.bg_color = Color(0.20, 0.40, 0.75, 1.0)
	c_av_style.border_width_left = 1
	c_av_style.border_width_top = 1
	c_av_style.border_width_right = 1
	c_av_style.border_width_bottom = 1
	c_av_style.border_color = Color(0.5, 0.75, 1.0, 1.0)
	c_av_style.corner_radius_top_left = 14
	c_av_style.corner_radius_top_right = 14
	c_av_style.corner_radius_bottom_right = 14
	c_av_style.corner_radius_bottom_left = 14
	call_avatar_frame.add_theme_stylebox_override("panel", c_av_style)
	phone_call_container.add_child(call_avatar_frame)
	
	var call_avatar_icon := Label.new()
	call_avatar_icon.text = "📞"
	call_avatar_icon.add_theme_font_size_override("font_size", 9)
	call_avatar_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	call_avatar_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	call_avatar_frame.add_child(call_avatar_icon)
	
	# Unified single-language caller title
	var caller_name := Label.new()
	caller_name.text = "พี่มาร์ช"
	caller_name.add_theme_font_override("font", FONT_THAI_BOLD)
	caller_name.add_theme_font_size_override("font_size", 8)
	caller_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phone_call_container.add_child(caller_name)
	
	call_status_lbl = Label.new()
	call_status_lbl.text = "กำลังโทรเข้า..."
	call_status_lbl.add_theme_font_override("font", FONT_THAI_MEDIUM)
	call_status_lbl.add_theme_font_size_override("font_size", 6)
	call_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.85, 1.0, 0.9))
	call_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phone_call_container.add_child(call_status_lbl)
	
	call_timer_lbl = Label.new()
	call_timer_lbl.text = "● 00:00"
	call_timer_lbl.add_theme_font_override("font", FONT_MONO)
	call_timer_lbl.add_theme_font_size_override("font_size", 6)
	call_timer_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5, 0.9))
	call_timer_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	call_timer_lbl.visible = false
	phone_call_container.add_child(call_timer_lbl)
	
	# Compact Conversation dialogue container (Scrollable to prevent overflow)
	var dialogue_scroll := ScrollContainer.new()
	dialogue_scroll.custom_minimum_size = Vector2(0, 58)
	dialogue_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_style_slim_scrollbar(dialogue_scroll)
	phone_call_container.add_child(dialogue_scroll)
	
	call_dialogue_vbox = VBoxContainer.new()
	call_dialogue_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	call_dialogue_vbox.add_theme_constant_override("separation", 2)
	dialogue_scroll.add_child(call_dialogue_vbox)
	
	# Action buttons for incoming call
	var call_btns_hbox := HBoxContainer.new()
	call_btns_hbox.add_theme_constant_override("separation", 6)
	call_btns_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	phone_call_container.add_child(call_btns_hbox)
	
	var dec_style := StyleBoxFlat.new()
	dec_style.bg_color = Color(0.8, 0.2, 0.2, 0.95)
	dec_style.corner_radius_top_left = 8
	dec_style.corner_radius_top_right = 8
	dec_style.corner_radius_bottom_right = 8
	dec_style.corner_radius_bottom_left = 8
	
	call_decline_btn = Button.new()
	call_decline_btn.text = "📵 ปฏิเสธ"
	call_decline_btn.custom_minimum_size = Vector2(58, 16)
	call_decline_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	call_decline_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	call_decline_btn.add_theme_font_size_override("font_size", 6)
	call_decline_btn.add_theme_stylebox_override("normal", dec_style)
	call_decline_btn.pressed.connect(_on_call_declined)
	call_btns_hbox.add_child(call_decline_btn)
	
	var ans_style := StyleBoxFlat.new()
	ans_style.bg_color = Color(0.18, 0.72, 0.32, 0.95)
	ans_style.corner_radius_top_left = 8
	ans_style.corner_radius_top_right = 8
	ans_style.corner_radius_bottom_right = 8
	ans_style.corner_radius_bottom_left = 8
	
	call_answer_btn = Button.new()
	call_answer_btn.text = "📞 รับสาย"
	call_answer_btn.custom_minimum_size = Vector2(58, 16)
	call_answer_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	call_answer_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	call_answer_btn.add_theme_font_size_override("font_size", 6)
	call_answer_btn.add_theme_stylebox_override("normal", ans_style)
	call_answer_btn.pressed.connect(_on_call_answered)
	call_btns_hbox.add_child(call_answer_btn)
	
	# Prominent red hangup button (Fits comfortably inside mobile screen)
	call_hangup_btn = Button.new()
	call_hangup_btn.text = "📴 วางสาย"
	call_hangup_btn.custom_minimum_size = Vector2(84, 16)
	call_hangup_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	call_hangup_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	call_hangup_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	call_hangup_btn.add_theme_font_size_override("font_size", 6)
	call_hangup_btn.add_theme_stylebox_override("normal", dec_style)
	call_hangup_btn.visible = false
	call_hangup_btn.pressed.connect(_on_call_hangup_pressed)
	phone_call_container.add_child(call_hangup_btn)

# Configure desktop for Scene 4 post-ransomware environment
func _setup_desktop_environment() -> void:
	if desktop:
		if desktop.has_method("setup_scene_4_investigation_mode"):
			desktop.setup_scene_4_investigation_mode()
		if desktop.has_signal("phone_toggle_requested"):
			desktop.phone_toggle_requested.connect(_toggle_phone)
		# Update objective text restricted to mobile phone ([P] key)
		_set_task_objective("• ติดต่อขอความช่วยเหลือจากพี่มาร์ช", "- [ ] ตอบแชตพี่มาร์ช (กด [P])")

# Update objective text on desktop task panel
func _set_task_objective(header: String, item1: String = "", item2: String = "") -> void:
	if desktop and desktop.has_method("set_custom_objective"):
		desktop.set_custom_objective(header, item1, item2)

# Toggle mobile phone modal display
func _toggle_phone() -> void:
	if is_phone_open:
		_close_phone()
	else:
		_open_phone()

# Open simulated smartphone modal
func _open_phone() -> void:
	if is_phone_open:
		return
	is_phone_open = true
	if phone_dimmer:
		phone_dimmer.visible = true
		phone_dimmer.modulate.a = 0.0
		var dt := create_tween()
		dt.tween_property(phone_dimmer, "modulate:a", 1.0, 0.15)
	if phone_modal:
		phone_modal.visible = true
		phone_modal.position = Vector2(158, 12)
		phone_modal.custom_minimum_size = Vector2(164, 226)
		phone_modal.size = Vector2(164, 226)
		phone_modal.scale = Vector2(0.94, 0.94)
		var mt := create_tween()
		mt.tween_property(phone_modal, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_scroll_phone_to_bottom()

# Close simulated smartphone modal
func _close_phone() -> void:
	if not is_phone_open:
		return
	is_phone_open = false
	if phone_modal:
		phone_modal.visible = false
	if phone_dimmer:
		phone_dimmer.visible = false

# Close phone when clicking dimmer outside phone bounds
func _on_dimmer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_phase != ChatPhase.CALL_RINGING and current_phase != ChatPhase.CALL_CONNECTED:
			_close_phone()

# Handle global keyboard shortcuts: [P] toggle phone, [ESC] close phone
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P:
			_toggle_phone()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and is_phone_open:
			_close_phone()
			get_viewport().set_input_as_handled()
		elif OS.is_debug_build() and event.keycode == KEY_F10:
			_developer_skip_step()
			get_viewport().set_input_as_handled()

# Style a slim, faint, minimalist scrollbar without heavy dark track
func _style_slim_scrollbar(scroll: ScrollContainer) -> void:
	if not scroll:
		return
	var v_bar: VScrollBar = scroll.get_v_scroll_bar()
	if not v_bar:
		return
	
	v_bar.custom_minimum_size.x = 3.0
	
	# Transparent track: removes the wide opaque black background track
	var empty_track := StyleBoxEmpty.new()
	v_bar.add_theme_stylebox_override("scroll", empty_track)
	v_bar.add_theme_stylebox_override("scroll_focus", empty_track)
	
	# Faint, thin translucent grabber (subtle pixel-art aesthetic)
	var grabber_normal := StyleBoxFlat.new()
	grabber_normal.bg_color = Color(0.7, 0.8, 0.95, 0.22)
	grabber_normal.corner_radius_top_left = 2
	grabber_normal.corner_radius_top_right = 2
	grabber_normal.corner_radius_bottom_right = 2
	grabber_normal.corner_radius_bottom_left = 2
	grabber_normal.content_margin_left = 1.0
	grabber_normal.content_margin_right = 1.0
	v_bar.add_theme_stylebox_override("grabber", grabber_normal)
	
	var grabber_hover := StyleBoxFlat.new()
	grabber_hover.bg_color = Color(0.85, 0.95, 1.0, 0.45)
	grabber_hover.corner_radius_top_left = 2
	grabber_hover.corner_radius_top_right = 2
	grabber_hover.corner_radius_bottom_right = 2
	grabber_hover.corner_radius_bottom_left = 2
	grabber_hover.content_margin_left = 1.0
	grabber_hover.content_margin_right = 1.0
	v_bar.add_theme_stylebox_override("grabber_highlight", grabber_hover)
	v_bar.add_theme_stylebox_override("grabber_pressed", grabber_hover)

# Scroll mobile phone message list to latest entry
func _scroll_phone_to_bottom() -> void:
	if not phone_chat_scroll or not is_inside_tree():
		return
	await get_tree().process_frame
	if phone_chat_scroll and is_instance_valid(phone_chat_scroll):
		var v_bar: VScrollBar = phone_chat_scroll.get_v_scroll_bar()
		if v_bar:
			v_bar.value = v_bar.max_value

# Add a speech bubble to mobile phone chat view
func _add_phone_bubble(sender: String, message: String, timestamp: String, is_may: bool) -> void:
	if not phone_messages_vbox:
		return
	
	var bubble := PanelContainer.new()
	var b_style := StyleBoxFlat.new()
	if is_may:
		b_style.bg_color = Color(0.12, 0.32, 0.58, 0.95)
		b_style.border_color = Color(0.25, 0.55, 0.85, 0.9)
		bubble.size_flags_horizontal = Control.SIZE_SHRINK_END
	else:
		b_style.bg_color = Color(0.15, 0.18, 0.26, 0.95)
		b_style.border_color = Color(0.28, 0.36, 0.50, 0.9)
		bubble.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	
	b_style.border_width_left = 1
	b_style.border_width_top = 1
	b_style.border_width_right = 1
	b_style.border_width_bottom = 1
	b_style.corner_radius_top_left = 6
	b_style.corner_radius_top_right = 6
	b_style.corner_radius_bottom_right = 6
	b_style.corner_radius_bottom_left = 6
	b_style.content_margin_left = 5.0
	b_style.content_margin_right = 5.0
	b_style.content_margin_top = 2.0
	b_style.content_margin_bottom = 2.0
	bubble.add_theme_stylebox_override("panel", b_style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	bubble.add_child(vbox)
	
	var header_lbl := Label.new()
	header_lbl.text = "%s • %s" % [sender, timestamp]
	header_lbl.add_theme_font_override("font", FONT_THAI_MEDIUM)
	header_lbl.add_theme_font_size_override("font_size", 5)
	header_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.75))
	vbox.add_child(header_lbl)
	
	var text_lbl := Label.new()
	text_lbl.text = message
	text_lbl.add_theme_font_override("font", FONT_THAI_MEDIUM)
	text_lbl.add_theme_font_size_override("font_size", 6)
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(text_lbl)
	
	var insert_idx: int = max(0, phone_messages_vbox.get_child_count() - 1)
	phone_messages_vbox.add_child(bubble)
	phone_messages_vbox.move_child(bubble, insert_idx)
	_scroll_phone_to_bottom()

# Add screenshot image preview card to mobile phone chat view
func _add_phone_screenshot_card(timestamp: String) -> void:
	if not phone_messages_vbox:
		return
	
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_SHRINK_END
	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color(0.10, 0.28, 0.50, 0.98)
	c_style.border_width_left = 1
	c_style.border_width_top = 1
	c_style.border_width_right = 1
	c_style.border_width_bottom = 1
	c_style.border_color = Color(0.35, 0.65, 0.95, 1.0)
	c_style.corner_radius_top_left = 6
	c_style.corner_radius_top_right = 6
	c_style.corner_radius_bottom_right = 6
	c_style.corner_radius_bottom_left = 6
	c_style.content_margin_left = 5.0
	c_style.content_margin_right = 5.0
	c_style.content_margin_top = 3.0
	c_style.content_margin_bottom = 3.0
	card.add_theme_stylebox_override("panel", c_style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	card.add_child(vbox)
	
	var header := Label.new()
	header.text = "Mayicomeinpls • %s" % timestamp
	header.add_theme_font_override("font", FONT_THAI_MEDIUM)
	header.add_theme_font_size_override("font_size", 5)
	header.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0, 0.8))
	vbox.add_child(header)
	
	var thumb_box := PanelContainer.new()
	thumb_box.custom_minimum_size = Vector2(100, 32)
	var t_style := StyleBoxFlat.new()
	t_style.bg_color = Color(0.05, 0.08, 0.14, 0.9)
	t_style.corner_radius_top_left = 3
	t_style.corner_radius_top_right = 3
	t_style.corner_radius_bottom_right = 3
	t_style.corner_radius_bottom_left = 3
	thumb_box.add_theme_stylebox_override("panel", t_style)
	vbox.add_child(thumb_box)
	
	var thumb_lbl := Label.new()
	thumb_lbl.text = "🖼️ [Screenshot]\nReport_Final.docx.locked\nResearch_Data.xlsx.locked"
	thumb_lbl.add_theme_font_override("font", FONT_THAI_MEDIUM)
	thumb_lbl.add_theme_font_size_override("font_size", 5)
	thumb_lbl.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4, 0.95))
	thumb_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thumb_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	thumb_box.add_child(thumb_lbl)
	
	var insert_idx: int = max(0, phone_messages_vbox.get_child_count() - 1)
	phone_messages_vbox.add_child(card)
	phone_messages_vbox.move_child(card, insert_idx)
	_scroll_phone_to_bottom()

# Post message to mobile phone and sync log to read-only desktop Discord
func _post_synced_message(sender: String, message: String, timestamp: String, is_may: bool, is_screenshot: bool = false) -> void:
	if is_screenshot:
		_add_phone_screenshot_card(timestamp)
	else:
		_add_phone_bubble(sender, message, timestamp, is_may)
	
	# Keep read-only Discord log mirror on desktop
	if desktop and desktop.has_method("add_discord_message"):
		var discord_msg_text: String = message
		if is_screenshot:
			discord_msg_text = "[📷 แนบรูปภาพหน้าจอ: ไฟล์งานกลุ่มทั้งหมดนามสกุล .locked]"
		desktop.add_discord_message("march", sender, discord_msg_text, timestamp)
	
	chat_message_sent.emit(sender, message)

# Show or hide typing indicators on mobile phone
func _set_typing_indicators(visible_state: bool) -> void:
	if phone_typing_indicator and is_instance_valid(phone_typing_indicator):
		phone_typing_indicator.visible = visible_state
		if visible_state:
			_scroll_phone_to_bottom()

# Set prefilled text and button visibility for May's reply on mobile phone
func _set_may_input_prefilled(prefilled_text: String, is_screenshot_mode: bool = false) -> void:
	if phone_input_line:
		phone_input_line.text = prefilled_text if not is_screenshot_mode else ""
		phone_input_line.editable = not is_screenshot_mode
		phone_input_line.visible = not is_screenshot_mode
	if phone_send_btn:
		phone_send_btn.visible = not is_screenshot_mode
		phone_send_btn.disabled = false
	if phone_screenshot_btn:
		phone_screenshot_btn.visible = is_screenshot_mode

# Disable input fields while awaiting March's response
func _clear_and_disable_inputs() -> void:
	if phone_input_line:
		phone_input_line.text = ""
		phone_input_line.editable = false
	if phone_send_btn:
		phone_send_btn.disabled = true
	if phone_screenshot_btn:
		phone_screenshot_btn.visible = false

# --- Beat-by-Beat Chat Sequence Implementation (Exclusively on Mobile Phone) ---

# Beat 1: March at 21:25 - "Roblox ป่าวน้อง"
func _start_chat_step_1_march() -> void:
	current_phase = ChatPhase.MARCH_1_WAIT
	_update_game_time("21:25")
	_set_typing_indicators(true)
	
	var tw := create_tween()
	tw.tween_interval(1.5)
	tw.tween_callback(func() -> void:
		_set_typing_indicators(false)
		_play_sfx_chat_ding()
		_post_synced_message("M4rchupikchu_inw101", "Roblox ป่าวน้อง", "21:25", false)
		
		# Show notification popup pointing to mobile phone
		if desktop and desktop.has_method("_spawn_discord_preview_popup"):
			desktop._spawn_discord_preview_popup("พี่มาร์ช (มือถือ [P])", "\"Roblox ป่าวน้อง\"")
		
		# Prepare May's turn 1 in mobile phone
		current_phase = ChatPhase.MAY_1_INPUT
		_set_may_input_prefilled("พี่มาร์ชคะ คอมเปิดไฟล์ไม่ได้ค่ะ", false)
	)

# Beat 2: May sends turn 1 ("พี่มาร์ชคะ คอมเปิดไฟล์ไม่ได้ค่ะ")
func _on_may_send_1() -> void:
	current_phase = ChatPhase.MARCH_2_WAIT
	_update_game_time("21:26")
	_clear_and_disable_inputs()
	_post_synced_message("Mayicomeinpls", "พี่มาร์ชคะ คอมเปิดไฟล์ไม่ได้ค่ะ", "21:26", true)
	
	# March types reply 2
	var tw := create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func() -> void:
		_set_typing_indicators(true)
	)
	tw.tween_interval(1.5)
	tw.tween_callback(func() -> void:
		_set_typing_indicators(false)
		_play_sfx_chat_ding()
		_update_game_time("21:28")
		_post_synced_message("M4rchupikchu_inw101", "ไฟล์อะไร", "21:28", false)
		
		# Prepare May's turn 2 in mobile phone
		current_phase = ChatPhase.MAY_2_INPUT
		_set_may_input_prefilled("ไฟล์ docx แล้ว .locked ค่ะ", false)
	)

# Beat 3: May sends turn 2 ("ไฟล์ docx แล้ว .locked ค่ะ")
func _on_may_send_2() -> void:
	current_phase = ChatPhase.MARCH_3_WAIT
	_clear_and_disable_inputs()
	_post_synced_message("Mayicomeinpls", "ไฟล์ docx แล้ว .locked ค่ะ", "21:28", true)
	
	# March types reply 3
	var tw := create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func() -> void:
		_set_typing_indicators(true)
	)
	tw.tween_interval(1.5)
	tw.tween_callback(func() -> void:
		_set_typing_indicators(false)
		_play_sfx_chat_ding()
		_post_synced_message("M4rchupikchu_inw101", "ยังไงนะ ถ่ายรูปมาหน่อย", "21:28", false)
		
		# Prepare May's screenshot turn in mobile phone
		current_phase = ChatPhase.MAY_3_SCREENSHOT
		_set_may_input_prefilled("", true)
	)

# Beat 4: May 1-click sends screenshot evidence of .locked files
func _on_screenshot_sent() -> void:
	if current_phase != ChatPhase.MAY_3_SCREENSHOT:
		return
	current_phase = ChatPhase.MARCH_4_WAIT
	_update_game_time("21:29")
	_play_sfx_camera_click()
	_clear_and_disable_inputs()
	_post_synced_message("Mayicomeinpls", "[ส่งรูปภาพหน้าจอไฟล์ .locked]", "21:29", true, true)
	
	# March types final advice
	var tw := create_tween()
	tw.tween_interval(0.8)
	tw.tween_callback(func() -> void:
		_set_typing_indicators(true)
	)
	tw.tween_interval(1.5)
	tw.tween_callback(func() -> void:
		_set_typing_indicators(false)
		_play_sfx_chat_ding()
		_update_game_time("21:30")
		_post_synced_message("M4rchupikchu_inw101", "อืมม ตัดเน็ตคอมพิวเตอร์ก่อน", "21:30", false)
		
		current_phase = ChatPhase.CHAT_COMPLETED
		# Transition to Step 2: Incoming Phone Call from March
		var call_tw := create_tween()
		call_tw.tween_interval(1.4)
		call_tw.tween_callback(_start_incoming_phone_call)
	)

# Send button handler on mobile phone
func _on_phone_send_pressed(_submitted_text: String = "") -> void:
	if current_phase == ChatPhase.MAY_1_INPUT:
		_on_may_send_1()
	elif current_phase == ChatPhase.MAY_2_INPUT:
		_on_may_send_2()

# --- Step 2: Compact Incoming Phone Call Cutscene ---

# Trigger incoming phone call from March at 21:30
func _start_incoming_phone_call() -> void:
	current_phase = ChatPhase.CALL_RINGING
	incoming_call_started.emit()
	
	# Open mobile phone modal in incoming call view
	_open_phone()
	if phone_chat_container:
		phone_chat_container.visible = false
	if phone_call_container:
		phone_call_container.visible = true
	
	call_status_lbl.text = "กำลังโทรเข้า..."
	call_timer_lbl.visible = false
	call_decline_btn.visible = true
	call_answer_btn.visible = true
	call_hangup_btn.visible = false
	
	# Start looping ringtone audio
	_play_phone_ringtone()

# Handle decline button press (March re-dials with emergency prompt)
func _on_call_declined() -> void:
	_stop_phone_ringtone()
	call_status_lbl.text = "สายถูกตัด..."
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_callback(func() -> void:
		call_status_lbl.text = "โทรกลับมาอีกครั้ง (เรื่องด่วน!)"
		_play_phone_ringtone()
	)

# Handle answer button press (Transition to active in-call dialogue)
func _on_call_answered() -> void:
	if current_phase != ChatPhase.CALL_RINGING:
		return
	current_phase = ChatPhase.CALL_CONNECTED
	_stop_phone_ringtone()
	phone_call_answered.emit()
	
	call_status_lbl.text = "กำลังสนทนากับพี่มาร์ช"
	call_timer_lbl.visible = true
	call_decline_btn.visible = false
	call_answer_btn.visible = false
	call_hangup_btn.visible = true
	
	# Start call timer
	call_seconds = 0
	call_timer_tween = create_tween().set_loops()
	call_timer_tween.tween_interval(1.0)
	call_timer_tween.tween_callback(func() -> void:
		call_seconds += 1
		call_timer_lbl.text = "● %02d:%02d" % [call_seconds / 60, call_seconds % 60]
	)
	
	# Play telephone conversation lines (Story_Board page 15)
	_play_call_dialogue_sequence()

# Step through telephone dialogue sequentially
func _play_call_dialogue_sequence() -> void:
	for child in call_dialogue_vbox.get_children():
		child.queue_free()
	
	var tw := create_tween()
	
	# Line 1: มาร์ช: "ยังมีเต่าดำอยู่ใช่มั้ย"
	tw.tween_interval(0.5)
	tw.tween_callback(func() -> void:
		_add_call_speech_bubble("มาร์ช", "ยังมีเต่าดำอยู่ใช่มั้ย", Color(0.2, 0.4, 0.7, 0.95))
	)
	
	# Line 2: เมย์: "ยังอยู่ค่ะ"
	tw.tween_interval(1.6)
	tw.tween_callback(func() -> void:
		_add_call_speech_bubble("เมย์", "ยังอยู่ค่ะ", Color(0.15, 0.35, 0.6, 0.95))
	)
	
	# Line 3: มาร์ช: "งั้นเดี๋ยวมาไล่ดูในเครื่องหลักก่อนว่าเกิดอะไรขึ้น"
	tw.tween_interval(1.6)
	tw.tween_callback(func() -> void:
		_add_call_speech_bubble("มาร์ช", "งั้นเดี๋ยวมาไล่ดูในเครื่องหลักก่อนว่าเกิดอะไรขึ้น", Color(0.2, 0.4, 0.7, 0.95))
		call_hangup_btn.text = "📴 วางสาย (เข้าสู่ Task 3)"
	)

# Add speech card to phone call view
func _add_call_speech_bubble(speaker: String, text_msg: String, bg_col: Color) -> void:
	if not call_dialogue_vbox:
		return
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = bg_col
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	style.content_margin_left = 5.0
	style.content_margin_right = 5.0
	style.content_margin_top = 2.0
	style.content_margin_bottom = 2.0
	card.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	card.add_child(vbox)
	
	var name_lbl := Label.new()
	name_lbl.text = speaker
	name_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	name_lbl.add_theme_font_size_override("font_size", 5)
	name_lbl.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0, 0.9))
	vbox.add_child(name_lbl)
	
	var msg_lbl := Label.new()
	msg_lbl.text = text_msg
	msg_lbl.add_theme_font_override("font", FONT_THAI_MEDIUM)
	msg_lbl.add_theme_font_size_override("font_size", 6)
	msg_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(msg_lbl)
	
	call_dialogue_vbox.add_child(card)

# Conclude call and transition to Step 3
func _on_call_hangup_pressed() -> void:
	if call_timer_tween and call_timer_tween.is_valid():
		call_timer_tween.kill()
	_play_sfx_call_end()
	phone_call_ended.emit()
	
	# Close phone modal and switch to Task 3: Event Log
	_close_phone()
	_start_step_3_event_log_task()

# --- Step 3: Enter Task 3 หาสาเหตุ (Event Log) ---

# Switch objective to Task 3: Inspect Event log
func _start_step_3_event_log_task() -> void:
	current_phase = ChatPhase.TASK_3_EVENT_LOG
	
	# Update Task Panel immediately
	_set_task_objective("• Task 3 หาสาเหตุ", "- [ ] ตรวจ Event log")
	
	# Highlight Event Viewer icon launcher on desktop
	if event_viewer_icon and is_instance_valid(event_viewer_icon):
		event_viewer_icon.visible = true
	
	# Show prompt toast
	if desktop and desktop.has_method("_show_dialogue_toast"):
		desktop._show_dialogue_toast("เมย์", "ลองเปิด Event Viewer ในเครื่องเพื่อหาสาเหตุ...", 3.2)

# Create Event Viewer window and standard DesktopIcon in Column 2 (cleanly separated from Trash)
func _setup_event_viewer_window() -> void:
	investigation_window = DESKTOP_WINDOW_SCENE.instantiate()
	investigation_window.name = "InvestigationWindow"
	investigation_window.window_title = "Event Viewer - Windows Logs"
	investigation_window.clip_contents = true
	investigation_window.custom_minimum_size = Vector2(300, 175)
	investigation_window.size = Vector2(300, 175)
	investigation_window.position = Vector2(88, 28)
	investigation_window.visible = false
	add_child(investigation_window)
	
	# Register desktop taskbar tab integration on window events
	if desktop:
		investigation_window.window_closed.connect(func():
			if desktop.has_method("_update_taskbar_tab"):
				desktop._update_taskbar_tab(investigation_window, "", false)
		)
		investigation_window.window_minimized.connect(func():
			if desktop.has_method("_highlight_active_tab"):
				desktop._highlight_active_tab(null)
		)
		investigation_window.window_focused.connect(func():
			if desktop.has_method("_highlight_active_tab"):
				desktop._highlight_active_tab(investigation_window)
		)
	
	# Add Event Viewer DesktopIcon to desktop's IconsContainer in Column 2 (not overlapping Trash)
	var icons_container: Control = null
	if desktop:
		icons_container = desktop.get("icons_container")
		if not icons_container:
			icons_container = desktop.get_node_or_null("%IconsContainer") as Control
	
	if icons_container:
		var col2: VBoxContainer = icons_container.get_node_or_null("Col2") as VBoxContainer
		if not col2:
			col2 = VBoxContainer.new()
			col2.name = "Col2"
			col2.add_theme_constant_override("separation", 4)
			icons_container.add_child(col2)
		
		event_viewer_icon = DESKTOP_ICON_SCENE.instantiate() as DesktopIcon
		event_viewer_icon.name = "Icon_EventViewer"
		event_viewer_icon.app_id = "event_viewer"
		event_viewer_icon.app_name = "Event Log"
		if ICON_COMPUTER:
			event_viewer_icon.icon_texture = ICON_COMPUTER
		event_viewer_icon.icon_activated.connect(func(_id: String): _open_event_log_viewer())
		event_viewer_icon.icon_selected.connect(func(_id: String): pass)
		col2.add_child(event_viewer_icon)

# Open Event Log puzzle inside DesktopWindow centered on screen
func _open_event_log_viewer() -> void:
	event_log_opened.emit()
	if not investigation_window:
		return
	
	# Minimize other open windows so background is clean without protruding edges
	if desktop:
		if desktop.get("files_window") and desktop.files_window.visible:
			desktop.files_window.minimize_window()
		if desktop.get("text_editor_window") and desktop.text_editor_window.visible:
			desktop.text_editor_window.minimize_window()
	
	investigation_window.window_title = "Event Viewer - Windows Logs"
	var content := investigation_window.get_content_container()
	for child in content.get_children():
		child.queue_free()
	
	var puzzle := PUZZLE_EVENT_LOG_SCENE.instantiate()
	puzzle.connect("timestamp_selected", _on_event_log_selected)
	content.add_child(puzzle)
	
	# Center on 480x270 viewport and register taskbar tab
	investigation_window.clip_contents = true
	investigation_window.custom_minimum_size = Vector2(300, 175)
	investigation_window.size = Vector2(300, 175)
	investigation_window.position = Vector2(88, 28)
	investigation_window.open_window()
	if desktop and desktop.has_method("_update_taskbar_tab"):
		desktop._update_taskbar_tab(investigation_window, "Event Viewer", true)
		desktop._highlight_active_tab(investigation_window)

# Handle player selecting timestamp from Event Log
func _on_event_log_selected(timestamp: String) -> void:
	if timestamp == "19:02:10" and not is_event_log_done:
		is_event_log_done = true
		event_log_completed.emit(timestamp)
		_set_task_objective("• Task 3 หาสาเหตุ", "- [x] ตรวจ Event log (19:02:10 WINWORD.EXE)")
		if desktop and desktop.has_method("_show_dialogue_toast"):
			desktop._show_dialogue_toast("เมย์", "เริ่มต้นจากไฟล์ Report_Final.docx ตอน 19:02:10... พี่มาร์ชบอกให้ไปหยิบโน้ตบุ๊กเต่าดำในห้องมาเตรียมไว้!", 3.5)

		# Auto-transition to bedroom for notebook after toast completes
		var trans_tw := create_tween()
		trans_tw.tween_interval(3.8)
		trans_tw.tween_callback(func() -> void:
			if has_node("/root/SceneRouter"):
				SceneRouter.goto_scene_4_bedroom()
			else:
				if game_state_node and is_instance_valid(game_state_node):
					game_state_node.set("scene_phase", "SCENE_4_INVESTIGATION")
					game_state_node.set("is_scene_4", true)
				var bedroom_path := "res://Scenes/Scene_02_Tutorial.tscn"
				if ResourceLoader.exists(bedroom_path):
					get_tree().change_scene_to_file(bedroom_path)
		)

# Developer quick skip key (F10) for testing
func _developer_skip_step() -> void:
	if current_phase == ChatPhase.MARCH_1_WAIT or current_phase == ChatPhase.MAY_1_INPUT:
		_on_may_send_1()
	elif current_phase == ChatPhase.MARCH_2_WAIT or current_phase == ChatPhase.MAY_2_INPUT:
		_on_may_send_2()
	elif current_phase == ChatPhase.MARCH_3_WAIT or current_phase == ChatPhase.MAY_3_SCREENSHOT:
		_on_screenshot_sent()
	elif current_phase == ChatPhase.CALL_RINGING:
		_on_call_answered()
	elif current_phase == ChatPhase.CALL_CONNECTED:
		_on_call_hangup_pressed()
	elif current_phase == ChatPhase.TASK_3_EVENT_LOG:
		_on_event_log_selected("19:02:10")
