class_name Scene02Tutorial extends Node2D

## Scene 2: Bedroom Tutorial & Game Flow (Storyboards 16 -> 20)
## State 1: Mobile chat prompt (Image 16)
## State 2: Smartphone chat modal (Image 17)
## State 3: Character movement tutorial WASD (Image 18)
## State 4: Room exploration & interactable objects (Image 19)
## State 5: First task - Go to Desktop (Image 20)
##
## Scene 4 (Investigation Intro):
## - March contact icon with red (+1) notification badge and chime
## - Floating pixel-art Speech Bubble guide over May ("โน้ตบุ๊กชมรมอยู่ในตู้...")
## - Top-right Task 3: "• Task 3 หาสาเหตุ: - [ ] หยิบ Notebook ชมรม"
## - Inspect lower bookshelf / cabinet to pick up Tao Dam notebook (turns green [x])

signal state_changed(new_state: TutorialState)
signal phone_opened
signal phone_closed
signal movement_completed
signal object_inspected(object_name: String)
signal desktop_task_completed
signal notebook_picked_up
signal scene_mode_switched(is_scene_4: bool)

@export var force_scene_4_mode: bool = false

const DESKTOP_SCENE_PATH: String = "res://Scenes/Initial/desktop_screen.tscn"

# Sequential Tutorial State Machine (Storyboards 16 - 20)
enum TutorialState {
	STATE_1_MOBILE_PROMPT,      # Image 16: Check phone prompt
	STATE_2_MOBILE_CHAT,        # Image 17: Mobile modal open
	STATE_3_MOVEMENT_GUIDE,     # Image 18: WASD movement guide
	STATE_4_ROOM_EXPLORATION,   # Image 19: Object inspection
	STATE_5_FIRST_TASK_DESKTOP  # Image 20: Task 1 Go to Desktop
}

# Room interactable object types
enum InteractableType {
	NONE,
	DESKTOP,
	BOOKSHELF_UPPER,
	BOOKSHELF_LOWER,
	SPEAKER,
	WINDOW,
	DRAWER
}

# 4 unread messages from Mesa according to Story Content
const MESA_MESSAGES: Array[Dictionary] = [
	{ "time": "14:33", "text": "เมย์" },
	{ "time": "14:33", "text": "การบ้านเธอจะทำส่วนไหน" },
	{ "time": "17:47", "text": "ฉันทำหมดแล้วล่ะ เหลือส่วนของรายงาน" },
	{ "time": "18:48", "text": "ฮาโหลลลลลล มีใครอยู่มั้ย" }
]

# Scene 4 March chat history
const MARCH_MESSAGES: Array[Dictionary] = [
	{ "time": "21:25", "sender": "M4rchupikchu_inw101", "text": "Roblox ป่าวน้อง" },
	{ "time": "21:26", "sender": "Mayicomeinpls", "text": "พี่มาร์ชคะ คอมเปิดไฟล์ไม่ได้ค่ะ" },
	{ "time": "21:28", "sender": "M4rchupikchu_inw101", "text": "ไฟล์อะไร" },
	{ "time": "21:28", "sender": "Mayicomeinpls", "text": "ไฟล์ docx แล้ว .locked ค่ะ" },
	{ "time": "21:28", "sender": "M4rchupikchu_inw101", "text": "ยังไงนะ ถ่ายรูปมาหน่อย" },
	{ "time": "21:29", "sender": "Mayicomeinpls", "text": "[รูปถ่ายหน้าจอไฟล์ .locked]" },
	{ "time": "21:30", "sender": "M4rchupikchu_inw101", "text": "อืมม ตัดเน็ตคอมก่อน แล้วไปหยิบโน้ตบุ๊กเต่าดำมาเช็คสภาพ" }
]

# Audio players
var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Scene References
var player_node: CharacterBody2D
var interactable_areas: Dictionary = {}

# UI Layer & Controls
var canvas_layer: CanvasLayer
var notif_badge_btn: Button
var avatar_panel: PanelContainer
var avatar_rect: TextureRect
var notif_badge_circle: PanelContainer
var notif_badge_label: Label
var notif_pulse_tween: Tween

var interaction_panel: PanelContainer
var interaction_vbox: VBoxContainer

var phone_dimmer: ColorRect
var phone_modal: PanelContainer
var phone_time_lbl: Label
var phone_thumb_frame: PanelContainer
var phone_contact_avatar: TextureRect
var phone_header_title: Label
var phone_header_sub: Label
var phone_chat_scroll: ScrollContainer
var phone_messages_vbox: VBoxContainer
var phone_close_btn: Button

var thought_bubble: PanelContainer
var thought_label: Label
var thought_tween: Tween

# Scene 4 specific guidance nodes
var speech_bubble_hint: Control
var speech_bubble_tween: Tween
var cabinet_marker: Node2D
var cabinet_tween: Tween
var cabinet_highlight: PanelContainer
var cabinet_highlight_tween: Tween
var desk_notebook_sprite: Sprite2D

var dialogue_box: PanelContainer
var dialogue_title: Label
var dialogue_text: Label
var dialogue_tween: Tween

var screen_fader: ColorRect

# Runtime states
var current_state: TutorialState = TutorialState.STATE_1_MOBILE_PROMPT
var active_interactable: InteractableType = InteractableType.NONE
var is_phone_open: bool = false
var has_read_messages: bool = false
var has_shown_first_thought: bool = false
var is_bgm_muted: bool = false
var is_task_1_completed: bool = false
var is_scene_4_active: bool = false
var is_notebook_picked_up: bool = false

# Movement tutorial trackers
var moved_distance: float = 0.0
var directions_pressed: Dictionary = {
	"W": false,
	"A": false,
	"S": false,
	"D": false
}
var wasd_key_panels: Dictionary = {}

# Fonts
var font_thai: Font
var font_thai_bold: Font
var font_mono: Font

func _exit_tree() -> void:
	if notif_pulse_tween and notif_pulse_tween.is_valid():
		notif_pulse_tween.kill()
	if thought_tween and thought_tween.is_valid():
		thought_tween.kill()
	if dialogue_tween and dialogue_tween.is_valid():
		dialogue_tween.kill()
	if speech_bubble_tween and speech_bubble_tween.is_valid():
		speech_bubble_tween.kill()
	if cabinet_tween and cabinet_tween.is_valid():
		cabinet_tween.kill()
	if cabinet_highlight_tween and cabinet_highlight_tween.is_valid():
		cabinet_highlight_tween.kill()

func _ready() -> void:
	_load_fonts()
	_setup_audio()
	_setup_player()
	_setup_interactables()
	_setup_ui()
	
	# Determine mode: Scene 4 Investigation vs Scene 2 Tutorial
	var game_state := get_tree().root.get_node_or_null("GameState") if (is_inside_tree() and get_tree().root) else null
	if game_state:
		var phase: String = str(game_state.get("scene_phase")) if game_state.get("scene_phase") != null else ""
		var s4: bool = (game_state.get("is_scene_4") == true)
		if s4 or phase == "SCENE_4_INVESTIGATION" or phase == "SCENE_4_INVESTIGATION_INTRO":
			is_scene_4_active = true
		else:
			is_scene_4_active = force_scene_4_mode
	else:
		is_scene_4_active = force_scene_4_mode

	if is_scene_4_active:
		_setup_scene_4_mode()
	else:
		_setup_scene_2_mode()

func _load_fonts() -> void:
	if ResourceLoader.exists("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Medium.ttf"):
		font_thai = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Medium.ttf")
	if ResourceLoader.exists("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf"):
		font_thai_bold = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")
	else:
		font_thai_bold = font_thai
	if ResourceLoader.exists("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf"):
		font_mono = load("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

func _setup_audio() -> void:
	# Bedroom BGM loop
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BedroomBgmPlayer"
	bgm_player.volume_db = -14.0
	bgm_player.stream = _generate_lofi_bgm_stream()
	add_child(bgm_player)
	bgm_player.play()

	# SFX player for UI chirps and interactions
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "TutorialSfxPlayer"
	sfx_player.volume_db = -8.0
	add_child(sfx_player)

func _setup_player() -> void:
	player_node = get_node_or_null("Player") as CharacterBody2D
	if not player_node:
		var player_scene = load("res://Scenes/Initial/player.tscn")
		if player_scene:
			player_node = player_scene.instantiate()
			player_node.position = Vector2(115, 160)
			player_node.z_index = 3
			add_child(player_node)

	# State 1: Lock movement until phone is checked
	if player_node:
		player_node.set_physics_process(false)

# State Machine transition controller
func _set_state(new_state: TutorialState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	_apply_state(new_state)
	state_changed.emit(new_state)

func _apply_state(state: TutorialState) -> void:
	match state:
		TutorialState.STATE_1_MOBILE_PROMPT:
			# Tutorial State 1: Prompt mobile interaction
			if player_node:
				player_node.set_physics_process(false)
			_update_hud_panel()

		TutorialState.STATE_2_MOBILE_CHAT:
			# Tutorial State 2: Open phone modal & dim background
			_open_phone()

		TutorialState.STATE_3_MOVEMENT_GUIDE:
			# Tutorial State 3: Teach WASD movement
			if player_node:
				player_node.set_physics_process(true)
			_update_hud_panel()

		TutorialState.STATE_4_ROOM_EXPLORATION, TutorialState.STATE_5_FIRST_TASK_DESKTOP:
			# Tutorial State 4 & 5: Room exploration and Desktop objective
			if player_node:
				player_node.set_physics_process(true)
			_update_hud_panel()

# Room interaction triggers (Area2D setup)
func _setup_interactables() -> void:
	# 1. Desktop (Computer table)
	_create_trigger(InteractableType.DESKTOP, Vector2(220, 138), Vector2(46, 28))

	# 2. Speaker (Desktop speaker)
	_create_trigger(InteractableType.SPEAKER, Vector2(174, 138), Vector2(24, 28))

	# 3. Window (Curtained windows)
	_create_trigger(InteractableType.WINDOW, Vector2(336, 130), Vector2(46, 32))

	# 4. Drawer beside bed
	_create_trigger(InteractableType.DRAWER, Vector2(108, 138), Vector2(32, 28))

	# 5. Bookshelf upper (Flash drive)
	_create_trigger(InteractableType.BOOKSHELF_UPPER, Vector2(418, 118), Vector2(36, 22))

	# 6. Bookshelf lower (Notebook)
	_create_trigger(InteractableType.BOOKSHELF_LOWER, Vector2(418, 148), Vector2(44, 28))

func _create_trigger(type: InteractableType, pos: Vector2, size: Vector2) -> void:
	var area := Area2D.new()
	area.name = "Interactable_" + str(type)
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 1 # Player layer

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	col.shape = rect
	area.add_child(col)

	area.body_entered.connect(_on_interactable_entered.bind(type))
	area.body_exited.connect(_on_interactable_exited.bind(type))

	add_child(area)
	interactable_areas[type] = area

func _on_interactable_entered(body: Node2D, type: InteractableType) -> void:
	if body == player_node or body is CharacterBody2D:
		active_interactable = type
		_update_hud_panel()

func _on_interactable_exited(body: Node2D, type: InteractableType) -> void:
	if (body == player_node or body is CharacterBody2D) and active_interactable == type:
		active_interactable = InteractableType.NONE
		_update_hud_panel()
		_dismiss_dialogue()

# UI Setup
func _setup_ui() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "TutorialUI"
	add_child(canvas_layer)

	_setup_notification_badge()
	_setup_interaction_guide()
	_setup_phone_dimmer()
	_setup_phone_modal()
	_setup_thought_bubble()
	_setup_dialogue_box()
	_setup_screen_fader()

# Notification badge on top-left (Image 16)
func _setup_notification_badge() -> void:
	notif_badge_btn = Button.new()
	notif_badge_btn.name = "NotificationBadgeBtn"
	notif_badge_btn.position = Vector2(14, 12)
	notif_badge_btn.custom_minimum_size = Vector2(36, 36)
	notif_badge_btn.size = Vector2(36, 36)
	notif_badge_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	notif_badge_btn.flat = true
	notif_badge_btn.pressed.connect(_on_notification_badge_pressed)
	canvas_layer.add_child(notif_badge_btn)

	# Avatar circular frame
	avatar_panel = PanelContainer.new()
	avatar_panel.name = "AvatarPanel"
	avatar_panel.custom_minimum_size = Vector2(32, 32)
	avatar_panel.size = Vector2(32, 32)
	avatar_panel.position = Vector2(2, 2)
	avatar_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar_panel.clip_contents = true
	var av_style := StyleBoxFlat.new()
	av_style.bg_color = Color(0.72, 0.20, 0.20, 0.95)
	av_style.border_width_left = 2
	av_style.border_width_top = 2
	av_style.border_width_right = 2
	av_style.border_width_bottom = 2
	av_style.border_color = Color(0.95, 0.88, 0.88, 1.0)
	av_style.corner_radius_top_left = 16
	av_style.corner_radius_top_right = 16
	av_style.corner_radius_bottom_right = 16
	av_style.corner_radius_bottom_left = 16
	avatar_panel.add_theme_stylebox_override("panel", av_style)
	notif_badge_btn.add_child(avatar_panel)

	# Strip skin tone modifier to fix emoji block glitch (pure base 👧)
	avatar_rect = TextureRect.new()
	avatar_rect.name = "AvatarRect"
	avatar_rect.custom_minimum_size = Vector2(24, 24)
	avatar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	avatar_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	avatar_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var portrait_path := "res://assets/images/portraits/portrait_mesa.png"
	if ResourceLoader.exists(portrait_path):
		avatar_rect.texture = load(portrait_path)
	avatar_panel.add_child(avatar_rect)

	# Red unread badge (+4)
	notif_badge_circle = PanelContainer.new()
	notif_badge_circle.name = "UnreadBadgeCircle"
	notif_badge_circle.position = Vector2(20, -2)
	notif_badge_circle.custom_minimum_size = Vector2(16, 16)
	notif_badge_circle.size = Vector2(16, 16)
	notif_badge_circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var red_style := StyleBoxFlat.new()
	red_style.bg_color = Color(0.92, 0.18, 0.18, 1.0)
	red_style.border_width_left = 1
	red_style.border_width_top = 1
	red_style.border_width_right = 1
	red_style.border_width_bottom = 1
	red_style.border_color = Color.WHITE
	red_style.corner_radius_top_left = 8
	red_style.corner_radius_top_right = 8
	red_style.corner_radius_bottom_right = 8
	red_style.corner_radius_bottom_left = 8
	notif_badge_circle.add_theme_stylebox_override("panel", red_style)
	notif_badge_btn.add_child(notif_badge_circle)

	notif_badge_label = Label.new()
	notif_badge_label.name = "BadgeLabel"
	notif_badge_label.text = "+4"
	if font_mono: notif_badge_label.add_theme_font_override("font", font_mono)
	notif_badge_label.add_theme_font_size_override("font_size", 7)
	notif_badge_label.add_theme_color_override("font_color", Color.WHITE)
	notif_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notif_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notif_badge_circle.add_child(notif_badge_label)

# Top-right context HUD panel (Styled with Main Menu translucent navy & cream border)
func _setup_interaction_guide() -> void:
	interaction_panel = PanelContainer.new()
	interaction_panel.name = "InteractionGuidePanel"
	interaction_panel.position = Vector2(286, 6)
	interaction_panel.custom_minimum_size = Vector2(188, 0)
	interaction_panel.add_theme_stylebox_override("panel", _create_menu_stylebox(0.88, 5))
	canvas_layer.add_child(interaction_panel)

	interaction_vbox = VBoxContainer.new()
	interaction_vbox.name = "InteractionVBox"
	interaction_vbox.add_theme_constant_override("separation", 3)
	interaction_panel.add_child(interaction_vbox)

# Dynamic HUD panel updates according to Tutorial State Machine (1 - 5)
func _update_hud_panel() -> void:
	if not interaction_vbox:
		return

	wasd_key_panels.clear()
	for child in interaction_vbox.get_children():
		interaction_vbox.remove_child(child)
		child.queue_free()

	if is_phone_open:
		interaction_panel.visible = false
		return

	interaction_panel.visible = true
	interaction_panel.custom_minimum_size = Vector2.ZERO
	interaction_panel.size = Vector2.ZERO

	# Scene 4 Mode: Task 3 - หาสาเหตุ & หยิบ Notebook ชมรม
	if is_scene_4_active:
		if active_interactable != InteractableType.NONE:
			interaction_panel.add_theme_stylebox_override("panel", _create_menu_stylebox(0.88, 4, 8.0, 5.0))
			var header := _create_header_label("• การโต้ตอบ")
			interaction_vbox.add_child(header)

			var prompt_str: String = ""
			match active_interactable:
				InteractableType.BOOKSHELF_LOWER:
					prompt_str = "- กด [Spacebar] เพื่อหยิบ Notebook ชมรม" if not is_notebook_picked_up else "- กด [Spacebar] เพื่อสำรวจตู้เก็บของ"
				InteractableType.DESKTOP:
					prompt_str = "- กด [Spacebar] เพื่อเริ่มตรวจสอบโน้ตบุ๊กเต่าดำ" if is_notebook_picked_up else "- กด [Spacebar] เพื่อตรวจดูคอมพิวเตอร์"
				_:
					prompt_str = "- กด [Spacebar] เพื่อตรวจสอบสิ่งของ"

			var row_space := _create_key_row("Space", 34, prompt_str, Color(0.95, 0.95, 0.95, 1.0))
			interaction_vbox.add_child(row_space)
			interaction_panel.reset_size()
			interaction_panel.position = Vector2(480.0 - interaction_panel.get_combined_minimum_size().x - 12.0, 6.0)
			return
		else:
			# Objective Panel matching Task 3 requirements
			interaction_panel.add_theme_stylebox_override("panel", _create_menu_stylebox(0.90, 4, 10.0, 6.0))
			var header := _create_header_label("• Task 3 หาสาเหตุ")
			interaction_vbox.add_child(header)

			if is_notebook_picked_up:
				var task_done := Label.new()
				task_done.text = "  - [x] หยิบ Notebook ชมรม"
				task_done.add_theme_color_override("font_color", Color(0.35, 0.95, 0.5, 1.0)) # Completed green
				if font_thai_bold: task_done.add_theme_font_override("font", font_thai_bold)
				task_done.add_theme_font_size_override("font_size", 8)
				interaction_vbox.add_child(task_done)

				var task_next := Label.new()
				task_next.text = "  - [ ] ตรวจสอบโน้ตบุ๊กเต่าดำที่โต๊ะคอม"
				task_next.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85, 1.0)) # Pending yellow-white
				if font_thai_bold: task_next.add_theme_font_override("font", font_thai_bold)
				task_next.add_theme_font_size_override("font_size", 8)
				interaction_vbox.add_child(task_next)
			else:
				var task_lbl := Label.new()
				task_lbl.text = "  - [ ] หยิบ Notebook ชมรม"
				task_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85, 1.0))
				if font_thai_bold: task_lbl.add_theme_font_override("font", font_thai_bold)
				task_lbl.add_theme_font_size_override("font_size", 8)
				interaction_vbox.add_child(task_lbl)

			interaction_panel.reset_size()
			interaction_panel.position = Vector2(480.0 - interaction_panel.get_combined_minimum_size().x - 12.0, 8.0)
			return

	# Case A: Inside an Area2D in State 4 or 5 -> Prompt [Space] to Inspect (Image 19)
	if active_interactable != InteractableType.NONE and current_state >= TutorialState.STATE_3_MOVEMENT_GUIDE:
		interaction_panel.add_theme_stylebox_override("panel", _create_menu_stylebox(0.88, 4, 8.0, 5.0))
		var header := _create_header_label("• การโต้ตอบ")
		interaction_vbox.add_child(header)

		var prompt_str := _get_interactable_prompt_text(active_interactable)
		var row_space := _create_key_row("Space", 34, prompt_str, Color(0.95, 0.95, 0.95, 1.0))
		interaction_vbox.add_child(row_space)
		interaction_panel.reset_size()
		interaction_panel.position = Vector2(480.0 - interaction_panel.get_combined_minimum_size().x - 12.0, 6.0)
		return

	# Case B: State 1 - Prompt mobile interaction (Image 16)
	if current_state == TutorialState.STATE_1_MOBILE_PROMPT:
		interaction_panel.add_theme_stylebox_override("panel", _create_menu_stylebox(0.88, 4, 8.0, 5.0))
		var header := _create_header_label("• การโต้ตอบ")
		interaction_vbox.add_child(header)

		var row_p := _create_key_row("P", 18, "- กด [P] เพื่อใช้มือถือ", Color(0.95, 0.92, 0.92, 0.95))
		interaction_vbox.add_child(row_p)
		interaction_panel.reset_size()
		interaction_panel.position = Vector2(480.0 - interaction_panel.get_combined_minimum_size().x - 12.0, 6.0)
		return

	# Case C: State 3 - Teach WASD movement (Image 18)
	if current_state == TutorialState.STATE_3_MOVEMENT_GUIDE:
		interaction_panel.add_theme_stylebox_override("panel", _create_menu_stylebox(0.88, 4, 8.0, 5.0))
		# Compact WASD tutorial layout margins
		interaction_panel.custom_minimum_size = Vector2(170, 78)

		var header := _create_header_label("• การเคลื่อนที่")
		interaction_vbox.add_child(header)

		var wasd_ctrl := _create_wasd_layout_control()
		interaction_vbox.add_child(wasd_ctrl)
		interaction_panel.position = Vector2(480.0 - 170.0 - 12.0, 6.0)
		return

	# Case D: State 5 - First task: Go to Desktop (Image 20)
	if current_state == TutorialState.STATE_5_FIRST_TASK_DESKTOP or current_state == TutorialState.STATE_4_ROOM_EXPLORATION:
		# Compact padding 10px H, 6px V for tightly fitting Task 1 box (no excess dark space)
		interaction_panel.add_theme_stylebox_override("panel", _create_menu_stylebox(0.90, 4, 10.0, 6.0))

		var header := _create_header_label("• Task 1 ทำรายงานต่อ")
		interaction_vbox.add_child(header)

		var task_lbl := Label.new()
		if is_task_1_completed:
			task_lbl.text = "  - [x] ไปที่ Desktop"
			task_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 1.0))
		else:
			task_lbl.text = "  - [ ] ไปที่ Desktop"
			task_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85, 1.0))
		if font_thai_bold: task_lbl.add_theme_font_override("font", font_thai_bold)
		task_lbl.add_theme_font_size_override("font_size", 8)
		interaction_vbox.add_child(task_lbl)

		interaction_panel.reset_size()
		# Position neatly in top-right corner
		interaction_panel.position = Vector2(480.0 - interaction_panel.get_combined_minimum_size().x - 12.0, 8.0)
		return

# Creates the virtual keyboard layout matching Image 18
# Fix left direction label overlapping key S
# Align WASD directional hints and guide lines
func _create_wasd_layout_control() -> Control:
	var ctrl := Control.new()
	ctrl.custom_minimum_size = Vector2(154, 60)

	# [W] Key and guide line (Top row)
	var key_w := _create_keycap_panel("W", 18)
	key_w.position = Vector2(67, 0)
	ctrl.add_child(key_w)
	wasd_key_panels["W"] = key_w

	# Line to "เดินขึ้น"
	var line_w := ColorRect.new()
	line_w.position = Vector2(88, 9)
	line_w.size = Vector2(6, 1)
	line_w.color = Color(0.90, 0.78, 0.62, 0.8)
	ctrl.add_child(line_w)

	var lbl_w := Label.new()
	lbl_w.text = "เดินขึ้น"
	if font_thai: lbl_w.add_theme_font_override("font", font_thai)
	lbl_w.add_theme_font_size_override("font_size", 6)
	lbl_w.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85, 1.0))
	lbl_w.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_w.position = Vector2(97, 4)
	ctrl.add_child(lbl_w)

	# Middle row: [เดินไปทางซ้าย] --- [A] [S] [D] --- [เดินไปทางขวา]
	# Container structure guarantees [เดินไปทางซ้าย] stays strictly to the left of Key [A]
	var hbox_mid := HBoxContainer.new()
	hbox_mid.name = "MidRow"
	hbox_mid.add_theme_constant_override("separation", 3)
	hbox_mid.position = Vector2(0, 20)
	hbox_mid.size = Vector2(154, 18)
	ctrl.add_child(hbox_mid)

	var lbl_a := Label.new()
	lbl_a.text = "เดินไปทางซ้าย"
	if font_thai: lbl_a.add_theme_font_override("font", font_thai)
	lbl_a.add_theme_font_size_override("font_size", 6)
	lbl_a.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85, 1.0))
	lbl_a.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox_mid.add_child(lbl_a)

	var line_a := ColorRect.new()
	line_a.custom_minimum_size = Vector2(6, 1)
	line_a.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line_a.color = Color(0.90, 0.78, 0.62, 0.8)
	hbox_mid.add_child(line_a)

	var key_a := _create_keycap_panel("A", 18)
	hbox_mid.add_child(key_a)
	wasd_key_panels["A"] = key_a

	var key_s := _create_keycap_panel("S", 18)
	hbox_mid.add_child(key_s)
	wasd_key_panels["S"] = key_s

	var key_d := _create_keycap_panel("D", 18)
	hbox_mid.add_child(key_d)
	wasd_key_panels["D"] = key_d

	var line_d := ColorRect.new()
	line_d.custom_minimum_size = Vector2(6, 1)
	line_d.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line_d.color = Color(0.90, 0.78, 0.62, 0.8)
	hbox_mid.add_child(line_d)

	var lbl_d := Label.new()
	lbl_d.text = "เดินไปทางขวา"
	if font_thai: lbl_d.add_theme_font_override("font", font_thai)
	lbl_d.add_theme_font_size_override("font_size", 6)
	lbl_d.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85, 1.0))
	lbl_d.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox_mid.add_child(lbl_d)

	# [S] Downward pointer to "เดินลง"
	var line_s := ColorRect.new()
	line_s.position = Vector2(76, 40)
	line_s.size = Vector2(1, 6)
	line_s.color = Color(0.90, 0.78, 0.62, 0.8)
	ctrl.add_child(line_s)

	var lbl_s := Label.new()
	lbl_s.text = "เดินลง"
	if font_thai: lbl_s.add_theme_font_override("font", font_thai)
	lbl_s.add_theme_font_size_override("font_size", 6)
	lbl_s.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85, 1.0))
	lbl_s.position = Vector2(68, 48)
	ctrl.add_child(lbl_s)

	return ctrl

func _create_header_label(title: String) -> Label:
	var lbl := Label.new()
	lbl.text = title
	if font_thai_bold: lbl.add_theme_font_override("font", font_thai_bold)
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.add_theme_color_override("font_color", Color(0.96, 0.88, 0.76, 1.0))
	return lbl

func _create_keycap_panel(key_name: String, min_w: float) -> PanelContainer:
	var key_panel := PanelContainer.new()
	key_panel.custom_minimum_size = Vector2(min_w, 18)
	key_panel.size = Vector2(min_w, 18)
	key_panel.add_theme_stylebox_override("panel", _create_keycap_stylebox(false))

	var key_lbl := Label.new()
	key_lbl.text = key_name
	if font_mono: key_lbl.add_theme_font_override("font", font_mono)
	key_lbl.add_theme_font_size_override("font_size", 8)
	key_lbl.add_theme_color_override("font_color", Color.WHITE)
	key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	key_panel.add_child(key_lbl)
	return key_panel

func _create_key_row(key_name: String, min_w: float, desc: String, desc_color: Color) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	hbox.alignment = BoxContainer.ALIGNMENT_BEGIN

	var key_panel := _create_keycap_panel(key_name, min_w)
	hbox.add_child(key_panel)

	var desc_lbl := Label.new()
	desc_lbl.text = desc
	if font_thai: desc_lbl.add_theme_font_override("font", font_thai)
	desc_lbl.add_theme_font_size_override("font_size", 7)
	desc_lbl.add_theme_color_override("font_color", desc_color)
	desc_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(desc_lbl)
	return hbox

func _get_interactable_prompt_text(type: InteractableType) -> String:
	match type:
		InteractableType.DESKTOP:
			return "- กด [Spacebar] เพื่อใช้งานคอมพิวเตอร์"
		_:
			return "- กด [Spacebar] เพื่อ Inspect สิ่งของ"

# StyleBox builders matching Main Menu theme
func _create_menu_stylebox(bg_alpha: float = 0.88, corner_rad: int = 4, pad_h: float = 8.0, pad_v: float = 4.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.10, 0.20, bg_alpha) # Deep Navy from Main Menu
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.90, 0.78, 0.62, 0.95) # Cream/Beige border (#E6C79E)
	style.corner_radius_top_left = corner_rad
	style.corner_radius_top_right = corner_rad
	style.corner_radius_bottom_right = corner_rad
	style.corner_radius_bottom_left = corner_rad
	style.content_margin_left = pad_h
	style.content_margin_right = pad_h
	style.content_margin_top = pad_v
	style.content_margin_bottom = pad_v
	return style

func _create_keycap_stylebox(is_active: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.16, 0.28, 0.95) if not is_active else Color(0.25, 0.40, 0.70, 1.0)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.92, 0.84, 0.72, 1.0) # Cream outline
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style

# Dimming overlay behind phone modal (Image 17: 40% opacity black)
func _setup_phone_dimmer() -> void:
	phone_dimmer = ColorRect.new()
	phone_dimmer.name = "PhoneDimmer"
	phone_dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	phone_dimmer.color = Color(0.0, 0.0, 0.0, 0.40)
	phone_dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	phone_dimmer.visible = false
	canvas_layer.add_child(phone_dimmer)

# Simulated Smartphone Screen Modal (Image 17)
func _setup_phone_modal() -> void:
	phone_modal = PanelContainer.new()
	phone_modal.name = "PhoneModal"
	phone_modal.position = Vector2(155, 14)
	phone_modal.custom_minimum_size = Vector2(170, 242)
	phone_modal.size = Vector2(170, 242)
	phone_modal.visible = false

	var phone_style := StyleBoxFlat.new()
	phone_style.bg_color = Color(0.08, 0.10, 0.15, 0.98)
	phone_style.border_width_left = 2
	phone_style.border_width_top = 2
	phone_style.border_width_right = 2
	phone_style.border_width_bottom = 2
	phone_style.border_color = Color(0.32, 0.38, 0.50, 1.0)
	phone_style.corner_radius_top_left = 12
	phone_style.corner_radius_top_right = 12
	phone_style.corner_radius_bottom_right = 12
	phone_style.corner_radius_bottom_left = 12
	phone_style.content_margin_left = 4.0
	phone_style.content_margin_right = 4.0
	phone_style.content_margin_top = 4.0
	phone_style.content_margin_bottom = 4.0
	phone_modal.add_theme_stylebox_override("panel", phone_style)
	canvas_layer.add_child(phone_modal)

	var phone_vbox := VBoxContainer.new()
	phone_vbox.add_theme_constant_override("separation", 2)
	phone_modal.add_child(phone_vbox)

	# 1. Top status bar
	var status_hbox := HBoxContainer.new()
	status_hbox.custom_minimum_size = Vector2(0, 12)
	phone_vbox.add_child(status_hbox)

	phone_time_lbl = Label.new()
	phone_time_lbl.text = " 19:02"
	if font_mono: phone_time_lbl.add_theme_font_override("font", font_mono)
	phone_time_lbl.add_theme_font_size_override("font_size", 6)
	phone_time_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 0.8))
	status_hbox.add_child(phone_time_lbl)

	# Remove phone speaker/notch overlay (clean status bar with time & battery only)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_hbox.add_child(spacer)

	var battery_lbl := Label.new()
	battery_lbl.text = "📶 100% "
	if font_mono: battery_lbl.add_theme_font_override("font", font_mono)
	battery_lbl.add_theme_font_size_override("font_size", 6)
	battery_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 0.8))
	status_hbox.add_child(battery_lbl)

	# 2. Contact header
	var header_panel := PanelContainer.new()
	var h_style := StyleBoxFlat.new()
	h_style.bg_color = Color(0.12, 0.15, 0.22, 0.95)
	h_style.border_width_bottom = 1
	h_style.border_color = Color(0.25, 0.30, 0.40, 0.8)
	h_style.content_margin_left = 4.0
	h_style.content_margin_right = 4.0
	h_style.content_margin_top = 2.0
	h_style.content_margin_bottom = 2.0
	header_panel.add_theme_stylebox_override("panel", h_style)
	phone_vbox.add_child(header_panel)

	var contact_hbox := HBoxContainer.new()
	contact_hbox.add_theme_constant_override("separation", 6)
	header_panel.add_child(contact_hbox)

	phone_thumb_frame = PanelContainer.new()
	phone_thumb_frame.name = "PhoneThumbFrame"
	phone_thumb_frame.custom_minimum_size = Vector2(22, 22)
	phone_thumb_frame.size = Vector2(22, 22)
	phone_thumb_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	phone_thumb_frame.clip_contents = true
	var th_style := StyleBoxFlat.new()
	th_style.bg_color = Color(0.72, 0.20, 0.20, 0.95)
	th_style.border_width_left = 1
	th_style.border_width_top = 1
	th_style.border_width_right = 1
	th_style.border_width_bottom = 1
	th_style.border_color = Color(0.95, 0.88, 0.88, 1.0)
	th_style.corner_radius_top_left = 11
	th_style.corner_radius_top_right = 11
	th_style.corner_radius_bottom_right = 11
	th_style.corner_radius_bottom_left = 11
	phone_thumb_frame.add_theme_stylebox_override("panel", th_style)
	contact_hbox.add_child(phone_thumb_frame)

	# Strip skin tone modifier to fix emoji block glitch (pure base 👧)
	var mesa_thumb := TextureRect.new()
	mesa_thumb.name = "MesaThumb"
	mesa_thumb.custom_minimum_size = Vector2(18, 18)
	mesa_thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mesa_thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mesa_thumb.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	mesa_thumb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mesa_thumb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var port_path := "res://assets/images/portraits/portrait_mesa.png"
	if ResourceLoader.exists(port_path):
		mesa_thumb.texture = load(port_path)
	phone_thumb_frame.add_child(mesa_thumb)
	phone_contact_avatar = mesa_thumb

	var contact_vbox := VBoxContainer.new()
	contact_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contact_vbox.add_theme_constant_override("separation", 0)
	contact_hbox.add_child(contact_vbox)

	phone_header_title = Label.new()
	phone_header_title.text = "เมษา"
	if font_thai_bold: phone_header_title.add_theme_font_override("font", font_thai_bold)
	phone_header_title.add_theme_font_size_override("font_size", 7)
	phone_header_title.add_theme_color_override("font_color", Color.WHITE)
	contact_vbox.add_child(phone_header_title)

	phone_header_sub = Label.new()
	phone_header_sub.text = "Mesasohot131415"
	if font_mono: phone_header_sub.add_theme_font_override("font", font_mono)
	phone_header_sub.add_theme_font_size_override("font_size", 5)
	phone_header_sub.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85, 0.8))
	contact_vbox.add_child(phone_header_sub)

	phone_close_btn = Button.new()
	phone_close_btn.text = "✕"
	phone_close_btn.custom_minimum_size = Vector2(16, 16)
	phone_close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	phone_close_btn.add_theme_font_size_override("font_size", 7)
	phone_close_btn.pressed.connect(_close_phone)
	contact_hbox.add_child(phone_close_btn)

	# 3. Chat scroll list
	# Slim down chat VScrollBar to minimal width
	phone_chat_scroll = ScrollContainer.new()
	phone_chat_scroll.name = "PhoneChatScroll"
	phone_chat_scroll.custom_minimum_size = Vector2(0, 168)
	phone_chat_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phone_chat_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	phone_chat_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_style_slim_scrollbar(phone_chat_scroll)
	phone_vbox.add_child(phone_chat_scroll)

	# Adjust right padding for message bubbles
	var chat_margin := MarginContainer.new()
	chat_margin.name = "ChatMargin"
	chat_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chat_margin.add_theme_constant_override("margin_left", 2)
	chat_margin.add_theme_constant_override("margin_right", 5)
	chat_margin.add_theme_constant_override("margin_top", 2)
	chat_margin.add_theme_constant_override("margin_bottom", 2)
	phone_chat_scroll.add_child(chat_margin)

	phone_messages_vbox = VBoxContainer.new()
	phone_messages_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phone_messages_vbox.add_theme_constant_override("separation", 4)
	chat_margin.add_child(phone_messages_vbox)

	var date_lbl := Label.new()
	date_lbl.text = "— วันนี้ (Today) —"
	if font_thai: date_lbl.add_theme_font_override("font", font_thai)
	date_lbl.add_theme_font_size_override("font_size", 5)
	date_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.8))
	date_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phone_messages_vbox.add_child(date_lbl)

	for msg in MESA_MESSAGES:
		_create_chat_bubble(msg["time"], msg["text"])

	# 4. Bottom hint
	var footer_panel := PanelContainer.new()
	var foot_style := StyleBoxFlat.new()
	foot_style.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	foot_style.content_margin_top = 2.0
	foot_style.content_margin_bottom = 2.0
	footer_panel.add_theme_stylebox_override("panel", foot_style)
	phone_vbox.add_child(footer_panel)

	var hint_lbl := Label.new()
	hint_lbl.text = "กด [P], [ESC] หรือคลิก [✕] เพื่อปิด"
	if font_thai: hint_lbl.add_theme_font_override("font", font_thai)
	hint_lbl.add_theme_font_size_override("font_size", 5)
	hint_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 0.7))
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_panel.add_child(hint_lbl)

func _create_chat_bubble(time_str: String, msg_text: String) -> void:
	var bubble_panel := PanelContainer.new()
	bubble_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var b_style := StyleBoxFlat.new()
	b_style.bg_color = Color(0.18, 0.22, 0.32, 0.95)
	b_style.border_width_left = 1
	b_style.border_width_top = 1
	b_style.border_width_right = 1
	b_style.border_width_bottom = 1
	b_style.border_color = Color(0.3, 0.38, 0.5, 0.8)
	b_style.corner_radius_top_left = 2
	b_style.corner_radius_top_right = 6
	b_style.corner_radius_bottom_right = 6
	b_style.corner_radius_bottom_left = 6
	b_style.content_margin_left = 6.0
	b_style.content_margin_right = 6.0
	b_style.content_margin_top = 3.0
	b_style.content_margin_bottom = 3.0
	bubble_panel.add_theme_stylebox_override("panel", b_style)
	phone_messages_vbox.add_child(bubble_panel)

	var b_vbox := VBoxContainer.new()
	b_vbox.add_theme_constant_override("separation", 1)
	bubble_panel.add_child(b_vbox)

	var txt_lbl := Label.new()
	txt_lbl.text = msg_text
	if font_thai: txt_lbl.add_theme_font_override("font", font_thai)
	txt_lbl.add_theme_font_size_override("font_size", 6)
	txt_lbl.add_theme_color_override("font_color", Color.WHITE)
	txt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt_lbl.custom_minimum_size = Vector2(118, 0)
	b_vbox.add_child(txt_lbl)

	var time_lbl := Label.new()
	time_lbl.text = time_str
	if font_mono: time_lbl.add_theme_font_override("font", font_mono)
	time_lbl.add_theme_font_size_override("font_size", 5)
	time_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.6))
	time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	b_vbox.add_child(time_lbl)

# Slim down chat VScrollBar to minimal width
func _style_slim_scrollbar(scroll: ScrollContainer) -> void:
	if not scroll:
		return
	var v_bar: VScrollBar = scroll.get_v_scroll_bar()
	if not v_bar:
		return

	v_bar.custom_minimum_size.x = 3.0

	# Transparent track: removes the wide opaque background track
	var empty_track := StyleBoxEmpty.new()
	v_bar.add_theme_stylebox_override("scroll", empty_track)
	v_bar.add_theme_stylebox_override("scroll_focus", empty_track)

	# Faint, thin translucent grabber (subtle pixel-art aesthetic)
	var grabber_normal := StyleBoxFlat.new()
	grabber_normal.bg_color = Color(0.65, 0.72, 0.85, 0.28)
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

# May thought monologue
func _setup_thought_bubble() -> void:
	thought_bubble = PanelContainer.new()
	thought_bubble.name = "ThoughtBubble"
	thought_bubble.position = Vector2(40, 105)
	thought_bubble.custom_minimum_size = Vector2(180, 32)
	thought_bubble.visible = false
	thought_bubble.add_theme_stylebox_override("panel", _create_menu_stylebox(0.92, 4))
	canvas_layer.add_child(thought_bubble)

	thought_label = Label.new()
	thought_label.text = "เมย์: จริงๆ แล้วฉันยังไม่ได้เริ่มแก้อะไรนั่นเลย... เมษาคงรอไหว"
	if font_thai: thought_label.add_theme_font_override("font", font_thai)
	thought_label.add_theme_font_size_override("font_size", 6)
	thought_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.82, 1.0))
	thought_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	thought_bubble.add_child(thought_label)

# Inspection narration box for room objects (Matching Scene 1 dialogue style)
func _setup_dialogue_box() -> void:
	dialogue_box = PanelContainer.new()
	dialogue_box.name = "RoomDialogueBox"
	dialogue_box.position = Vector2(14, 192)
	dialogue_box.custom_minimum_size = Vector2(452, 68)
	dialogue_box.size = Vector2(452, 68)
	dialogue_box.visible = false

	# Style identical to Scene 1: Dark Navy #0E152B with Cream border #E0C097
	var box_style := StyleBoxFlat.new()
	box_style.bg_color = Color(0.05, 0.08, 0.17, 0.96)
	box_style.border_width_left = 2
	box_style.border_width_top = 2
	box_style.border_width_right = 2
	box_style.border_width_bottom = 2
	box_style.border_color = Color(0.88, 0.74, 0.58, 1.0)
	box_style.corner_radius_top_left = 4
	box_style.corner_radius_top_right = 4
	box_style.corner_radius_bottom_right = 4
	box_style.corner_radius_bottom_left = 4
	box_style.content_margin_left = 10.0
	box_style.content_margin_right = 10.0
	box_style.content_margin_top = 6.0
	box_style.content_margin_bottom = 6.0
	dialogue_box.add_theme_stylebox_override("panel", box_style)
	canvas_layer.add_child(dialogue_box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	dialogue_box.add_child(vbox)

	dialogue_title = Label.new()
	dialogue_title.name = "DialogueTitle"
	if font_thai_bold: dialogue_title.add_theme_font_override("font", font_thai_bold)
	dialogue_title.add_theme_font_size_override("font_size", 8)
	dialogue_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.55, 1.0))
	vbox.add_child(dialogue_title)

	dialogue_text = Label.new()
	dialogue_text.name = "DialogueText"
	if font_thai: dialogue_text.add_theme_font_override("font", font_thai)
	dialogue_text.add_theme_font_size_override("font_size", 7)
	dialogue_text.add_theme_color_override("font_color", Color.WHITE)
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(dialogue_text)

	var foot_lbl := Label.new()
	foot_lbl.text = "[ Spacebar / เดินออก เพื่อปิด ]"
	if font_thai: foot_lbl.add_theme_font_override("font", font_thai)
	foot_lbl.add_theme_font_size_override("font_size", 6)
	foot_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 0.6))
	foot_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(foot_lbl)

# Screen fader for smooth scene transitions
func _setup_screen_fader() -> void:
	screen_fader = ColorRect.new()
	screen_fader.name = "ScreenFader"
	screen_fader.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_fader.color = Color.BLACK
	screen_fader.modulate.a = 0.0
	screen_fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(screen_fader)

# Pulse tween for notification badge
func _start_badge_pulse() -> void:
	if not notif_badge_circle:
		return
	notif_pulse_tween = create_tween().set_loops()
	notif_pulse_tween.tween_property(notif_badge_circle, "scale", Vector2(1.18, 1.18), 0.3).set_trans(Tween.TRANS_SINE)
	notif_pulse_tween.tween_property(notif_badge_circle, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)
	notif_pulse_tween.tween_interval(1.4)

# Movement tracker loop for State 3
func _physics_process(delta: float) -> void:
	if current_state != TutorialState.STATE_3_MOVEMENT_GUIDE or not player_node:
		return

	# Highlight WASD keys dynamically when pressed
	var is_w := Input.is_action_pressed("Up") or Input.is_key_pressed(KEY_W)
	var is_a := Input.is_action_pressed("Left") or Input.is_key_pressed(KEY_A)
	var is_s := Input.is_action_pressed("Down") or Input.is_key_pressed(KEY_S)
	var is_d := Input.is_action_pressed("Right") or Input.is_key_pressed(KEY_D)

	if wasd_key_panels.has("W"):
		wasd_key_panels["W"].add_theme_stylebox_override("panel", _create_keycap_stylebox(is_w))
	if wasd_key_panels.has("A"):
		wasd_key_panels["A"].add_theme_stylebox_override("panel", _create_keycap_stylebox(is_a))
	if wasd_key_panels.has("S"):
		wasd_key_panels["S"].add_theme_stylebox_override("panel", _create_keycap_stylebox(is_s))
	if wasd_key_panels.has("D"):
		wasd_key_panels["D"].add_theme_stylebox_override("panel", _create_keycap_stylebox(is_d))

	if player_node.velocity.length() > 5.0:
		moved_distance += player_node.velocity.length() * delta

		if is_w: directions_pressed["W"] = true
		if is_a: directions_pressed["A"] = true
		if is_s: directions_pressed["S"] = true
		if is_d: directions_pressed["D"] = true

		var all_dirs: bool = bool(directions_pressed["W"]) and bool(directions_pressed["A"]) and bool(directions_pressed["S"]) and bool(directions_pressed["D"])
		if all_dirs or moved_distance >= 60.0:
			_complete_movement_tutorial()

func _complete_movement_tutorial() -> void:
	movement_completed.emit()
	_play_success_chime()
	# Transition from State 3 -> State 5 (First Task appear)
	_set_state(TutorialState.STATE_5_FIRST_TASK_DESKTOP)

# Input handling: [P] phone toggle, [ESC] close phone, [Space] interact with room object
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P:
			_toggle_phone()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and is_phone_open:
			_close_phone()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE and not is_phone_open:
			if dialogue_box and dialogue_box.visible:
				_dismiss_dialogue()
				get_viewport().set_input_as_handled()
			elif active_interactable != InteractableType.NONE:
				_interact_with_current_object()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F9:
			# Quick toggle between Scene 2 Tutorial and Scene 4 Investigation Intro
			_toggle_scene_mode()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F10:
			# Quick-skip current objective
			if is_scene_4_active and not is_notebook_picked_up:
				_pickup_notebook()
				get_viewport().set_input_as_handled()

func _on_notification_badge_pressed() -> void:
	if current_state == TutorialState.STATE_1_MOBILE_PROMPT or is_phone_open:
		_toggle_phone()

func _toggle_phone() -> void:
	if is_phone_open:
		_close_phone()
	else:
		_open_phone()

# State 2: Open phone modal
func _open_phone() -> void:
	if is_phone_open:
		return
	is_phone_open = true

	# Play open chirp
	_play_sfx(660.0, 0.08)

	# Clear unread badge after viewing phone
	if not has_read_messages:
		has_read_messages = true
		_clear_notification_badge()

	# Freeze player movement while phone is open
	if player_node:
		player_node.set_physics_process(false)
		player_node.velocity = Vector2.ZERO
		var sprite := player_node.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
		if sprite and player_node.has_method("AnimatedDirection"):
			sprite.play("Idle_" + player_node.AnimatedDirection())

	# Dim background on phone open (40% opacity black)
	if phone_dimmer:
		phone_dimmer.visible = true
		phone_dimmer.modulate.a = 0.0
		var dt := create_tween()
		dt.tween_property(phone_dimmer, "modulate:a", 1.0, 0.15)

	# Pop up smartphone modal
	if phone_modal:
		phone_modal.visible = true
		phone_modal.scale = Vector2(0.9, 0.9)
		var t := create_tween()
		t.tween_property(phone_modal, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_update_hud_panel()
	phone_opened.emit()
	_scroll_phone_to_bottom()

# Close phone & advance to State 3
func _close_phone() -> void:
	if not is_phone_open:
		return
	is_phone_open = false

	# Play close click
	_play_sfx(440.0, 0.06)

	if phone_modal:
		phone_modal.visible = false

	# Fade out background dimmer on phone close
	if phone_dimmer:
		var dt := create_tween()
		dt.tween_property(phone_dimmer, "modulate:a", 0.0, 0.12)
		dt.finished.connect(_on_phone_dimmer_fade_finished)

	# Resume player movement
	if player_node:
		player_node.set_physics_process(true)

	phone_closed.emit()

	# Transition from State 1/2 -> State 3 (Movement) on first close in Scene 2
	if not is_scene_4_active and (current_state == TutorialState.STATE_1_MOBILE_PROMPT or current_state == TutorialState.STATE_2_MOBILE_CHAT):
		_set_state(TutorialState.STATE_3_MOVEMENT_GUIDE)
		if not has_shown_first_thought:
			has_shown_first_thought = true
			_show_thought_bubble()

	_update_hud_panel()

func _clear_notification_badge() -> void:
	if notif_pulse_tween and notif_pulse_tween.is_valid():
		notif_pulse_tween.kill()
	if notif_badge_circle:
		var t := create_tween()
		t.tween_property(notif_badge_circle, "scale", Vector2.ZERO, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		t.finished.connect(_on_notif_badge_fade_finished)

func _show_thought_bubble() -> void:
	if not thought_bubble:
		return
	thought_bubble.visible = true
	thought_bubble.modulate.a = 0.0
	if thought_tween and thought_tween.is_valid():
		thought_tween.kill()
	thought_tween = create_tween()
	thought_tween.tween_property(thought_bubble, "modulate:a", 1.0, 0.3)
	thought_tween.tween_interval(3.5)
	thought_tween.tween_property(thought_bubble, "modulate:a", 0.0, 0.5)
	thought_tween.finished.connect(_on_thought_bubble_fade_finished)

# State 4 & 5: Object inspection logic
func _interact_with_current_object() -> void:
	if is_scene_4_active:
		match active_interactable:
			InteractableType.BOOKSHELF_LOWER:
				if not is_notebook_picked_up:
					_pickup_notebook()
				else:
					_show_dialogue(
						"ชั้นหนังสือ (ชั้นล่าง)",
						"ตู้เก็บของที่หยิบเครื่องเต่าดำออกมาแล้ว ตอนนี้เหลือแต่คู่มือและเอกสารชมรม"
					)
					_play_inspect_click()
			InteractableType.DESKTOP:
				if not is_notebook_picked_up:
					_show_dialogue(
						"โต๊ะคอมพิวเตอร์",
						"คอมเครื่องนี้โดนไวรัสเรียกค่าไถ่และถูกตัดเน็ตอยู่... พี่มาร์ชบอกให้ไปหยิบโน้ตบุ๊กเต่าดำในตู้มาก่อน"
					)
				else:
					_show_dialogue(
						"โน้ตบุ๊กเต่าดำบนโต๊ะคอม",
						"นำโน้ตบุ๊กเต่าดำมาวางเตรียมไว้บนโต๊ะแล้ว พร้อมเริ่มขั้นตอนตรวจสอบและกู้คืนไฟล์ร่วมกับพี่มาร์ช!"
					)
				_play_inspect_click()
			InteractableType.BOOKSHELF_UPPER:
				_show_dialogue(
					"ชั้นหนังสือ (ชั้นบน)",
					"มี Flash Drive สีดำวางอยู่ข้างหนังสือ... เดี๋ยวอาจต้องใช้เซฟไฟล์หลักฐาน"
				)
				_play_inspect_click()
			InteractableType.WINDOW:
				_show_dialogue(
					"หน้าต่างห้อง",
					"มองออกไปเห็นแสงไฟยามค่ำคืน... ตอนนี้ 21:25 น. แล้ว ต้องรีบหาสาเหตุและกู้คืนไฟล์ให้ทัน"
				)
				_play_inspect_click()
			InteractableType.DRAWER:
				_show_dialogue(
					"ลิ้นชักข้างเตียง",
					"มีสายชาร์จสำรองและอุปกรณ์เสริมต่างๆ เก็บอยู่อย่างเรียบร้อย"
				)
				_play_inspect_click()
			InteractableType.SPEAKER:
				_toggle_speaker()
		return

	match active_interactable:
		InteractableType.DESKTOP:
			_interact_with_desktop()
		InteractableType.SPEAKER:
			_toggle_speaker()
		InteractableType.BOOKSHELF_UPPER:
			_show_dialogue(
				"ชั้นหนังสือ (ชั้นบน)",
				"มี Flash Drive สีดำวางอยู่ข้างหนังสือ... เอาไว้สำรองงานสำคัญและเอกสารโครงงาน"
			)
			_play_inspect_click()
			object_inspected.emit("Bookshelf_Upper")
		InteractableType.BOOKSHELF_LOWER:
			_show_dialogue(
				"ชั้นหนังสือ (ชั้นล่าง)",
				"มีสมุดเลกเชอร์วิชา Computer Security จดโน้ตสรุปเรื่องมัลแวร์ การสำรองข้อมูล และการตรวจจับภัยคุกคามไว้เพียบ"
			)
			_play_inspect_click()
			object_inspected.emit("Bookshelf_Lower")
		InteractableType.WINDOW:
			_show_dialogue(
				"หน้าต่างห้อง",
				"มองออกไปเห็นท้องฟ้ายามค่ำคืนและแสงไฟจากตึกข้างนอก... คืนนี้อากาศค่อนข้างเย็น เหมาะกับการนั่งปั่นงานยาวๆ"
			)
			_play_inspect_click()
			object_inspected.emit("Window")
		InteractableType.DRAWER:
			_show_dialogue(
				"ลิ้นชักข้างเตียง",
				"มีสายชาร์จสำรอง หูฟัง และกองกระดาษโน้ตเก่าๆ วางอยู่อย่างเป็นระเบียบ"
			)
			_play_inspect_click()
			object_inspected.emit("Drawer")

# Toggle bedroom BGM mute/unmute
func _toggle_speaker() -> void:
	is_bgm_muted = not is_bgm_muted
	if bgm_player:
		bgm_player.volume_db = -80.0 if is_bgm_muted else -14.0

	_play_sfx(520.0, 0.08)
	if is_bgm_muted:
		_show_dialogue("ลำโพงตั้งโต๊ะ", "ปิดเสียงเพลงแล้ว ห้องเงียบสงัด เหมาะกับสมาธิตอนนี้")
	else:
		_show_dialogue("ลำโพงตั้งโต๊ะ", "เปิดเพลงคลอเบาๆ เมโลดี้ Lofi ช่วยให้ผ่อนคลายขึ้นเยอะ")
	object_inspected.emit("Speaker")

# State 5: Task 1 - Go to Desktop transition (Image 20)
func _interact_with_desktop() -> void:
	is_task_1_completed = true
	_update_hud_panel()
	_play_success_chime()
	desktop_task_completed.emit()

	# Lock player movement
	if player_node:
		player_node.set_physics_process(false)
		player_node.velocity = Vector2.ZERO

	# Fade to black transition
	if screen_fader:
		screen_fader.visible = true
		var t := create_tween()
		t.tween_property(screen_fader, "modulate:a", 1.0, 0.45)
		t.finished.connect(_transition_to_desktop_scene)
	else:
		_transition_to_desktop_scene()

func _transition_to_desktop_scene() -> void:
	if has_node("/root/SceneRouter"):
		SceneRouter.goto_scene_2_desktop()
	elif ResourceLoader.exists(DESKTOP_SCENE_PATH):
		if is_inside_tree() and get_tree():
			get_tree().change_scene_to_file(DESKTOP_SCENE_PATH)
	else:
		push_error("Desktop scene not found: " + DESKTOP_SCENE_PATH)

# Display inspection dialogue box (Matching Scene 1 style)
func _show_dialogue(title: String, text: String) -> void:
	if not dialogue_box:
		return
	dialogue_title.text = "[ " + title + " ]"
	dialogue_text.text = text
	dialogue_box.visible = true
	dialogue_box.modulate.a = 0.0

	if dialogue_tween and dialogue_tween.is_valid():
		dialogue_tween.kill()
	dialogue_tween = create_tween()
	dialogue_tween.tween_property(dialogue_box, "modulate:a", 1.0, 0.15)
	dialogue_tween.tween_interval(4.5)
	dialogue_tween.tween_property(dialogue_box, "modulate:a", 0.0, 0.3)
	dialogue_tween.finished.connect(_on_dialogue_fade_finished)

func _dismiss_dialogue() -> void:
	if dialogue_box and dialogue_box.visible:
		if dialogue_tween and dialogue_tween.is_valid():
			dialogue_tween.kill()
		dialogue_tween = create_tween()
		dialogue_tween.tween_property(dialogue_box, "modulate:a", 0.0, 0.15)
		dialogue_tween.finished.connect(_on_dialogue_fade_finished)

func _on_phone_dimmer_fade_finished() -> void:
	if phone_dimmer:
		phone_dimmer.visible = false

func _on_notif_badge_fade_finished() -> void:
	if notif_badge_circle:
		notif_badge_circle.visible = false

func _on_thought_bubble_fade_finished() -> void:
	if thought_bubble:
		thought_bubble.visible = false

func _on_dialogue_fade_finished() -> void:
	if dialogue_box:
		dialogue_box.visible = false

# --- Procedural Audio Synthesizers ---
func _play_sfx(freq: float, duration: float) -> void:
	if not sfx_player:
		return
	var sample_rate: int = 22050
	var sample_count: int = int(float(sample_rate) * duration)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var val: float = sin(2.0 * PI * freq * t)
		var env: float = 1.0 - (float(i) / float(sample_count))
		var byte_val: int = int(clampf(128.0 + (val * env * 50.0), 0.0, 255.0))
		data[i] = byte_val

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _play_inspect_click() -> void:
	_play_sfx(880.0, 0.05)

func _play_success_chime() -> void:
	if not sfx_player:
		return
	var sample_rate: int = 22050
	var duration: float = 0.4
	var sample_count: int = int(float(sample_rate) * duration)
	var data := PackedByteArray()
	data.resize(sample_count)

	var freqs: Array[float] = [523.25, 659.25, 783.99, 1046.50] # C5, E5, G5, C6
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var step_idx: int = int(t / (duration / float(freqs.size())))
		step_idx = mini(step_idx, freqs.size() - 1)
		var freq: float = freqs[step_idx]
		var val: float = sin(2.0 * PI * freq * t)
		var env: float = 1.0 - (float(i) / float(sample_count))
		data[i] = int(clampf(128.0 + (val * env * 45.0), 0.0, 255.0))

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

func _generate_lofi_bgm_stream() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD

	var sample_count: int = 22050 * 4
	var data := PackedByteArray()
	data.resize(sample_count)

	var notes: Array[float] = [261.63, 329.63, 392.00, 493.88, 220.00, 261.63, 329.63, 392.00]
	for i in range(sample_count):
		var t: float = float(i) / 22050.0
		var note_idx: int = int(t * 2.0) % notes.size()
		var freq: float = notes[note_idx]
		var val: float = sin(2.0 * PI * freq * t) * 0.35 + sin(2.0 * PI * (freq * 0.5) * t) * 0.15
		var env: float = clampf(sin(PI * fmod(t * 2.0, 1.0)), 0.1, 1.0)
		data[i] = int(clampf(128.0 + (val * env * 40.0), 0.0, 255.0))

	wav.data = data
	wav.loop_begin = 0
	wav.loop_end = sample_count
	return wav

# --- Scene 4: Investigation Intro Systems ---

# Configure bedroom for Scene 4: Investigation Intro
func _setup_scene_4_mode() -> void:
	is_scene_4_active = true
	is_notebook_picked_up = false
	has_read_messages = false

	# Unlock player movement immediately
	if player_node:
		player_node.set_physics_process(true)

	# 1. Update Notification Button for March (+1 badge and chime)
	if notif_badge_btn and is_instance_valid(notif_badge_btn):
		notif_badge_btn.visible = true

	# Update avatar to March
	if avatar_panel and is_instance_valid(avatar_panel):
		var av_style := StyleBoxFlat.new()
		av_style.bg_color = Color(0.20, 0.40, 0.70, 0.95) # March Theme Blue
		av_style.border_width_left = 2
		av_style.border_width_top = 2
		av_style.border_width_right = 2
		av_style.border_width_bottom = 2
		av_style.border_color = Color(0.85, 0.92, 1.0, 1.0)
		av_style.corner_radius_top_left = 16
		av_style.corner_radius_top_right = 16
		av_style.corner_radius_bottom_right = 16
		av_style.corner_radius_bottom_left = 16
		avatar_panel.add_theme_stylebox_override("panel", av_style)

	if avatar_rect and is_instance_valid(avatar_rect):
		var march_portrait_path := "res://assets/images/portraits/portrait_march.png"
		if ResourceLoader.exists(march_portrait_path):
			avatar_rect.texture = load(march_portrait_path)

	# Configure Badge: red +1
	if notif_badge_circle and is_instance_valid(notif_badge_circle):
		notif_badge_circle.visible = true
		notif_badge_circle.scale = Vector2.ONE
	if notif_badge_label and is_instance_valid(notif_badge_label):
		notif_badge_label.text = "+1"

	# Notification chime SFX & gentle pulsing badge
	_play_notification_chime()
	_start_badge_pulse()

	# 2. Setup Speech Bubble hint for picking up club notebook
	_setup_speech_bubble_hint()
	_setup_cabinet_highlight()
	_setup_cabinet_marker()
	_setup_desk_notebook_sprite()

	if is_notebook_picked_up:
		if cabinet_highlight and is_instance_valid(cabinet_highlight):
			cabinet_highlight.visible = false
		if cabinet_marker and is_instance_valid(cabinet_marker):
			cabinet_marker.visible = false
		if desk_notebook_sprite and is_instance_valid(desk_notebook_sprite):
			desk_notebook_sprite.visible = true
			desk_notebook_sprite.modulate.a = 1.0
	else:
		if desk_notebook_sprite and is_instance_valid(desk_notebook_sprite):
			desk_notebook_sprite.visible = false

	# 3. Configure phone messages for March
	_configure_phone_for_march()

	# 4. Update HUD
	_update_hud_panel()

# Revert to Scene 2 tutorial mode
func _setup_scene_2_mode() -> void:
	is_scene_4_active = false
	is_notebook_picked_up = false
	has_read_messages = false

	_hide_hint_speech_bubble()
	if cabinet_highlight and is_instance_valid(cabinet_highlight):
		if cabinet_highlight_tween and cabinet_highlight_tween.is_valid():
			cabinet_highlight_tween.kill()
		cabinet_highlight.queue_free()
		cabinet_highlight = null

	if cabinet_marker and is_instance_valid(cabinet_marker):
		if cabinet_tween and cabinet_tween.is_valid():
			cabinet_tween.kill()
		cabinet_marker.queue_free()
		cabinet_marker = null

	if desk_notebook_sprite and is_instance_valid(desk_notebook_sprite):
		desk_notebook_sprite.visible = false

	if player_node:
		player_node.set_physics_process(false)

	if avatar_panel and is_instance_valid(avatar_panel):
		var av_style := StyleBoxFlat.new()
		av_style.bg_color = Color(0.72, 0.20, 0.20, 0.95)
		av_style.border_width_left = 2
		av_style.border_width_top = 2
		av_style.border_width_right = 2
		av_style.border_width_bottom = 2
		av_style.border_color = Color(0.95, 0.88, 0.88, 1.0)
		av_style.corner_radius_top_left = 16
		av_style.corner_radius_top_right = 16
		av_style.corner_radius_bottom_right = 16
		av_style.corner_radius_bottom_left = 16
		avatar_panel.add_theme_stylebox_override("panel", av_style)

	if avatar_rect and is_instance_valid(avatar_rect):
		var mesa_path := "res://assets/images/portraits/portrait_mesa.png"
		if ResourceLoader.exists(mesa_path):
			avatar_rect.texture = load(mesa_path)

	if notif_badge_circle and is_instance_valid(notif_badge_circle):
		notif_badge_circle.visible = true
		notif_badge_circle.scale = Vector2.ONE
	if notif_badge_label and is_instance_valid(notif_badge_label):
		notif_badge_label.text = "+4"

	_start_badge_pulse()
	_configure_phone_for_mesa()
	_apply_state(TutorialState.STATE_1_MOBILE_PROMPT)

func _toggle_scene_mode() -> void:
	is_scene_4_active = not is_scene_4_active
	scene_mode_switched.emit(is_scene_4_active)
	if is_scene_4_active:
		_setup_scene_4_mode()
	else:
		_setup_scene_2_mode()

# Speech Bubble floating above May's head with bobbing tween
func _setup_speech_bubble_hint() -> void:
	if not player_node:
		return
	if speech_bubble_hint and is_instance_valid(speech_bubble_hint):
		speech_bubble_hint.queue_free()

	speech_bubble_hint = Control.new()
	speech_bubble_hint.name = "SpeechBubbleHint"
	speech_bubble_hint.position = Vector2(-52, -44)
	speech_bubble_hint.z_index = 20

	var panel := PanelContainer.new()
	panel.name = "BubblePanel"

	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = Color(0.06, 0.10, 0.20, 0.95)
	bubble_style.border_width_left = 1
	bubble_style.border_width_top = 1
	bubble_style.border_width_right = 1
	bubble_style.border_width_bottom = 1
	bubble_style.border_color = Color(0.90, 0.78, 0.62, 1.0)
	bubble_style.corner_radius_top_left = 4
	bubble_style.corner_radius_top_right = 4
	bubble_style.corner_radius_bottom_right = 4
	bubble_style.corner_radius_bottom_left = 4
	bubble_style.content_margin_left = 6.0
	bubble_style.content_margin_right = 6.0
	bubble_style.content_margin_top = 3.0
	bubble_style.content_margin_bottom = 3.0
	panel.add_theme_stylebox_override("panel", bubble_style)
	speech_bubble_hint.add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 3)
	panel.add_child(hbox)

	var icon_lbl := Label.new()
	icon_lbl.text = "💭"
	icon_lbl.add_theme_font_size_override("font_size", 7)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_lbl)

	var hint_lbl := Label.new()
	hint_lbl.text = "โน้ตบุ๊กชมรมอยู่ในตู้..."
	if font_thai_bold:
		hint_lbl.add_theme_font_override("font", font_thai_bold)
	hint_lbl.add_theme_font_size_override("font_size", 7)
	hint_lbl.add_theme_color_override("font_color", Color(1.0, 0.94, 0.82, 1.0))
	hint_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(hint_lbl)

	var pointer := ColorRect.new()
	pointer.name = "TailPointer"
	pointer.size = Vector2(4, 3)
	pointer.color = Color(0.90, 0.78, 0.62, 1.0)
	pointer.position = Vector2(50, 16)
	speech_bubble_hint.add_child(pointer)

	player_node.add_child(speech_bubble_hint)

	if speech_bubble_tween and speech_bubble_tween.is_valid():
		speech_bubble_tween.kill()
	speech_bubble_tween = create_tween().set_loops()
	speech_bubble_tween.tween_property(speech_bubble_hint, "position:y", -48.0, 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	speech_bubble_tween.tween_property(speech_bubble_hint, "position:y", -42.0, 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Highlight club notebook shelf location (Purple glow outline matching storyboard)
func _setup_cabinet_highlight() -> void:
	if cabinet_highlight and is_instance_valid(cabinet_highlight):
		cabinet_highlight.queue_free()

	cabinet_highlight = PanelContainer.new()
	cabinet_highlight.name = "CabinetHighlight"
	cabinet_highlight.position = Vector2(397, 131)
	cabinet_highlight.custom_minimum_size = Vector2(42, 26)
	cabinet_highlight.size = Vector2(42, 26)
	cabinet_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cabinet_highlight.z_index = 2

	var glow_style := StyleBoxFlat.new()
	glow_style.bg_color = Color(0.70, 0.40, 1.0, 0.16) # Faint translucent purple fill
	glow_style.border_width_left = 2
	glow_style.border_width_top = 2
	glow_style.border_width_right = 2
	glow_style.border_width_bottom = 2
	glow_style.border_color = Color(0.82, 0.50, 1.0, 0.95) # Vibrant glowing purple border
	glow_style.corner_radius_top_left = 2
	glow_style.corner_radius_top_right = 2
	glow_style.corner_radius_bottom_right = 2
	glow_style.corner_radius_bottom_left = 2
	cabinet_highlight.add_theme_stylebox_override("panel", glow_style)

	add_child(cabinet_highlight)

	# Glow pulse tween
	if cabinet_highlight_tween and cabinet_highlight_tween.is_valid():
		cabinet_highlight_tween.kill()
	cabinet_highlight_tween = create_tween().set_loops()
	cabinet_highlight_tween.tween_property(cabinet_highlight, "modulate:a", 0.45, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	cabinet_highlight_tween.tween_property(cabinet_highlight, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Reveal placed notebook sprite on computer desk
func _setup_desk_notebook_sprite() -> void:
	if desk_notebook_sprite and is_instance_valid(desk_notebook_sprite):
		return

	desk_notebook_sprite = Sprite2D.new()
	desk_notebook_sprite.name = "DeskNotebookTaoDam"
	var tex_path := "res://assets/images/items/laptop_taodam.png"
	if ResourceLoader.exists(tex_path):
		desk_notebook_sprite.texture = load(tex_path)
	desk_notebook_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	desk_notebook_sprite.position = Vector2(234, 115)
	desk_notebook_sprite.z_index = 2
	desk_notebook_sprite.visible = false
	add_child(desk_notebook_sprite)

# Floating marker above the notebook cabinet (Bookshelf lower)
func _setup_cabinet_marker() -> void:
	if cabinet_marker and is_instance_valid(cabinet_marker):
		cabinet_marker.queue_free()

	cabinet_marker = Node2D.new()
	cabinet_marker.name = "CabinetMarker"
	cabinet_marker.position = Vector2(418, 122)
	cabinet_marker.z_index = 10

	var mark_panel := PanelContainer.new()
	mark_panel.position = Vector2(-26, -10)
	var m_style := StyleBoxFlat.new()
	m_style.bg_color = Color(0.12, 0.15, 0.28, 0.92)
	m_style.border_width_left = 1
	m_style.border_width_top = 1
	m_style.border_width_right = 1
	m_style.border_width_bottom = 1
	m_style.border_color = Color(0.82, 0.50, 1.0, 0.95) # Purple accent
	m_style.corner_radius_top_left = 3
	m_style.corner_radius_top_right = 3
	m_style.corner_radius_bottom_right = 3
	m_style.corner_radius_bottom_left = 3
	m_style.content_margin_left = 4.0
	m_style.content_margin_right = 4.0
	m_style.content_margin_top = 1.0
	m_style.content_margin_bottom = 1.0
	mark_panel.add_theme_stylebox_override("panel", m_style)

	var mark_lbl := Label.new()
	mark_lbl.text = "🔻 โน้ตบุ๊กชมรม [Space]"
	if font_thai:
		mark_lbl.add_theme_font_override("font", font_thai)
	mark_lbl.add_theme_font_size_override("font_size", 6)
	mark_lbl.add_theme_color_override("font_color", Color(0.88, 0.70, 1.0, 1.0))
	mark_panel.add_child(mark_lbl)
	cabinet_marker.add_child(mark_panel)

	add_child(cabinet_marker)

	if cabinet_tween and cabinet_tween.is_valid():
		cabinet_tween.kill()
	cabinet_tween = create_tween().set_loops()
	cabinet_tween.tween_property(cabinet_marker, "position:y", 119.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	cabinet_tween.tween_property(cabinet_marker, "position:y", 123.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Dismiss speech bubble, cabinet marker, and highlight
func _hide_hint_speech_bubble() -> void:
	if speech_bubble_tween and speech_bubble_tween.is_valid():
		speech_bubble_tween.kill()
	if speech_bubble_hint and is_instance_valid(speech_bubble_hint):
		var tw := create_tween()
		tw.tween_property(speech_bubble_hint, "modulate:a", 0.0, 0.2)
		tw.finished.connect(func():
			if is_instance_valid(speech_bubble_hint):
				speech_bubble_hint.visible = false
		)
	if cabinet_tween and cabinet_tween.is_valid():
		cabinet_tween.kill()
	if cabinet_marker and is_instance_valid(cabinet_marker):
		var ctw := create_tween()
		ctw.tween_property(cabinet_marker, "modulate:a", 0.0, 0.2)
		ctw.finished.connect(func():
			if is_instance_valid(cabinet_marker):
				cabinet_marker.visible = false
		)
	if cabinet_highlight_tween and cabinet_highlight_tween.is_valid():
		cabinet_highlight_tween.kill()
	if cabinet_highlight and is_instance_valid(cabinet_highlight):
		var htw := create_tween()
		htw.tween_property(cabinet_highlight, "modulate:a", 0.0, 0.2)
		htw.finished.connect(func():
			if is_instance_valid(cabinet_highlight):
				cabinet_highlight.visible = false
		)

# Handle bookshelf interaction and item pickup
func _pickup_notebook() -> void:
	if not is_notebook_picked_up:
		is_notebook_picked_up = true
		_play_pickup_sfx()
		_hide_hint_speech_bubble()
		notebook_picked_up.emit()

		# Reveal placed notebook sprite on computer desk
		if desk_notebook_sprite and is_instance_valid(desk_notebook_sprite):
			desk_notebook_sprite.visible = true
			desk_notebook_sprite.position = Vector2(234, 109)
			desk_notebook_sprite.modulate.a = 0.0
			var d_tw := create_tween()
			d_tw.parallel().tween_property(desk_notebook_sprite, "modulate:a", 1.0, 0.25)
			d_tw.parallel().tween_property(desk_notebook_sprite, "position:y", 115.0, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

		# Update GameState
		var gs = get_tree().root.get_node_or_null("GameState")
		if gs:
			gs.set("is_notebook_picked_up", true)
			gs.set("has_club_notebook", true)
			gs.set("notebook_placed_on_desk", true)

		_show_dialogue(
			"โน้ตบุ๊กชมรม (เต่าดำ)",
			"เจอโน้ตบุ๊กชมรมแล้ว! เครื่องสีดำลายเต่า (เต่าดำ) นำไปวางเตรียมไว้ที่โต๊ะคอมเรียบร้อย พร้อมต่อสายตรวจสอบ"
		)
		_update_hud_panel()

# Procedural cabinet open and item pickup sound
func _play_pickup_sfx() -> void:
	if not sfx_player:
		return
	var sample_rate: int = 22050
	var duration: float = 0.45
	var sample_count: int = int(float(sample_rate) * duration)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var val: float = 0.0
		if t < 0.12:
			var creak_env = exp(-18.0 * t)
			val = sin(2.0 * PI * (130.0 + 80.0 * t) * t) * creak_env * 0.7
		else:
			var chime_t = t - 0.12
			var chime_env = exp(-8.0 * chime_t)
			var freq = 523.25 if chime_t < 0.14 else 783.99 # C5 -> G5
			val = (sin(2.0 * PI * freq * chime_t) * 0.7 + sin(2.0 * PI * (freq * 2.0) * chime_t) * 0.3) * chime_env
		data[i] = int(clampf(128.0 + (val * 45.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()

# Configure phone messages for March
func _configure_phone_for_march() -> void:
	if not phone_modal or not is_instance_valid(phone_modal):
		return

	if phone_time_lbl and is_instance_valid(phone_time_lbl):
		phone_time_lbl.text = " 21:25"

	if phone_header_title and is_instance_valid(phone_header_title):
		phone_header_title.text = "พี่มาร์ช"
	if phone_header_sub and is_instance_valid(phone_header_sub):
		phone_header_sub.text = "M4rchupikchu_inw101"

	if phone_thumb_frame and is_instance_valid(phone_thumb_frame):
		var th_style := StyleBoxFlat.new()
		th_style.bg_color = Color(0.20, 0.40, 0.70, 0.95)
		th_style.border_width_left = 1
		th_style.border_width_top = 1
		th_style.border_width_right = 1
		th_style.border_width_bottom = 1
		th_style.border_color = Color(0.85, 0.92, 1.0, 1.0)
		th_style.corner_radius_top_left = 11
		th_style.corner_radius_top_right = 11
		th_style.corner_radius_bottom_right = 11
		th_style.corner_radius_bottom_left = 11
		phone_thumb_frame.add_theme_stylebox_override("panel", th_style)

	if phone_contact_avatar and is_instance_valid(phone_contact_avatar):
		var march_portrait_path := "res://assets/images/portraits/portrait_march.png"
		if ResourceLoader.exists(march_portrait_path):
			phone_contact_avatar.texture = load(march_portrait_path)

	if phone_messages_vbox and is_instance_valid(phone_messages_vbox):
		for child in phone_messages_vbox.get_children():
			child.queue_free()

		var date_lbl := Label.new()
		date_lbl.text = "— วันนี้ (Today 21:25) —"
		if font_thai: date_lbl.add_theme_font_override("font", font_thai)
		date_lbl.add_theme_font_size_override("font_size", 5)
		date_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.8))
		date_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		phone_messages_vbox.add_child(date_lbl)

		for msg in MARCH_MESSAGES:
			var is_me: bool = (msg["sender"] == "Mayicomeinpls")
			_create_chat_bubble_styled(msg["time"], msg["text"], is_me)

# Configure phone messages for Mesa (Scene 2)
func _configure_phone_for_mesa() -> void:
	if not phone_modal or not is_instance_valid(phone_modal):
		return

	if phone_time_lbl and is_instance_valid(phone_time_lbl):
		phone_time_lbl.text = " 19:02"

	if phone_header_title and is_instance_valid(phone_header_title):
		phone_header_title.text = "เมษา"
	if phone_header_sub and is_instance_valid(phone_header_sub):
		phone_header_sub.text = "Mesasohot131415"

	if phone_thumb_frame and is_instance_valid(phone_thumb_frame):
		var th_style := StyleBoxFlat.new()
		th_style.bg_color = Color(0.72, 0.20, 0.20, 0.95)
		th_style.border_width_left = 1
		th_style.border_width_top = 1
		th_style.border_width_right = 1
		th_style.border_width_bottom = 1
		th_style.border_color = Color(0.95, 0.88, 0.88, 1.0)
		th_style.corner_radius_top_left = 11
		th_style.corner_radius_top_right = 11
		th_style.corner_radius_bottom_right = 11
		th_style.corner_radius_bottom_left = 11
		phone_thumb_frame.add_theme_stylebox_override("panel", th_style)

	if phone_contact_avatar and is_instance_valid(phone_contact_avatar):
		var mesa_path := "res://assets/images/portraits/portrait_mesa.png"
		if ResourceLoader.exists(mesa_path):
			phone_contact_avatar.texture = load(mesa_path)

	if phone_messages_vbox and is_instance_valid(phone_messages_vbox):
		for child in phone_messages_vbox.get_children():
			child.queue_free()

		var date_lbl := Label.new()
		date_lbl.text = "— วันนี้ (Today) —"
		if font_thai: date_lbl.add_theme_font_override("font", font_thai)
		date_lbl.add_theme_font_size_override("font_size", 5)
		date_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.8))
		date_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		phone_messages_vbox.add_child(date_lbl)

		for msg in MESA_MESSAGES:
			_create_chat_bubble(msg["time"], msg["text"])

# Creates chat bubbles with custom alignment and color (Scene 4)
func _create_chat_bubble_styled(time_str: String, msg_text: String, is_me: bool) -> void:
	var bubble_panel := PanelContainer.new()
	bubble_panel.size_flags_horizontal = Control.SIZE_SHRINK_END if is_me else Control.SIZE_SHRINK_BEGIN
	var b_style := StyleBoxFlat.new()
	if is_me:
		b_style.bg_color = Color(0.18, 0.38, 0.30, 0.95)
		b_style.border_color = Color(0.28, 0.55, 0.45, 0.8)
		b_style.corner_radius_top_left = 6
		b_style.corner_radius_top_right = 2
		b_style.corner_radius_bottom_right = 6
		b_style.corner_radius_bottom_left = 6
	else:
		b_style.bg_color = Color(0.16, 0.24, 0.38, 0.95)
		b_style.border_color = Color(0.28, 0.42, 0.60, 0.8)
		b_style.corner_radius_top_left = 2
		b_style.corner_radius_top_right = 6
		b_style.corner_radius_bottom_right = 6
		b_style.corner_radius_bottom_left = 6
	b_style.border_width_left = 1
	b_style.border_width_top = 1
	b_style.border_width_right = 1
	b_style.border_width_bottom = 1
	b_style.content_margin_left = 6.0
	b_style.content_margin_right = 6.0
	b_style.content_margin_top = 3.0
	b_style.content_margin_bottom = 3.0
	bubble_panel.add_theme_stylebox_override("panel", b_style)
	phone_messages_vbox.add_child(bubble_panel)

	var b_vbox := VBoxContainer.new()
	b_vbox.add_theme_constant_override("separation", 1)
	bubble_panel.add_child(b_vbox)

	var txt_lbl := Label.new()
	txt_lbl.text = msg_text
	if font_thai: txt_lbl.add_theme_font_override("font", font_thai)
	txt_lbl.add_theme_font_size_override("font_size", 6)
	txt_lbl.add_theme_color_override("font_color", Color.WHITE)
	txt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt_lbl.custom_minimum_size = Vector2(118, 0)
	b_vbox.add_child(txt_lbl)

	var time_lbl := Label.new()
	time_lbl.text = time_str
	if font_mono: time_lbl.add_theme_font_override("font", font_mono)
	time_lbl.add_theme_font_size_override("font_size", 5)
	time_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.6))
	time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	b_vbox.add_child(time_lbl)

# Notification chime SFX (ติ๊ง~)
func _play_notification_chime() -> void:
	if not sfx_player:
		return
	var sample_rate: int = 22050
	var duration: float = 0.35
	var sample_count: int = int(float(sample_rate) * duration)
	var data := PackedByteArray()
	data.resize(sample_count)
	for i in range(sample_count):
		var t: float = float(i) / float(sample_rate)
		var env: float = exp(-9.0 * t)
		var val: float = (sin(2.0 * PI * 880.0 * t) * 0.6 + sin(2.0 * PI * 1760.0 * t) * 0.4) * env
		data[i] = int(clampf(128.0 + (val * 48.0), 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()
