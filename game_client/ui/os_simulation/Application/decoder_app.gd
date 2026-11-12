class_name DecoderApp extends Control

## Controller for Decoder Application (Forensic OS Simulation)
## Provides decoding (HexCode, Base64, Binary, etc.) and hashing (MD5, SHA-256, etc.) tools.

signal closed()
signal mode_executed(mode_name: String, input_text: String, output_text: String)

const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

@onready var input_edit: TextEdit = find_child("RawCode", true, false).find_child("TextEdit", true, false) as TextEdit
@onready var output_edit: TextEdit = find_child("Result", true, false).find_child("TextEdit", true, false) as TextEdit
@onready var status_label: Label = find_child("StatusLabel", true, false) as Label
@onready var minimize_button: Button = find_child("Minimize", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button
var maximize_button: Button = null

var _is_maximized: bool = false
var _pre_maximize_pos: Vector2 = Vector2(40, 30)
var _pre_maximize_size: Vector2 = Vector2(400, 200)

# Scroll & Container Nodes
@onready var scroll_container: ScrollContainer = find_child("ScrollContainer", true, false) as ScrollContainer
@onready var mode_scroll_bar: VScrollBar = get_node_or_null("ColorRect/HBoxContainer/DecoderMode/VScrollBar")
@onready var raw_code_scroll_bar: VScrollBar = get_node_or_null("ColorRect/HBoxContainer/VBoxContainer/RawCode/VScrollBar")
@onready var result_scroll_bar: VScrollBar = get_node_or_null("ColorRect/HBoxContainer/VBoxContainer/Result/VScrollBar")

var _internal_mode_scroll: VScrollBar = null
var _internal_raw_scroll: VScrollBar = null
var _internal_result_scroll: VScrollBar = null

# Mode Buttons - Category 1: Decoders & Ciphers
@onready var btn_hex: Button = find_child("BtnHex", true, false) as Button
@onready var btn_base64: Button = find_child("BtnBase64", true, false) as Button
@onready var btn_binary: Button = find_child("BtnBinary", true, false) as Button
@onready var btn_rot13: Button = find_child("BtnROT13", true, false) as Button
@onready var btn_morse: Button = find_child("BtnMorse", true, false) as Button
@onready var btn_url: Button = find_child("BtnURL", true, false) as Button
@onready var btn_reverse: Button = find_child("BtnReverse", true, false) as Button
@onready var btn_atbash: Button = find_child("BtnAtbash", true, false) as Button

# Mode Buttons - Category 2: Hashes & Checksums
@onready var btn_md5: Button = find_child("BtnMD5", true, false) as Button
@onready var btn_sha256: Button = find_child("BtnSHA256", true, false) as Button
@onready var btn_sha1: Button = find_child("BtnSHA1", true, false) as Button
@onready var btn_crc32: Button = find_child("BtnCRC32", true, false) as Button

# Helper Action Buttons
@onready var btn_decode: Button = (find_child("BtnDecode", true, false) if find_child("BtnDecode", true, false) else find_child("BtnUseAsInput", true, false)) as Button
@onready var btn_clear: Button = find_child("BtnClear", true, false) as Button
@onready var btn_copy: Button = find_child("BtnCopy", true, false) as Button

var _current_mode_name: String = "HexCode"
var _current_decode_func: Callable = Callable()
var _mode_buttons: Array[Button] = []

const MORSE_TO_CHAR: Dictionary = {
	".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E",
	"..-.": "F", "--.": "G", "....": "H", "..": "I", ".---": "J",
	"-.-": "K", ".-..": "L", "--": "M", "-.": "N", "---": "O",
	".--.": "P", "--.-": "Q", ".-.": "R", "...": "S", "-": "T",
	"..-": "U", "...-": "V", ".--": "W", "-..-": "X", "-.--": "Y",
	"--..": "Z", "-----": "0", ".----": "1", "..---": "2", "...--": "3",
	"....-": "4", ".....": "5", "-....": "6", "--...": "7", "---..": "8",
	"----.": "9", ".-.-.-": ".", "--..--": ",", "..--..": "?",
	".----.": "'", "-.-.--": "!", "-..-.": "/", "-.--.": "(",
	"-.--.-": ")", ".-...": "&", "---...": ":", "-.-.-.": ";",
	"-...-": "=", ".-.-.": "+", "-....-": "-", "..--.-": "_",
	".-..-.": "\"", "...-..-": "$", ".--.-.": "@"
}

var _char_to_morse: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for code in MORSE_TO_CHAR:
		_char_to_morse[MORSE_TO_CHAR[code]] = code
	_char_to_morse[" "] = "/"

	_apply_modern_styling()
	_setup_window_dragging()
	_style_window()
	_setup_mode_controls()

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

func _on_close_pressed() -> void:
	hide()
	closed.emit()

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

func _setup_mode_controls() -> void:
	_register_mode_button(btn_hex, "HexCode", _decode_hex)
	_register_mode_button(btn_base64, "Base64", _decode_base64)
	_register_mode_button(btn_binary, "Binary", _decode_binary)
	_register_mode_button(btn_rot13, "ROT13", _decode_rot13)
	_register_mode_button(btn_morse, "Morse Code", _decode_morse)
	_register_mode_button(btn_url, "URL Decode", _decode_url)
	_register_mode_button(btn_reverse, "Reverse Text", _decode_reverse)
	_register_mode_button(btn_atbash, "Atbash", _decode_atbash)
	
	_register_mode_button(btn_md5, "MD5 Hash", _hash_md5)
	_register_mode_button(btn_sha256, "SHA-256", _hash_sha256)
	_register_mode_button(btn_sha1, "SHA-1", _hash_sha1)
	_register_mode_button(btn_crc32, "CRC32", _hash_crc32)
	
	if btn_hex:
		_select_mode(btn_hex, "HexCode", _decode_hex)
		if status_label:
			status_label.text = "Status: 1. Select Mode -> 2. Enter Code -> 3. Click ▶ Decode"
	
	if btn_decode and not btn_decode.pressed.is_connected(_on_decode_pressed):
		btn_decode.pressed.connect(_on_decode_pressed)
	if btn_clear and not btn_clear.pressed.is_connected(_on_clear_pressed):
		btn_clear.pressed.connect(_on_clear_pressed)
	if btn_copy and not btn_copy.pressed.is_connected(_on_copy_pressed):
		btn_copy.pressed.connect(_on_copy_pressed)

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
		win_sb.bg_color = Color(0.11, 0.13, 0.18, 0.98)
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
		win_sb.border_color = Color(0.25, 0.38, 0.65, 0.7)
		bg_panel.add_theme_stylebox_override("panel", win_sb)
		
		var title_bar: Panel = window_box.get_node_or_null("AppTitle") as Panel
		if not title_bar:
			title_bar = window_box.find_child("AppTitle", true, false) as Panel
		if title_bar:
			var title_sb := StyleBoxFlat.new()
			title_sb.bg_color = Color(0.16, 0.18, 0.26, 1.0)
			title_sb.corner_radius_top_left = 7
			title_sb.corner_radius_top_right = 7
			title_sb.corner_radius_bottom_left = 0
			title_sb.corner_radius_bottom_right = 0
			title_sb.border_width_bottom = 1
			title_sb.border_color = Color(0.22, 0.28, 0.42, 0.8)
			title_bar.add_theme_stylebox_override("panel", title_sb)

		var title_lbl := window_box.find_child("Label", true, false) as Label
		if title_lbl:
			title_lbl.add_theme_font_size_override("font_size", 9)

	var mode_panel := find_child("DecoderMode", true, false) as Control
	if mode_panel:
		var mode_sb := StyleBoxFlat.new()
		mode_sb.bg_color = Color(0.13, 0.15, 0.22, 0.9)
		mode_sb.corner_radius_top_left = 7
		mode_sb.corner_radius_top_right = 7
		mode_sb.corner_radius_bottom_left = 7
		mode_sb.corner_radius_bottom_right = 7
		mode_sb.shadow_size = 6
		mode_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		mode_sb.shadow_offset = Vector2(0, 3)
		mode_sb.border_width_left = 1
		mode_sb.border_width_top = 1
		mode_sb.border_width_right = 1
		mode_sb.border_width_bottom = 1
		mode_sb.border_color = Color(0.24, 0.32, 0.48, 0.6)
		mode_panel.add_theme_stylebox_override("panel", mode_sb)

	var raw_panel := find_child("RawCode", true, false) as Control
	if raw_panel:
		var raw_sb := StyleBoxFlat.new()
		raw_sb.bg_color = Color(0.09, 0.11, 0.16, 0.95)
		raw_sb.corner_radius_top_left = 7
		raw_sb.corner_radius_top_right = 7
		raw_sb.corner_radius_bottom_left = 7
		raw_sb.corner_radius_bottom_right = 7
		raw_sb.shadow_size = 6
		raw_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		raw_sb.shadow_offset = Vector2(0, 3)
		raw_sb.border_width_left = 1
		raw_sb.border_width_top = 1
		raw_sb.border_width_right = 1
		raw_sb.border_width_bottom = 1
		raw_sb.border_color = Color(0.22, 0.3, 0.45, 0.6)
		raw_panel.add_theme_stylebox_override("panel", raw_sb)

	var result_panel := find_child("Result", true, false) as Control
	if result_panel:
		var res_sb := StyleBoxFlat.new()
		res_sb.bg_color = Color(0.09, 0.11, 0.16, 0.95)
		res_sb.corner_radius_top_left = 7
		res_sb.corner_radius_top_right = 7
		res_sb.corner_radius_bottom_left = 7
		res_sb.corner_radius_bottom_right = 7
		res_sb.shadow_size = 6
		res_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		res_sb.shadow_offset = Vector2(0, 3)
		res_sb.border_width_left = 1
		res_sb.border_width_top = 1
		res_sb.border_width_right = 1
		res_sb.border_width_bottom = 1
		res_sb.border_color = Color(0.22, 0.3, 0.45, 0.6)
		result_panel.add_theme_stylebox_override("panel", res_sb)

	if input_edit:
		input_edit.add_theme_font_size_override("font_size", 7)
	if output_edit:
		output_edit.add_theme_font_size_override("font_size", 7)
	if status_label:
		status_label.add_theme_font_size_override("font_size", 6)

	var action_buttons: Array[Button] = [btn_decode, btn_clear, btn_copy]
	for ab in action_buttons:
		if ab:
			ab.add_theme_font_size_override("font_size", 6)
			var a_sb := StyleBoxFlat.new()
			a_sb.bg_color = Color(0.16, 0.28, 0.46, 0.9)
			a_sb.corner_radius_top_left = 7
			a_sb.corner_radius_top_right = 7
			a_sb.corner_radius_bottom_left = 7
			a_sb.corner_radius_bottom_right = 7
			a_sb.border_width_left = 1
			a_sb.border_width_top = 1
			a_sb.border_width_right = 1
			a_sb.border_width_bottom = 1
			a_sb.border_color = Color(0.35, 0.6, 0.9, 0.8)
			a_sb.content_margin_left = 5.0
			a_sb.content_margin_right = 5.0
			a_sb.content_margin_top = 1.0
			a_sb.content_margin_bottom = 1.0
			ab.add_theme_stylebox_override("normal", a_sb)

func _process(_delta: float) -> void:
	_sync_ranges_if_needed(_internal_mode_scroll, mode_scroll_bar)
	_sync_ranges_if_needed(_internal_raw_scroll, raw_code_scroll_bar)
	_sync_ranges_if_needed(_internal_result_scroll, result_scroll_bar)

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

func _post_init_scrollbars() -> void:
	_setup_custom_scrollbars()

func _setup_custom_scrollbars() -> void:
	if not mode_scroll_bar:
		var mode_panel := get_node_or_null("ColorRect/HBoxContainer/DecoderMode")
		if mode_panel:
			mode_scroll_bar = mode_panel.get_node_or_null("VScrollBar") as VScrollBar
		elif scroll_container and scroll_container.get_parent():
			mode_scroll_bar = scroll_container.get_parent().get_node_or_null("VScrollBar") as VScrollBar

	if scroll_container and mode_scroll_bar:
		_internal_mode_scroll = _get_internal_v_scrollbar(scroll_container)
		if _internal_mode_scroll:
			_bind_scrollbar(_internal_mode_scroll, mode_scroll_bar)

	if input_edit and raw_code_scroll_bar:
		_internal_raw_scroll = _get_internal_v_scrollbar(input_edit)
		if _internal_raw_scroll:
			_bind_scrollbar(_internal_raw_scroll, raw_code_scroll_bar)

	if output_edit and result_scroll_bar:
		_internal_result_scroll = _get_internal_v_scrollbar(output_edit)
		if _internal_result_scroll:
			_bind_scrollbar(_internal_result_scroll, result_scroll_bar)

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

	# Ensure custom scrollbar layout and grabber styling
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

	# Custom scrollbar dragging -> internal scrolling
	if not custom.value_changed.is_connected(_on_custom_scroll_changed.bind(internal)):
		custom.value_changed.connect(_on_custom_scroll_changed.bind(internal))

	# Internal scrolling (mouse wheel, caret navigation) -> custom scrollbar
	if not internal.value_changed.is_connected(_on_internal_scroll_changed.bind(custom)):
		internal.value_changed.connect(_on_internal_scroll_changed.bind(custom))

func _on_custom_scroll_changed(new_val: float, internal: VScrollBar) -> void:
	if is_instance_valid(internal) and not is_equal_approx(internal.value, new_val):
		internal.value = new_val

func _on_internal_scroll_changed(new_val: float, custom: VScrollBar) -> void:
	if is_instance_valid(custom) and not is_equal_approx(custom.value, new_val):
		custom.value = new_val

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
		grabber_box.bg_color = Color(0.50, 0.75, 0.90, 0.85)
		grabber_box.corner_radius_top_left = 1
		grabber_box.corner_radius_top_right = 1
		grabber_box.corner_radius_bottom_right = 1
		grabber_box.corner_radius_bottom_left = 1
		scrollbar.add_theme_stylebox_override("grabber", grabber_box)

	if not scrollbar.has_theme_stylebox_override("grabber_highlight"):
		var hl_box: StyleBoxFlat = StyleBoxFlat.new()
		hl_box.bg_color = Color(0.70, 0.90, 1.0, 1.0)
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

func _register_mode_button(btn: Button, mode_name: String, decode_func: Callable) -> void:
	if not btn:
		return
	btn.toggle_mode = true
	btn.add_theme_font_size_override("font_size", 6)
	var m_sb := StyleBoxFlat.new()
	m_sb.bg_color = Color(0.16, 0.20, 0.28, 0.85)
	m_sb.corner_radius_top_left = 7
	m_sb.corner_radius_top_right = 7
	m_sb.corner_radius_bottom_left = 7
	m_sb.corner_radius_bottom_right = 7
	m_sb.border_width_left = 1
	m_sb.border_width_top = 1
	m_sb.border_width_right = 1
	m_sb.border_width_bottom = 1
	m_sb.border_color = Color(0.28, 0.38, 0.52, 0.7)
	m_sb.content_margin_left = 4.0
	m_sb.content_margin_right = 4.0
	m_sb.content_margin_top = 2.0
	m_sb.content_margin_bottom = 2.0
	btn.add_theme_stylebox_override("normal", m_sb)

	var p_sb := m_sb.duplicate() as StyleBoxFlat
	p_sb.bg_color = Color(0.15, 0.35, 0.6, 1.0)
	p_sb.border_color = Color(0.5, 0.8, 1.0, 1.0)
	btn.add_theme_stylebox_override("pressed", p_sb)

	_mode_buttons.append(btn)
	btn.pressed.connect(func() -> void:
		_select_mode(btn, mode_name, decode_func)
	)

func _select_mode(btn: Button, mode_name: String, decode_func: Callable) -> void:
	_current_mode_name = mode_name
	_current_decode_func = decode_func
	for b in _mode_buttons:
		b.button_pressed = (b == btn)
	if status_label:
		status_label.text = "Selected: %s | Enter code & click ▶ Decode" % mode_name

func _on_decode_pressed() -> void:
	if not input_edit or not output_edit:
		return
	var raw_text: String = input_edit.text
	if raw_text.strip_edges().is_empty():
		output_edit.text = "[!] Input is empty. Please enter or paste text in the top box."
		if status_label:
			status_label.text = "Status: Input is empty"
		return
	
	if not _current_decode_func.is_valid():
		output_edit.text = "[!] Please select a decoding mode on the left first."
		if status_label:
			status_label.text = "Status: Select a mode on the left"
		return
		
	var prev_status: String = status_label.text if status_label else ""
	var result: String = _current_decode_func.call(raw_text)
	output_edit.text = result
	if status_label and status_label.text == prev_status:
		status_label.text = "%s completed" % _current_mode_name
	mode_executed.emit(_current_mode_name, raw_text, result)

func _on_clear_pressed() -> void:
	if input_edit:
		input_edit.text = ""
	if output_edit:
		output_edit.text = ""
	if status_label:
		status_label.text = "Cleared"

func _on_copy_pressed() -> void:
	if not output_edit:
		return
	var text_to_copy: String = output_edit.text.strip_edges()
	if not text_to_copy.is_empty() and not text_to_copy.begins_with("[!]"):
		DisplayServer.clipboard_set(text_to_copy)
		if status_label:
			status_label.text = "Copied to clipboard! (%d chars)" % text_to_copy.length()

# ----------------- Decoder & Cipher Implementations -----------------

func _decode_hex(raw: String) -> String:
	var clean: String = raw.strip_edges()
	clean = clean.replace("0x", "").replace("0X", "").replace("\\x", "").replace("\\X", "")
	clean = clean.replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "").replace(":", "").replace("-", "").replace(",", "")
	
	var is_hex: bool = clean.length() >= 2
	if is_hex:
		for i in range(clean.length()):
			var c: String = clean[i]
			if not ((c >= '0' and c <= '9') or (c >= 'a' and c <= 'f') or (c >= 'A' and c <= 'F')):
				is_hex = false
				break
				
	if is_hex and clean.length() % 2 == 0:
		var bytes: PackedByteArray = PackedByteArray()
		for i in range(0, clean.length(), 2):
			bytes.append(clean.substr(i, 2).hex_to_int())
		
		var decoded: String = bytes.get_string_from_utf8()
		if decoded.is_empty() and not bytes.is_empty():
			var ascii_str: String = ""
			for b in bytes:
				if b >= 32 and b <= 126:
					ascii_str += String.chr(b)
				elif b == 10:
					ascii_str += "\n"
				elif b == 13 or b == 9:
					ascii_str += " "
				else:
					ascii_str += "."
			decoded = ascii_str
			
		if not decoded.is_empty():
			if status_label:
				status_label.text = "HexCode Decoded (%d bytes)" % bytes.size()
			return decoded
			
	# If input is text or odd hex, ENCODE text -> HexCode
	var bytes_to_encode: PackedByteArray = raw.to_utf8_buffer()
	var hex_out: String = ""
	for i in range(bytes_to_encode.size()):
		hex_out += "%02X" % bytes_to_encode[i]
		if i < bytes_to_encode.size() - 1:
			hex_out += " "
			
	if status_label:
		status_label.text = "HexCode Encoded (%d bytes)" % bytes_to_encode.size()
	return hex_out

func _decode_base64(raw: String) -> String:
	var clean: String = raw.strip_edges()
	clean = clean.replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "")
	clean = clean.replace("-", "+").replace("_", "/")
	
	var is_b64_chars: bool = clean.length() > 0
	for i in range(clean.length()):
		var c: String = clean[i]
		if not ((c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z') or (c >= '0' and c <= '9') or c == '+' or c == '/' or c == '='):
			is_b64_chars = false
			break
			
	if is_b64_chars:
		var padded: String = clean
		while padded.length() % 4 != 0:
			padded += "="
			
		var bytes: PackedByteArray = Marshalls.base64_to_raw(padded)
		if not bytes.is_empty():
			var decoded: String = bytes.get_string_from_utf8()
			if decoded.is_empty():
				var ascii_str: String = ""
				var printable_count: int = 0
				for b in bytes:
					if (b >= 32 and b <= 126) or b == 10 or b == 13 or b == 9:
						ascii_str += String.chr(b)
						printable_count += 1
					else:
						ascii_str += "."
				if printable_count > bytes.size() / 2:
					decoded = ascii_str
					
			if not decoded.is_empty():
				if status_label:
					status_label.text = "Base64 Decoded (%d bytes)" % bytes.size()
				return decoded
				
	# Encode to Base64
	var encoded: String = Marshalls.raw_to_base64(raw.to_utf8_buffer())
	if status_label:
		status_label.text = "Base64 Encoded (%d chars)" % encoded.length()
	return encoded

func _decode_binary(raw: String) -> String:
	var clean: String = raw.strip_edges()
	clean = clean.replace("0b", "").replace("0B", "").replace(",", "")
	clean = clean.replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "")
	
	var is_pure_binary: bool = clean.length() >= 8
	for i in range(clean.length()):
		var c: String = clean[i]
		if c != "0" and c != "1":
			is_pure_binary = false
			break
			
	if is_pure_binary and clean.length() % 8 == 0:
		var bytes: PackedByteArray = PackedByteArray()
		for i in range(0, clean.length(), 8):
			var byte_str: String = clean.substr(i, 8)
			var val: int = 0
			for bit in byte_str:
				val = (val << 1) | (1 if bit == "1" else 0)
			bytes.append(val)
			
		var decoded: String = bytes.get_string_from_utf8()
		if decoded.is_empty() and not bytes.is_empty():
			var ascii_str: String = ""
			for b in bytes:
				if b >= 32 and b <= 126:
					ascii_str += String.chr(b)
				elif b == 10:
					ascii_str += "\n"
				else:
					ascii_str += "."
			decoded = ascii_str
			
		if not decoded.is_empty():
			if status_label:
				status_label.text = "Binary Decoded (%d bytes)" % bytes.size()
			return decoded
			
	# Encode to Binary
	var bytes_to_encode: PackedByteArray = raw.to_utf8_buffer()
	var bin_parts: PackedStringArray = PackedStringArray()
	for b in bytes_to_encode:
		var s: String = ""
		for bit_idx in range(7, -1, -1):
			s += "1" if ((b >> bit_idx) & 1) != 0 else "0"
		bin_parts.append(s)
		
	var result_bin: String = " ".join(bin_parts)
	if status_label:
		status_label.text = "Binary Encoded (%d bytes)" % bytes_to_encode.size()
	return result_bin

func _decode_rot13(raw: String) -> String:
	var res: String = ""
	for i in range(raw.length()):
		var code: int = raw.unicode_at(i)
		if code >= 65 and code <= 90:
			res += String.chr(((code - 65 + 13) % 26) + 65)
		elif code >= 97 and code <= 122:
			res += String.chr(((code - 97 + 13) % 26) + 97)
		else:
			res += raw[i]
	if status_label:
		status_label.text = "ROT13 Applied (Shift 13)"
	return res

func _decode_morse(raw: String) -> String:
	var clean: String = raw.strip_edges()
	
	var has_morse_symbols: bool = false
	var has_letters: bool = false
	
	for i in range(clean.length()):
		var c: String = clean[i]
		if c == "." or c == "-":
			has_morse_symbols = true
		elif (c >= "A" and c <= "Z") or (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			has_letters = true
			
	if has_morse_symbols and not has_letters:
		# DECODE Morse -> Text
		var normalized: String = clean.replace("\n", " / ").replace("|", " / ")
		var tokens: PackedStringArray = normalized.split(" ", false)
		var decoded: String = ""
		for token in tokens:
			token = token.strip_edges()
			if token.is_empty():
				continue
			if token == "/" or token == "//":
				if not decoded.ends_with(" "):
					decoded += " "
			elif MORSE_TO_CHAR.has(token):
				decoded += MORSE_TO_CHAR[token]
			else:
				decoded += "?"
		if status_label:
			status_label.text = "Morse Code Decoded"
		return decoded
	else:
		# ENCODE Text -> Morse
		var upper_text: String = clean.to_upper()
		var morse_parts: PackedStringArray = PackedStringArray()
		for i in range(upper_text.length()):
			var ch: String = upper_text[i]
			if ch == " ":
				morse_parts.append("/")
			elif _char_to_morse.has(ch):
				morse_parts.append(_char_to_morse[ch])
			elif ch == "\n":
				morse_parts.append("/")
		var result: String = " ".join(morse_parts)
		if status_label:
			status_label.text = "Morse Code Encoded"
		return result

func _decode_url(raw: String) -> String:
	if "%" in raw:
		var decoded: String = raw.replace("+", " ").uri_decode()
		if status_label:
			status_label.text = "URL Decoded"
		return decoded
	else:
		var encoded: String = raw.uri_encode()
		if status_label:
			status_label.text = "URL Encoded"
		return encoded

func _decode_reverse(raw: String) -> String:
	var res: String = ""
	for i in range(raw.length() - 1, -1, -1):
		res += raw[i]
	if status_label:
		status_label.text = "Text Reversed (%d chars)" % res.length()
	return res

func _decode_atbash(raw: String) -> String:
	var res: String = ""
	for i in range(raw.length()):
		var code: int = raw.unicode_at(i)
		if code >= 65 and code <= 90:
			res += String.chr(90 - (code - 65))
		elif code >= 97 and code <= 122:
			res += String.chr(122 - (code - 97))
		else:
			res += raw[i]
	if status_label:
		status_label.text = "Atbash Cipher Applied"
	return res

# ----------------- Hash & Checksum Implementations -----------------

func _hash_md5(raw: String) -> String:
	var hash_str: String = raw.md5_text().to_lower()
	if status_label:
		status_label.text = "MD5 Hash: 32 hex chars (128-bit)"
	return hash_str

func _hash_sha256(raw: String) -> String:
	var hash_str: String = raw.sha256_text().to_lower()
	if status_label:
		status_label.text = "SHA-256 Hash: 64 hex chars (256-bit)"
	return hash_str

func _hash_sha1(raw: String) -> String:
	var ctx: HashingContext = HashingContext.new()
	var err: Error = ctx.start(HashingContext.HASH_SHA1)
	if err != OK:
		return "[ERROR] Failed to initialize SHA-1 context."
	ctx.update(raw.to_utf8_buffer())
	var res: PackedByteArray = ctx.finish()
	var hash_str: String = res.hex_encode().to_lower()
	if status_label:
		status_label.text = "SHA-1 Hash: 40 hex chars (160-bit)"
	return hash_str

func _hash_crc32(raw: String) -> String:
	var bytes: PackedByteArray = raw.to_utf8_buffer()
	var crc: int = 0xFFFFFFFF
	for b in bytes:
		crc ^= b
		for _j in range(8):
			var mask: int = -(crc & 1)
			crc = (crc >> 1) ^ (0xEDB88320 & mask)
	var final_crc: int = (~crc & 0xFFFFFFFF)
	var crc_str: String = "%08X" % final_crc
	if status_label:
		status_label.text = "CRC32 Checksum (32-bit): 0x%s" % crc_str
	return crc_str

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
