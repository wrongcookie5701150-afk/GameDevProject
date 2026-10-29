class_name MSWordApp extends Control

signal macro_enabled
signal typing_completed
signal save_pressed
signal minimize_requested
signal close_requested

@onready var macro_banner: PanelContainer = find_child("MacroBanner", true, false) as PanelContainer
@onready var enable_button: Button = find_child("EnableButton", true, false) as Button
@onready var status_label: Label = find_child("StatusLabel", true, false) as Label
@onready var margin_container: MarginContainer = find_child("MarginContainer", true, false) as MarginContainer
@onready var typing_puzzle: TypingGamePuzzle = find_child("TypingPuzzle", true, false) as TypingGamePuzzle
@onready var report_editor: TextEdit = find_child("TextEdit", true, false) as TextEdit
@onready var passage_label: RichTextLabel = find_child("PassageLabel", true, false) as RichTextLabel
@onready var v_scroll_bar: VScrollBar = find_child("VScrollBar", true, false) as VScrollBar
@onready var hide_button: Button = find_child("Hide", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button
@onready var save_button: Button = find_child("SaveButton", true, false) as Button

var _is_macro_enabled: bool = false

func _ready() -> void:
	if not hide_button:
		hide_button = find_child("Hide", true, false) as Button
	if not exit_button:
		exit_button = find_child("Exit", true, false) as Button
	if not enable_button:
		enable_button = find_child("EnableButton", true, false) as Button
	if not save_button:
		save_button = find_child("SaveButton", true, false) as Button
		if not save_button:
			save_button = find_child("Button", true, false) as Button
	if not typing_puzzle:
		typing_puzzle = find_child("TypingPuzzle", true, false) as TypingGamePuzzle
	if not report_editor:
		report_editor = find_child("TextEdit", true, false) as TextEdit
	if not v_scroll_bar:
		v_scroll_bar = find_child("VScrollBar", true, false) as VScrollBar
	if not margin_container:
		margin_container = find_child("MarginContainer", true, false) as MarginContainer
	if not passage_label:
		passage_label = find_child("PassageLabel", true, false) as RichTextLabel
	
	if enable_button:
		enable_button.pressed.connect(_on_enable_content_pressed)
		enable_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if typing_puzzle and typing_puzzle.has_signal("scene_completion_requested"):
		typing_puzzle.scene_completion_requested.connect(_on_typing_completed)
	if hide_button:
		hide_button.pressed.connect(_on_hide_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	if save_button:
		save_button.pressed.connect(_on_save_pressed)
		save_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if typing_puzzle and report_editor:
		typing_puzzle.configure_input(report_editor)
		typing_puzzle.hide()
	
	if macro_banner:
		macro_banner.show()
	
	_setup_scrollbar()

func _setup_scrollbar() -> void:
	if not v_scroll_bar:
		return
	v_scroll_bar.min_value = 0.0
	_update_scrollbar_range()
	if not v_scroll_bar.value_changed.is_connected(_on_scrollbar_value_changed):
		v_scroll_bar.value_changed.connect(_on_scrollbar_value_changed)
	
	var workspace: Control = find_child("Workspace", true, false) as Control
	if workspace:
		_bind_scroll_input_recursive(workspace)
	elif margin_container:
		_bind_scroll_input_recursive(margin_container)

func _bind_scroll_input_recursive(node: Node) -> void:
	if node is Control and node is not VScrollBar:
		var ctrl: Control = node as Control
		if ctrl.mouse_filter == Control.MOUSE_FILTER_IGNORE:
			ctrl.mouse_filter = Control.MOUSE_FILTER_PASS
		if not ctrl.gui_input.is_connected(_on_scroll_input):
			ctrl.gui_input.connect(_on_scroll_input)
	for child: Node in node.get_children():
		_bind_scroll_input_recursive(child)

func _update_scrollbar_range() -> void:
	if not v_scroll_bar:
		return
	
	var view_h: float = 130.0
	if margin_container:
		view_h = margin_container.size.y if margin_container.size.y > 0.0 else margin_container.custom_minimum_size.y
	
	var content_h: float = view_h
	if passage_label:
		if passage_label.has_method("get_content_height"):
			var ch: float = float(passage_label.get_content_height())
			if ch > 0.0:
				content_h = maxf(content_h, ch + 18.0)
		
		var raw_text: String = passage_label.get_parsed_text() if passage_label.has_method("get_parsed_text") else passage_label.text
		if not raw_text.is_empty():
			var lines: PackedStringArray = raw_text.split("\n")
			var total_lines: int = 0
			for l: String in lines:
				var l_len: int = l.length()
				if l_len == 0:
					total_lines += 1
				else:
					total_lines += maxi(1, int(ceil(float(l_len) / 46.0)))
			var godot_lines: int = passage_label.get_line_count()
			total_lines = maxi(total_lines, godot_lines)
			content_h = maxf(content_h, float(total_lines) * 10.0 + 18.0)
		
		# Option A: Stretch PassageLabel paper height to fit content perfectly
		passage_label.size.y = content_h
		passage_label.custom_minimum_size.y = content_h
		passage_label.offset_bottom = content_h
	
	if report_editor:
		report_editor.size.y = content_h
		report_editor.custom_minimum_size.y = content_h
		report_editor.offset_bottom = content_h
	
	var max_scroll: float = maxf(0.0, content_h - view_h)
	v_scroll_bar.max_value = max_scroll
	v_scroll_bar.page = view_h

func _on_scrollbar_value_changed(val: float) -> void:
	_apply_scroll(val)

func _apply_scroll(val: float) -> void:
	if report_editor:
		report_editor.position.y = -val
	if passage_label:
		passage_label.position.y = -val

func _on_scroll_input(event: InputEvent) -> void:
	if not v_scroll_bar:
		return
	if event is InputEventMouseButton and event.pressed:
		_update_scrollbar_range()
		var step: float = 8.0
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			v_scroll_bar.value = maxf(v_scroll_bar.min_value, v_scroll_bar.value - step)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			v_scroll_bar.value = minf(v_scroll_bar.max_value, v_scroll_bar.value + step)
			get_viewport().set_input_as_handled()

func scroll_following_content(step_speed: float = -1.0) -> void:
	_update_scrollbar_range()
	if not v_scroll_bar:
		return
	
	var view_h: float = 130.0
	if margin_container:
		view_h = margin_container.size.y if margin_container.size.y > 0.0 else margin_container.custom_minimum_size.y
	
	# Determine effective line count accurately and monotonically
	var total_lines: int = 0
	if passage_label:
		var raw_text: String = passage_label.get_parsed_text() if passage_label.has_method("get_parsed_text") else passage_label.text
		if not raw_text.is_empty():
			var lines: PackedStringArray = raw_text.split("\n")
			for l: String in lines:
				var l_len: int = l.length()
				if l_len == 0:
					total_lines += 1
				else:
					total_lines += maxi(1, int(ceil(float(l_len) / 46.0)))
		
		# If Godot's line count is available and higher, use it
		var godot_lines: int = passage_label.get_line_count()
		total_lines = maxi(total_lines, godot_lines)
	
	# StyleBox margins: top = 10.0, line_height = 10.0, bottom padding = 8.0
	var current_bottom: float = float(total_lines) * 10.0 + 18.0
	
	# Only start scrolling when the text actually exceeds the visible viewport
	var target_val: float = 0.0
	if current_bottom > view_h:
		target_val = clampf(current_bottom - view_h, 0.0, v_scroll_bar.max_value)
	
	# Smoothly follow the typed text without rushing or overshooting
	var dist: float = target_val - v_scroll_bar.value
	var step: float = 0.4
	if step_speed > 0.0:
		step = step_speed
	else:
		if dist > 0.0:
			step = clampf(dist * 0.08, 0.3, 0.8)
		else:
			step = 0.4
	
	v_scroll_bar.value = move_toward(v_scroll_bar.value, target_val, step)

func scroll_to_ratio(ratio: float) -> void:
	_update_scrollbar_range()
	if v_scroll_bar:
		v_scroll_bar.value = clampf(ratio, 0.0, 1.0) * v_scroll_bar.max_value

func scroll_to_bottom() -> void:
	_update_scrollbar_range()
	if v_scroll_bar:
		v_scroll_bar.value = v_scroll_bar.max_value

func scroll_to_top() -> void:
	_update_scrollbar_range()
	if v_scroll_bar:
		v_scroll_bar.value = 0.0
	_apply_scroll(0.0)

func open_document() -> void:
	show()
	if not _is_macro_enabled:
		if macro_banner:
			macro_banner.show()
		if typing_puzzle:
			typing_puzzle.hide()
	else:
		if macro_banner:
			macro_banner.hide()
		if typing_puzzle:
			typing_puzzle.show()

func _on_enable_content_pressed() -> void:
	_is_macro_enabled = true
	if macro_banner:
		macro_banner.hide()
	if status_label:
		status_label.text = "Macros enabled. Document is being processed..."
	
	# Trigger typing puzzle
	if typing_puzzle:
		typing_puzzle.show()
		if typing_puzzle.has_method("start_puzzle"):
			typing_puzzle.start_puzzle()
	
	macro_enabled.emit()

func _on_typing_completed() -> void:
	if typing_puzzle:
		typing_puzzle.hide()
	if status_label:
		status_label.text = "Document processed successfully!"
	typing_completed.emit()

func _on_save_pressed() -> void:
	save_pressed.emit()

func highlight_save_button() -> void:
	if save_button:
		save_button.add_theme_color_override("font_color", Color(0.1, 0.7, 0.2, 1.0))
		save_button.tooltip_text = "Click to save Report_Final.docx"

func _on_hide_pressed() -> void:
	hide()
	minimize_requested.emit()

func _on_exit_pressed() -> void:
	hide()
	close_requested.emit()

func is_macro_enabled() -> bool:
	return _is_macro_enabled
