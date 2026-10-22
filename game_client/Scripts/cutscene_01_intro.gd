class_name Cutscene01Intro extends Node2D

## Scene 1 Cutscene: May's bedroom (19:02).
## Flow:
## 1. May relaxes on bed listening to phone music (chill lofi + leg kicks).
## 2. Incoming call from Mesa interrupts.
## 3. Call connects -> Typewriter dialogue (4 lines).
## 4. Fade to Black -> Transition to Scene 2 (Tutorial).

signal cutscene_started
signal incoming_call_started
signal call_answered
signal dialogue_line_started(speaker: String, text: String)
signal dialogue_line_completed(index: int)
signal dialogue_finished
signal cutscene_completed

const SCENE_02_TUTORIAL_PATH: String = "res://Scenes/Scene_02_Tutorial.tscn"
const SCENE_02_TUTORIAL_ALT_PATH: String = "res://Scene_02_Tutorial.tscn"
const DESKTOP_SCENE_PATH: String = "res://Scenes/Initial/desktop_screen.tscn"

const DIALOGUE_SEQUENCE: Array[Dictionary] = [
	{
		"speaker": "เมษา (โทรศัพท์)",
		"sub_name": "เมษา (โทรศัพท์)",
		"portrait": "res://assets/images/portraits/portrait_mesa.png",
		"text": "เมย์ เธอยังไม่ได้ส่งงานเลยนะ พรุ่งนี้จะเดดไลน์แล้ว",
		"expression": "serious"
	},
	{
		"speaker": "เมย์",
		"sub_name": "เมย์",
		"portrait": "res://assets/images/portraits/portrait_may_surprised.png",
		"text": "โอ๊ะ !",
		"expression": "surprised"
	},
	{
		"speaker": "เมษา (โทรศัพท์)",
		"sub_name": "เมษา (โทรศัพท์)",
		"portrait": "res://assets/images/portraits/portrait_mesa.png",
		"text": "ฉันส่งข้อความไปบอกตั้งเยอะ เปิดอ่านด้วยละกัน",
		"expression": "serious"
	},
	{
		"speaker": "เมย์",
		"sub_name": "เมย์",
		"portrait": "res://assets/images/portraits/portrait_may_normal.png",
		"text": "เดี๋ยวส่งไป~",
		"expression": "sigh"
	}
]

# Audio Players
var bgm_player: AudioStreamPlayer
var ringtone_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var typewriter_player: AudioStreamPlayer

# May on Bed Visuals
var may_node: Node2D
var may_sprite: Sprite2D
var may_anim_timer: float = 0.0
var may_frame: int = 0
var is_kicking_legs: bool = true
var music_notes_container: Node2D
var music_note_timer: float = 0.0
var surprise_badge: Label

# UI Nodes
var canvas_layer: CanvasLayer
var incoming_call_modal: PanelContainer
var dialogue_box: PanelContainer
var speaker_avatar_rect: TextureRect
var speaker_name_label: Label
var dialogue_text_label: Label
var prompt_arrow: Label
var fade_overlay: ColorRect

# Cutscene State Machine
enum State { INTRO_CHILL, INCOMING_CALL, DIALOGUE, TRANSITION }
var current_state: State = State.INTRO_CHILL
var state_timer: float = 0.0

# Dialogue State
var current_dialogue_idx: int = -1
var is_typing: bool = false
var typewriter_tween: Tween

func _ready() -> void:
	_setup_audio_players()
	_setup_may_on_bed()
	_setup_ui()
	_start_intro_chill()

func _setup_audio_players() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BgmPlayer"
	bgm_player.volume_db = -12.0
	bgm_player.stream = _generate_lofi_bgm_stream()
	add_child(bgm_player)

	ringtone_player = AudioStreamPlayer.new()
	ringtone_player.name = "RingtonePlayer"
	ringtone_player.volume_db = -8.0
	ringtone_player.stream = _generate_ringtone_stream()
	add_child(ringtone_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SfxPlayer"
	sfx_player.volume_db = -6.0
	add_child(sfx_player)

	typewriter_player = AudioStreamPlayer.new()
	typewriter_player.name = "TypewriterPlayer"
	typewriter_player.volume_db = -18.0
	typewriter_player.stream = _generate_typewriter_click()
	add_child(typewriter_player)

func _setup_may_on_bed() -> void:
	may_node = Node2D.new()
	may_node.name = "MayOnBed"
	may_node.position = Vector2(58, 150)
	may_node.z_index = 5  # Render above bed furniture tilemap (z_index = 1)
	add_child(may_node)

	may_sprite = Sprite2D.new()
	may_sprite.name = "Sprite"
	var texture_path := "res://assets/sprite/may_bed_lying.png"
	if ResourceLoader.exists(texture_path):
		var tex: Texture2D = load(texture_path)
		may_sprite.texture = tex
		may_sprite.hframes = 5
		may_sprite.frame = 0
	may_node.add_child(may_sprite)

	surprise_badge = Label.new()
	surprise_badge.name = "SurpriseBadge"
	surprise_badge.text = "!"
	surprise_badge.add_theme_font_size_override("font_size", 14)
	surprise_badge.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
	surprise_badge.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	surprise_badge.add_theme_constant_override("shadow_offset_x", 1)
	surprise_badge.add_theme_constant_override("shadow_offset_y", 1)
	surprise_badge.position = Vector2(8, -26)
	surprise_badge.visible = false
	may_node.add_child(surprise_badge)

	music_notes_container = Node2D.new()
	music_notes_container.name = "MusicNotes"
	music_notes_container.position = Vector2(0, -10)
	may_node.add_child(music_notes_container)

func _setup_ui() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "CutsceneUI"
	add_child(canvas_layer)

	var font_thai: Font = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Medium.ttf") if ResourceLoader.exists("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Medium.ttf") else null
	var font_thai_bold: Font = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf") if ResourceLoader.exists("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf") else font_thai
	var font_mono: Font = load("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf") if ResourceLoader.exists("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf") else null

	# Incoming call notification modal
	incoming_call_modal = PanelContainer.new()
	incoming_call_modal.name = "IncomingCallModal"
	incoming_call_modal.position = Vector2(145, 36)
	incoming_call_modal.custom_minimum_size = Vector2(190, 50)
	incoming_call_modal.size = Vector2(190, 50)
	incoming_call_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	incoming_call_modal.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	incoming_call_modal.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_answer_call()
	)
	var call_style := StyleBoxFlat.new()
	call_style.bg_color = Color(0.08, 0.12, 0.20, 0.95)
	call_style.border_width_left = 2
	call_style.border_width_top = 2
	call_style.border_width_right = 2
	call_style.border_width_bottom = 2
	call_style.border_color = Color(0.3, 0.85, 0.45, 0.95) # Green call ring border
	call_style.corner_radius_top_left = 4
	call_style.corner_radius_top_right = 4
	call_style.corner_radius_bottom_right = 4
	call_style.corner_radius_bottom_left = 4
	call_style.content_margin_left = 8.0
	call_style.content_margin_right = 8.0
	call_style.content_margin_top = 6.0
	call_style.content_margin_bottom = 6.0
	incoming_call_modal.add_theme_stylebox_override("panel", call_style)
	incoming_call_modal.visible = false
	canvas_layer.add_child(incoming_call_modal)

	var call_vbox := VBoxContainer.new()
	call_vbox.add_theme_constant_override("separation", 2)
	incoming_call_modal.add_child(call_vbox)

	var call_header := Label.new()
	call_header.text = "📞 สายเรียกเข้า (Incoming Call)..."
	if font_thai_bold: call_header.add_theme_font_override("font", font_thai_bold)
	call_header.add_theme_font_size_override("font_size", 7)
	call_header.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5, 1.0))
	call_vbox.add_child(call_header)

	var call_name := Label.new()
	call_name.text = "เมษา (Mesasohot131415)"
	if font_thai_bold: call_name.add_theme_font_override("font", font_thai_bold)
	call_name.add_theme_font_size_override("font_size", 8)
	call_name.add_theme_color_override("font_color", Color.WHITE)
	call_vbox.add_child(call_name)

	var call_prompt := Label.new()
	call_prompt.text = "กด [Space] หรือคลิกเพื่อรับสาย"
	if font_thai: call_prompt.add_theme_font_override("font", font_thai)
	call_prompt.add_theme_font_size_override("font_size", 6)
	call_prompt.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.8))
	call_vbox.add_child(call_prompt)

	# Main Dialogue Box (fixed to bottom of viewport 480x270)
	dialogue_box = PanelContainer.new()
	dialogue_box.name = "DialogueBox"
	dialogue_box.position = Vector2(14, 190)
	dialogue_box.custom_minimum_size = Vector2(452, 72)
	dialogue_box.size = Vector2(452, 72)
	dialogue_box.mouse_filter = Control.MOUSE_FILTER_STOP
	dialogue_box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var box_style := StyleBoxFlat.new()
	box_style.bg_color = Color(0.05, 0.08, 0.17, 0.96) # Dark Navy #0E152B
	box_style.border_width_left = 2
	box_style.border_width_top = 2
	box_style.border_width_right = 2
	box_style.border_width_bottom = 2
	box_style.border_color = Color(0.88, 0.74, 0.58, 1.0) # Warm Cream/Beige #E0C097
	box_style.corner_radius_top_left = 4
	box_style.corner_radius_top_right = 4
	box_style.corner_radius_bottom_right = 4
	box_style.corner_radius_bottom_left = 4
	box_style.content_margin_left = 8.0
	box_style.content_margin_right = 8.0
	box_style.content_margin_top = 6.0
	box_style.content_margin_bottom = 6.0
	dialogue_box.add_theme_stylebox_override("panel", box_style)
	dialogue_box.visible = false
	canvas_layer.add_child(dialogue_box)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	dialogue_box.add_child(hbox)

	# Left profile section: avatar frame + character name
	var left_box := HBoxContainer.new()
	left_box.name = "ProfileSection"
	left_box.custom_minimum_size = Vector2(138, 56)
	left_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_box.add_theme_constant_override("separation", 8)
	left_box.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(left_box)

	var avatar_panel := PanelContainer.new()
	avatar_panel.name = "AvatarPanel"
	avatar_panel.custom_minimum_size = Vector2(48, 48)
	avatar_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var av_style := StyleBoxFlat.new()
	av_style.bg_color = Color(0.10, 0.14, 0.24, 0.95)
	av_style.border_width_left = 2
	av_style.border_width_top = 2
	av_style.border_width_right = 2
	av_style.border_width_bottom = 2
	av_style.border_color = Color(0.88, 0.74, 0.58, 0.95)
	av_style.corner_radius_top_left = 4
	av_style.corner_radius_top_right = 4
	av_style.corner_radius_bottom_right = 4
	av_style.corner_radius_bottom_left = 4
	avatar_panel.add_theme_stylebox_override("panel", av_style)
	left_box.add_child(avatar_panel)

	speaker_avatar_rect = TextureRect.new()
	speaker_avatar_rect.name = "AvatarRect"
	speaker_avatar_rect.custom_minimum_size = Vector2(44, 44)
	speaker_avatar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	speaker_avatar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	speaker_avatar_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	speaker_avatar_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	avatar_panel.add_child(speaker_avatar_rect)

	speaker_name_label = Label.new()
	speaker_name_label.name = "SpeakerNameLabel"
	speaker_name_label.text = "เมษา (โทรศัพท์)"
	if font_thai_bold: speaker_name_label.add_theme_font_override("font", font_thai_bold)
	speaker_name_label.add_theme_font_size_override("font_size", 8)
	speaker_name_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.78, 1.0))
	speaker_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speaker_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	speaker_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(speaker_name_label)

	# Vertical divider line
	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(1, 50)
	divider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	divider.color = Color(0.88, 0.74, 0.58, 0.45)
	hbox.add_child(divider)

	# Right dialogue text area + advance arrow
	var right_box := MarginContainer.new()
	right_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_box.add_theme_constant_override("margin_left", 8)
	right_box.add_theme_constant_override("margin_right", 8)
	right_box.add_theme_constant_override("margin_top", 4)
	right_box.add_theme_constant_override("margin_bottom", 4)
	hbox.add_child(right_box)

	dialogue_text_label = Label.new()
	dialogue_text_label.name = "DialogueTextLabel"
	if font_thai: dialogue_text_label.add_theme_font_override("font", font_thai)
	dialogue_text_label.add_theme_font_size_override("font_size", 8)
	dialogue_text_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
	dialogue_text_label.add_theme_constant_override("line_spacing", 3)
	dialogue_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text_label.text = ""
	dialogue_text_label.visible_ratio = 0.0
	right_box.add_child(dialogue_text_label)

	# Blinking Downward Triangle Arrow Indicator (Matching '▼')
	prompt_arrow = Label.new()
	prompt_arrow.name = "PromptArrow"
	prompt_arrow.text = "▼"
	if font_mono: prompt_arrow.add_theme_font_override("font", font_mono)
	prompt_arrow.add_theme_font_size_override("font_size", 8)
	prompt_arrow.add_theme_color_override("font_color", Color.WHITE)
	prompt_arrow.size_flags_horizontal = Control.SIZE_SHRINK_END
	prompt_arrow.size_flags_vertical = Control.SIZE_SHRINK_END
	prompt_arrow.visible = false
	right_box.add_child(prompt_arrow)

	dialogue_box.gui_input.connect(_on_dialogue_box_gui_input)

	# Fullscreen fade overlay for transitions
	fade_overlay = ColorRect.new()
	fade_overlay.name = "FadeOverlay"
	fade_overlay.position = Vector2.ZERO
	fade_overlay.size = Vector2(480, 270)
	fade_overlay.color = Color(0, 0, 0, 1.0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(fade_overlay)

	# Fade in at start
	var in_tween := create_tween()
	in_tween.tween_property(fade_overlay, "color:a", 0.0, 0.8)

func _process(delta: float) -> void:
	state_timer += delta

	# Animate leg kicks on bed
	if is_kicking_legs and may_sprite:
		may_anim_timer += delta
		if may_anim_timer >= 0.32:
			may_anim_timer = 0.0
			may_frame = (may_frame + 1) % 4
			may_sprite.frame = may_frame

	# Floating music notes during chill intro
	if current_state == State.INTRO_CHILL:
		music_note_timer += delta
		if music_note_timer >= 0.9:
			music_note_timer = 0.0
			_spawn_music_note()

	# Blinking prompt arrow
	if prompt_arrow and prompt_arrow.visible:
		var pulse: float = (sin(Time.get_ticks_msec() / 150.0) + 1.0) * 0.5
		prompt_arrow.modulate.a = lerp(0.2, 1.0, pulse)

	# State timers
	match current_state:
		State.INTRO_CHILL:
			if state_timer >= 2.0:
				_start_incoming_call()
		State.INCOMING_CALL:
			# Auto-answer after 2.2s ringing
			if state_timer >= 2.2:
				_answer_call()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_on_skip_pressed()
			return
		if event.keycode in [KEY_SPACE, KEY_ENTER]:
			_handle_advance_input()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_advance_input()

func _handle_advance_input() -> void:
	match current_state:
		State.INTRO_CHILL:
			_start_incoming_call()
		State.INCOMING_CALL:
			_answer_call()
		State.DIALOGUE:
			_advance_dialogue()

func _on_dialogue_box_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_advance_dialogue()

# Flow 1: Chill intro with BGM
func _start_intro_chill() -> void:
	current_state = State.INTRO_CHILL
	state_timer = 0.0
	is_kicking_legs = true
	if bgm_player:
		bgm_player.play()
	cutscene_started.emit()

func _spawn_music_note() -> void:
	if not music_notes_container:
		return
	var note_lbl := Label.new()
	var symbols: Array[String] = ["♪", "♫", "♬"]
	note_lbl.text = symbols[randi() % symbols.size()]
	note_lbl.add_theme_font_size_override("font_size", 9)
	note_lbl.add_theme_color_override("font_color", Color(0.65, 0.85, 1.0, 0.9))
	var start_x: float = randf_range(-8.0, 12.0)
	note_lbl.position = Vector2(start_x, 0.0)
	music_notes_container.add_child(note_lbl)

	var tween := create_tween()
	var target_pos := Vector2(start_x + randf_range(-12.0, 12.0), -26.0)
	tween.tween_property(note_lbl, "position", target_pos, 1.4).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(note_lbl, "modulate:a", 0.0, 1.4)
	tween.finished.connect(note_lbl.queue_free)

# Flow 2: Phone call event (Mesa calls May)
func _start_incoming_call() -> void:
	if current_state != State.INTRO_CHILL:
		return
	current_state = State.INCOMING_CALL
	state_timer = 0.0
	incoming_call_started.emit()

	# Fade out BGM and start ringtone
	if bgm_player:
		var fade_bgm := create_tween()
		fade_bgm.tween_property(bgm_player, "volume_db", -40.0, 0.5)
		fade_bgm.finished.connect(bgm_player.stop)

	if ringtone_player:
		ringtone_player.play()

	# Alert icon above May
	if surprise_badge:
		surprise_badge.visible = true
		var t := create_tween()
		t.tween_property(surprise_badge, "scale", Vector2(1.2, 1.2), 0.15)
		t.tween_property(surprise_badge, "scale", Vector2(1.0, 1.0), 0.15)

	if incoming_call_modal:
		incoming_call_modal.visible = true
		incoming_call_modal.modulate.a = 1.0

# Flow 3: Answer call & dialogue sequence
func _answer_call() -> void:
	if current_state != State.INCOMING_CALL:
		return
	current_state = State.DIALOGUE
	state_timer = 0.0
	call_answered.emit()

	if ringtone_player:
		ringtone_player.stop()

	# Pickup beep
	_play_beep(880.0, 0.08)

	# Switch May sprite to phone call pose
	is_kicking_legs = false
	if may_sprite:
		may_sprite.frame = 4
	if surprise_badge:
		surprise_badge.visible = false

	# Hide call popup and show dialogue box
	if incoming_call_modal:
		incoming_call_modal.visible = false

	if dialogue_box:
		dialogue_box.visible = true
		dialogue_box.modulate.a = 1.0

	current_dialogue_idx = -1
	_advance_dialogue()

func _advance_dialogue() -> void:
	# Skip typewriter and dump full text if user presses advance while typing
	if is_typing:
		if typewriter_tween and typewriter_tween.is_valid():
			typewriter_tween.kill()
		if dialogue_text_label:
			dialogue_text_label.visible_ratio = 1.0
		_on_typing_finished()
		return

	# Next dialogue line
	current_dialogue_idx += 1
	if current_dialogue_idx >= DIALOGUE_SEQUENCE.size():
		_finish_dialogue()
		return

	_show_dialogue_line(current_dialogue_idx)

func _show_dialogue_line(index: int) -> void:
	var item: Dictionary = DIALOGUE_SEQUENCE[index]
	is_typing = true
	prompt_arrow.visible = false

	# Speaker info
	var speaker_name: String = item.get("sub_name", item.get("speaker", ""))
	if speaker_name_label:
		speaker_name_label.text = speaker_name

	if speaker_avatar_rect:
		var port_path: String = item.get("portrait", "")
		if ResourceLoader.exists(port_path):
			speaker_avatar_rect.texture = load(port_path)

	# Typewriter effect
	var text_content: String = item.get("text", "")

	if dialogue_text_label:
		dialogue_text_label.text = text_content
		dialogue_text_label.visible_ratio = 0.0

		var duration: float = clampf(float(text_content.length()) * 0.04, 0.3, 2.0)
		if typewriter_tween and typewriter_tween.is_valid():
			typewriter_tween.kill()
		typewriter_tween = create_tween()
		typewriter_tween.tween_property(dialogue_text_label, "visible_ratio", 1.0, duration)
		typewriter_tween.finished.connect(_on_typing_finished)

		_play_typewriter_sound_loop(text_content.length(), duration)

	dialogue_line_started.emit(item.get("speaker", ""), text_content)

func _play_typewriter_sound_loop(total_chars: int, duration: float) -> void:
	var step: float = duration / maxf(1.0, float(total_chars))
	for i in range(mini(total_chars, 30)):
		get_tree().create_timer(i * step).timeout.connect(func():
			if is_typing and typewriter_player:
				typewriter_player.play()
		)

func _on_typing_finished() -> void:
	is_typing = false
	if prompt_arrow:
		prompt_arrow.visible = true
	dialogue_line_completed.emit(current_dialogue_idx)

func _finish_dialogue() -> void:
	if current_state == State.TRANSITION:
		return
	current_state = State.TRANSITION
	dialogue_finished.emit()

	# Close dialogue box immediately
	if dialogue_box:
		dialogue_box.visible = false

	# Hang up beep
	_play_beep(440.0, 0.12)

	# Fade out to black and transition to Scene 2 (Tutorial)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, 0.5)
	fade_tween.finished.connect(func():
		cutscene_completed.emit()
		_switch_to_next_scene()
	)

func _on_skip_pressed() -> void:
	if current_state == State.TRANSITION:
		return
	current_state = State.TRANSITION

	if bgm_player: bgm_player.stop()
	if ringtone_player: ringtone_player.stop()
	if dialogue_box: dialogue_box.visible = false

	# Fast fade out on ESC skip
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, 0.3)
	fade_tween.finished.connect(func():
		cutscene_completed.emit()
		_switch_to_next_scene()
	)

func _switch_to_next_scene() -> void:
	# Change scene to Scene 2 (Tutorial)
	if ResourceLoader.exists(SCENE_02_TUTORIAL_PATH):
		get_tree().change_scene_to_file(SCENE_02_TUTORIAL_PATH)
	elif ResourceLoader.exists(SCENE_02_TUTORIAL_ALT_PATH):
		get_tree().change_scene_to_file(SCENE_02_TUTORIAL_ALT_PATH)
	elif ResourceLoader.exists("res://Scene_02_Tutorial"):
		get_tree().change_scene_to_file("res://Scene_02_Tutorial")
	elif ResourceLoader.exists(DESKTOP_SCENE_PATH):
		get_tree().change_scene_to_file(DESKTOP_SCENE_PATH)
	else:
		push_error("Scene 2 Tutorial scene not found: " + SCENE_02_TUTORIAL_PATH)

# --- Procedural Audio Synthesizers ---
func _generate_lofi_bgm_stream() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD

	# Generate a 4-second cozy Cmaj7 - Am7 ambient arpeggio
	var sample_count: int = 22050 * 4
	var data := PackedByteArray()
	data.resize(sample_count)

	var notes: Array[float] = [261.63, 329.63, 392.00, 493.88, 220.00, 261.63, 329.63, 392.00]
	for i in range(sample_count):
		var t: float = float(i) / 22050.0
		var note_idx: int = int(t * 2.0) % notes.size()
		var freq: float = notes[note_idx]
		var val: float = sin(2.0 * PI * freq * t) * 0.4 + sin(2.0 * PI * (freq * 0.5) * t) * 0.2
		var env: float = clampf(sin(PI * fmod(t * 2.0, 1.0)), 0.1, 1.0)
		var byte_val: int = int(clampf(128.0 + (val * env * 45.0), 0.0, 255.0))
		data[i] = byte_val

	wav.data = data
	wav.loop_begin = 0
	wav.loop_end = sample_count
	return wav

func _generate_ringtone_stream() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD

	var sample_count: int = int(22050 * 2.0)
	var data := PackedByteArray()
	data.resize(sample_count)

	for i in range(sample_count):
		var t: float = float(i) / 22050.0
		var ring_active: bool = (t < 1.0)
		var byte_val: int = 128
		if ring_active:
			var wave: float = sin(2.0 * PI * 750.0 * t) * 0.4 + sin(2.0 * PI * 850.0 * t) * 0.4
			var pulse: float = sin(2.0 * PI * 20.0 * t)
			byte_val = int(clampf(128.0 + (wave * pulse * 50.0), 0.0, 255.0))
		data[i] = byte_val

	wav.data = data
	wav.loop_begin = 0
	wav.loop_end = sample_count
	return wav

func _generate_typewriter_click() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	var sample_count: int = int(22050 * 0.02)
	var data := PackedByteArray()
	data.resize(sample_count)

	for i in range(sample_count):
		var t: float = float(i) / float(sample_count)
		var decay: float = 1.0 - t
		var wave: float = sin(2.0 * PI * 1400.0 * (float(i) / 22050.0)) * decay
		data[i] = int(clampf(128.0 + (wave * 35.0), 0.0, 255.0))

	wav.data = data
	return wav

func _play_beep(freq: float, duration: float) -> void:
	if not sfx_player:
		return
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 22050
	var sample_count: int = int(22050 * duration)
	var data := PackedByteArray()
	data.resize(sample_count)

	for i in range(sample_count):
		var t: float = float(i) / 22050.0
		var decay: float = 1.0 - (float(i) / float(sample_count))
		var wave: float = sin(2.0 * PI * freq * t) * decay
		data[i] = int(clampf(128.0 + (wave * 45.0), 0.0, 255.0))

	wav.data = data
	sfx_player.stream = wav
	sfx_player.play()
