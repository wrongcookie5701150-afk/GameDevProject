class_name MSWordApp extends Control

signal macro_enabled
signal typing_completed
signal save_pressed
signal minimize_requested
signal close_requested

@onready var macro_banner: PanelContainer = find_child("MacroBanner", true, false) as PanelContainer
@onready var enable_button: Button = find_child("EnableButton", true, false) as Button
@onready var status_label: Label = find_child("StatusLabel", true, false) as Label
@onready var workspace: HBoxContainer = get_node_or_null("ColorRect/VBoxContainer/Workspace") as HBoxContainer
@onready var workspace_margin: MarginContainer = get_node_or_null("ColorRect/VBoxContainer/Workspace/MarginContainer") as MarginContainer
@onready var margin_container: MarginContainer = workspace_margin
@onready var typing_puzzle: TypingGamePuzzle = find_child("TypingPuzzle", true, false) as TypingGamePuzzle
@onready var report_editor: TextEdit = find_child("TextEdit", true, false) as TextEdit
@onready var passage_label: RichTextLabel = find_child("PassageLabel", true, false) as RichTextLabel
@onready var v_scroll_bar: VScrollBar = find_child("VScrollBar", true, false) as VScrollBar
@onready var hide_button: Button = find_child("Hide", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button
@onready var save_button: Button = find_child("SaveButton", true, false) as Button
@onready var word_count_label: Label = find_child("WordCountLabel", true, false) as Label
@onready var page_count_label: Label = find_child("PageCountLabel", true, false) as Label

const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

var maximize_button: Button = null
var _is_macro_enabled: bool = false
var _is_expanded_mode: bool = false
var _is_maximized: bool = false
var _pre_maximize_pos: Vector2 = Vector2(18, 8)
var _pre_maximize_size: Vector2 = Vector2(444, 236)

func _ready() -> void:
	var win := get_node_or_null("ColorRect") as Control
	var head := get_node_or_null("ColorRect/VBoxContainer/AppHeader") as Control
	if not head:
		head = get_node_or_null("ColorRect/VBoxContainer/ColorRect") as Control
	if not head and win:
		head = win.find_child("AppHeader", true, false) as Control

	var global_settings = get_node_or_null("/root/GlobalSettings")
	if win and head and global_settings and global_settings.has_method("make_window_draggable"):
		global_settings.make_window_draggable(win, head)

	if not workspace:
		workspace = get_node_or_null("ColorRect/VBoxContainer/Workspace") as HBoxContainer
		if not workspace:
			workspace = find_child("Workspace", true, false) as HBoxContainer
	if not workspace_margin:
		if workspace:
			workspace_margin = workspace.get_node_or_null("MarginContainer") as MarginContainer
		if not workspace_margin:
			workspace_margin = get_node_or_null("ColorRect/VBoxContainer/Workspace/MarginContainer") as MarginContainer
	margin_container = workspace_margin

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
	
	_apply_modern_styling()
	_setup_compact_header()
	update_word_count()
	_setup_scrollbar()
	set_expanded_document_mode(true)

## Dynamic Workspace Sizing: Expands MSWordApp to safe screen area (444x236)
func set_expanded_document_mode(expanded: bool = true) -> void:
	_is_expanded_mode = expanded
	var win := get_node_or_null("ColorRect") as Control
	if expanded:
		set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		self.position = Vector2(18, 8)
		self.size = Vector2(444, 236)
		self.custom_minimum_size = Vector2(444, 236)
		if win:
			win.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			win.position = Vector2.ZERO
			win.size = Vector2(444, 236)
			win.custom_minimum_size = Vector2(444, 236)
		if workspace_margin:
			workspace_margin.custom_minimum_size.y = 175.0
	else:
		set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		self.position = Vector2(45, 17)
		self.size = Vector2(390, 220)
		self.custom_minimum_size = Vector2(390, 220)
		if win:
			win.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			win.position = Vector2.ZERO
			win.size = Vector2(390, 220)
			win.custom_minimum_size = Vector2(390, 220)
		if workspace_margin:
			workspace_margin.custom_minimum_size.y = 160.0
	_update_scrollbar_range()

## Prepares a clean blank document workspace for Pre-test / typing / cutscenes
func prepare_blank_canvas() -> void:
	set_expanded_document_mode(true)
	if macro_banner:
		macro_banner.hide()
	if status_label:
		status_label.text = ""
	_setup_compact_header()

func _apply_modern_styling() -> void:
	var win := get_node_or_null("ColorRect") as Control
	if win:
		if win is ColorRect:
			(win as ColorRect).color = Color(0, 0, 0, 0)
		
		var bg_panel: Panel = win.get_node_or_null("WinBgPanel") as Panel
		if not bg_panel:
			bg_panel = Panel.new()
			bg_panel.name = "WinBgPanel"
			bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bg_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			win.add_child(bg_panel)
			win.move_child(bg_panel, 0)
		
		var win_sb := StyleBoxFlat.new()
		win_sb.bg_color = Color(0.96, 0.96, 0.97, 1.0)
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
		win_sb.border_color = Color(0.2, 0.4, 0.7, 0.45)
		bg_panel.add_theme_stylebox_override("panel", win_sb)

	# App Header styling
	var app_header := find_child("AppHeader", true, false) as Control
	if app_header:
		var head_panel: Panel = app_header.get_node_or_null("HeaderBgPanel") as Panel
		if not head_panel:
			head_panel = Panel.new()
			head_panel.name = "HeaderBgPanel"
			head_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			head_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			app_header.add_child(head_panel)
			app_header.move_child(head_panel, 0)
		if app_header is ColorRect:
			(app_header as ColorRect).color = Color(0, 0, 0, 0)
		
		var head_sb := StyleBoxFlat.new()
		head_sb.bg_color = Color(0.06, 0.42, 0.75, 1.0)
		head_sb.corner_radius_top_left = 7
		head_sb.corner_radius_top_right = 7
		head_sb.corner_radius_bottom_left = 0
		head_sb.corner_radius_bottom_right = 0
		head_panel.add_theme_stylebox_override("panel", head_sb)

		var title_lbl := app_header.find_child("Label", true, false) as Label
		if title_lbl:
			title_lbl.add_theme_font_size_override("font_size", 8)

	# MacroBanner styling
	if macro_banner:
		var mb_sb := StyleBoxFlat.new()
		mb_sb.bg_color = Color(0.965, 0.93, 0.86, 1.0)
		mb_sb.corner_radius_top_left = 7
		mb_sb.corner_radius_top_right = 7
		mb_sb.corner_radius_bottom_left = 7
		mb_sb.corner_radius_bottom_right = 7
		mb_sb.shadow_size = 6
		mb_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		mb_sb.shadow_offset = Vector2(0, 3)
		mb_sb.border_width_left = 1
		mb_sb.border_width_top = 1
		mb_sb.border_width_right = 1
		mb_sb.border_width_bottom = 1
		mb_sb.border_color = Color(0.82, 0.65, 0.35, 0.75)
		mb_sb.content_margin_left = 6.0
		mb_sb.content_margin_right = 6.0
		mb_sb.content_margin_top = 2.0
		mb_sb.content_margin_bottom = 2.0
		macro_banner.add_theme_stylebox_override("panel", mb_sb)

		if status_label:
			status_label.add_theme_font_size_override("font_size", 5)
		if enable_button:
			enable_button.add_theme_font_size_override("font_size", 5)

	# DetailsBar (Status bar at bottom)
	var details_bar := find_child("DetailsBar", true, false) as Control
	if details_bar:
		var db_sb := StyleBoxFlat.new()
		db_sb.bg_color = Color(0.106, 0.369, 0.69, 1.0)
		db_sb.corner_radius_top_left = 0
		db_sb.corner_radius_top_right = 0
		db_sb.corner_radius_bottom_left = 7
		db_sb.corner_radius_bottom_right = 7
		db_sb.border_width_top = 1
		db_sb.border_color = Color(0.08, 0.3, 0.58, 1.0)
		db_sb.content_margin_left = 6.0
		db_sb.content_margin_right = 6.0
		db_sb.content_margin_top = 1.0
		db_sb.content_margin_bottom = 1.0
		details_bar.add_theme_stylebox_override("panel", db_sb)

func _setup_compact_header() -> void:
	var vbox := get_node_or_null("ColorRect/VBoxContainer") as VBoxContainer
	if vbox:
		vbox.add_theme_constant_override("separation", 0)

	var app_header := find_child("AppHeader", true, false) as Control
	if app_header:
		app_header.custom_minimum_size = Vector2(0, 11)
		var margin := app_header.find_child("MarginContainer", true, false) as MarginContainer
		if margin:
			margin.add_theme_constant_override("margin_left", 6)
			margin.add_theme_constant_override("margin_right", 4)
			margin.add_theme_constant_override("margin_top", 1)
			margin.add_theme_constant_override("margin_bottom", 1)

	var ribbon_tabs := find_child("RibbonTabs", true, false) as Control
	if ribbon_tabs:
		ribbon_tabs.hide()

	var toolbar := find_child("ToolBar", true, false) as Control
	if toolbar:
		toolbar.custom_minimum_size = Vector2(0, 12)
		var hbox := toolbar.find_child("Hbox", true, false) as Control
		if hbox:
			for child in hbox.get_children():
				if child != save_button:
					child.visible = false

	# Enforce typography caps (titles 8-10px, content 6-7px, buttons/dropdowns <= 6px)
	for btn in find_children("*", "Button", true, false):
		if btn != hide_button and btn != exit_button and btn != maximize_button:
			(btn as Button).add_theme_font_size_override("font_size", 5)

	_setup_window_control_buttons()

func _setup_window_control_buttons() -> void:
	var head := find_child("AppHeader", true, false) as Control
	if not hide_button:
		hide_button = find_child("Hide", true, false) as Button
	if not exit_button:
		exit_button = find_child("Exit", true, false) as Button
	
	var btn_container: HBoxContainer = null
	if hide_button and hide_button.get_parent() is HBoxContainer:
		btn_container = hide_button.get_parent() as HBoxContainer
	elif exit_button and exit_button.get_parent() is HBoxContainer:
		btn_container = exit_button.get_parent() as HBoxContainer

	if btn_container:
		btn_container.add_theme_constant_override("separation", 0)
	
	if not maximize_button:
		maximize_button = find_child("Maximize", true, false) as Button
		if not maximize_button:
			maximize_button = find_child("MaximizeButton", true, false) as Button
		if not maximize_button and btn_container:
			maximize_button = Button.new()
			maximize_button.name = "Maximize"
			btn_container.add_child(maximize_button)
			if hide_button:
				btn_container.move_child(maximize_button, hide_button.get_index() + 1)

	var btn_normal := StyleBoxEmpty.new()
	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = Color(1.0, 1.0, 1.0, 0.15)
	var btn_pressed := StyleBoxFlat.new()
	btn_pressed.bg_color = Color(1.0, 1.0, 1.0, 0.25)
	
	var close_hover := StyleBoxFlat.new()
	close_hover.bg_color = Color(0.91, 0.08, 0.14, 1.0)
	var close_pressed := StyleBoxFlat.new()
	close_pressed.bg_color = Color(0.75, 0.05, 0.1, 1.0)

	if hide_button:
		hide_button.icon = null
		hide_button.text = "─"
		hide_button.custom_minimum_size = Vector2(20, 16)
		hide_button.size = Vector2(20, 16)
		hide_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hide_button.add_theme_font_override("font", FONT_MONO)
		hide_button.add_theme_font_size_override("font_size", 7)
		hide_button.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		hide_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		hide_button.add_theme_stylebox_override("normal", btn_normal)
		hide_button.add_theme_stylebox_override("hover", btn_hover)
		hide_button.add_theme_stylebox_override("pressed", btn_pressed)

	if maximize_button:
		maximize_button.icon = null
		maximize_button.text = "❐" if _is_maximized else "□"
		maximize_button.custom_minimum_size = Vector2(20, 16)
		maximize_button.size = Vector2(20, 16)
		maximize_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		maximize_button.add_theme_font_override("font", FONT_MONO)
		maximize_button.add_theme_font_size_override("font_size", 7)
		maximize_button.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		maximize_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		maximize_button.add_theme_stylebox_override("normal", btn_normal)
		maximize_button.add_theme_stylebox_override("hover", btn_hover)
		maximize_button.add_theme_stylebox_override("pressed", btn_pressed)
		if not maximize_button.pressed.is_connected(_toggle_maximize):
			maximize_button.pressed.connect(_toggle_maximize)

	if exit_button:
		exit_button.icon = null
		exit_button.text = "✕"
		exit_button.custom_minimum_size = Vector2(22, 16)
		exit_button.size = Vector2(22, 16)
		exit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		exit_button.add_theme_font_override("font", FONT_MONO)
		exit_button.add_theme_font_size_override("font_size", 7)
		exit_button.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		exit_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		exit_button.add_theme_stylebox_override("normal", btn_normal)
		exit_button.add_theme_stylebox_override("hover", close_hover)
		exit_button.add_theme_stylebox_override("pressed", close_pressed)

	if head and not head.gui_input.is_connected(_on_header_gui_input):
		head.gui_input.connect(_on_header_gui_input)

func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if event.double_click:
			_toggle_maximize()

func _toggle_maximize() -> void:
	var win := get_node_or_null("ColorRect") as Control
	_is_maximized = !_is_maximized
	if _is_maximized:
		_pre_maximize_pos = position
		_pre_maximize_size = size
		set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		position = Vector2(2, 2)
		size = Vector2(476, 246)
		custom_minimum_size = Vector2(476, 246)
		if win:
			win.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			win.position = Vector2.ZERO
			win.size = Vector2(476, 246)
			win.custom_minimum_size = Vector2(476, 246)
		if workspace_margin:
			workspace_margin.custom_minimum_size.y = 185.0
		if maximize_button:
			maximize_button.text = "❐"
	else:
		position = _pre_maximize_pos
		size = _pre_maximize_size
		custom_minimum_size = _pre_maximize_size
		if win:
			win.position = Vector2.ZERO
			win.size = _pre_maximize_size
			win.custom_minimum_size = _pre_maximize_size
		if workspace_margin:
			workspace_margin.custom_minimum_size.y = 175.0
		if maximize_button:
			maximize_button.text = "□"
	_update_scrollbar_range()

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
	if node.name == "PretestScroll" or node.name == "CutsceneScroll":
		return
	if node is Control and node is not VScrollBar:
		var ctrl: Control = node as Control
		if ctrl.mouse_filter == Control.MOUSE_FILTER_IGNORE:
			ctrl.mouse_filter = Control.MOUSE_FILTER_PASS
		if not ctrl.gui_input.is_connected(_on_scroll_input):
			ctrl.gui_input.connect(_on_scroll_input)
	for child: Node in node.get_children():
		_bind_scroll_input_recursive(child)

func _get_view_height() -> float:
	if workspace_margin and workspace_margin.size.y > 0.0:
		return workspace_margin.size.y
	if workspace and workspace.size.y > 0.0:
		return workspace.size.y
	return 190.0

func _calculate_content_height() -> float:
	var view_h: float = _get_view_height()
	
	if not passage_label:
		return view_h
	
	var text_h: float = 0.0
	if passage_label.has_method("get_content_height"):
		text_h = float(passage_label.get_content_height())
	
	var raw_text: String = passage_label.get_parsed_text() if passage_label.has_method("get_parsed_text") else passage_label.text
	var estimated_h: float = 0.0
	if not raw_text.is_empty():
		var lines: PackedStringArray = raw_text.split("\n")
		var estimated_lines: int = 0
		for l: String in lines:
			var l_len: int = l.length()
			if l_len == 0:
				estimated_lines += 1
			else:
				# In ShareTechMono size 6 with inner width ~303px (~3.24px per char),
				# realistic word wrapping occurs at ~75-80 chars per line.
				estimated_lines += maxi(1, int(ceil(float(l_len) / 80.0)))
		var godot_lines: int = passage_label.get_line_count()
		if godot_lines > 0:
			estimated_lines = maxi(estimated_lines, godot_lines)
		estimated_h = float(estimated_lines) * 10.0
	
	text_h = maxf(text_h, estimated_h)
	
	# StyleBox margins: top = 10.0, bottom = 8.0 (total 18.0)
	var content_h: float = text_h + 18.0
	return maxf(content_h, view_h)

func _update_scrollbar_range() -> void:
	update_word_count()
	if not v_scroll_bar:
		return
	
	var view_h: float = _get_view_height()
	var content_h: float = _calculate_content_height()
	
	if passage_label:
		passage_label.custom_minimum_size.y = content_h
		passage_label.size.y = content_h
		# NOTE: Do NOT assign passage_label.offset_bottom = content_h!
		# If position.y is negative (-val), setting offset_bottom sets size.y = content_h + val,
		# which creates an extra val pixels (1 screen size) of blank paper below the text.
	
	if report_editor:
		report_editor.custom_minimum_size.y = content_h
		report_editor.size.y = content_h
	
	var max_scroll: float = maxf(0.0, content_h - view_h)
	if max_scroll <= 0.0:
		v_scroll_bar.min_value = 0.0
		v_scroll_bar.max_value = 0.0
		v_scroll_bar.page = 0.0
		v_scroll_bar.value = 0.0
		v_scroll_bar.hide()
		_apply_scroll(0.0)
	else:
		v_scroll_bar.show()
		v_scroll_bar.min_value = 0.0
		v_scroll_bar.max_value = content_h
		v_scroll_bar.page = view_h

func _on_scrollbar_value_changed(val: float) -> void:
	_apply_scroll(val)

func _apply_scroll(val: float) -> void:
	if report_editor:
		report_editor.position.y = -val
	if passage_label:
		passage_label.position.y = -val

func _on_scroll_input(event: InputEvent) -> void:
	if typing_puzzle and typing_puzzle.has_method("is_pretest_active") and typing_puzzle.is_pretest_active():
		return
	if not v_scroll_bar or not v_scroll_bar.visible:
		return
	if event is InputEventMouseButton and event.pressed:
		_update_scrollbar_range()
		var step: float = 12.0
		var max_val: float = maxf(0.0, v_scroll_bar.max_value - v_scroll_bar.page)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			v_scroll_bar.value = maxf(v_scroll_bar.min_value, v_scroll_bar.value - step)
			_apply_scroll(v_scroll_bar.value)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			v_scroll_bar.value = minf(max_val, v_scroll_bar.value + step)
			_apply_scroll(v_scroll_bar.value)
			get_viewport().set_input_as_handled()

func scroll_following_content(step_speed: float = -1.0) -> void:
	_update_scrollbar_range()
	if not v_scroll_bar or not v_scroll_bar.visible:
		return
	
	var view_h: float = _get_view_height()
	
	var text_h: float = 0.0
	if passage_label and passage_label.has_method("get_content_height"):
		text_h = float(passage_label.get_content_height())
	
	var raw_text: String = passage_label.get_parsed_text() if passage_label.has_method("get_parsed_text") else passage_label.text
	var estimated_h: float = 0.0
	if not raw_text.is_empty():
		var lines: PackedStringArray = raw_text.split("\n")
		var total_lines: int = 0
		for l: String in lines:
			var l_len: int = l.length()
			if l_len == 0:
				total_lines += 1
			else:
				total_lines += maxi(1, int(ceil(float(l_len) / 80.0)))
		var godot_lines: int = passage_label.get_line_count()
		if godot_lines > 0:
			total_lines = maxi(total_lines, godot_lines)
		estimated_h = float(total_lines) * 10.0
	
	text_h = maxf(text_h, estimated_h)
	
	var current_bottom: float = text_h + 18.0
	var max_val: float = maxf(0.0, v_scroll_bar.max_value - v_scroll_bar.page)
	
	var target_val: float = 0.0
	if current_bottom > view_h:
		target_val = clampf(current_bottom - view_h, 0.0, max_val)
	
	if step_speed > 0.0:
		v_scroll_bar.value = move_toward(v_scroll_bar.value, target_val, step_speed)
	else:
		# Lock the active typing position flush to the bottom edge of the application
		v_scroll_bar.value = target_val
	
	_apply_scroll(v_scroll_bar.value)

func scroll_to_ratio(ratio: float) -> void:
	_update_scrollbar_range()
	if v_scroll_bar and v_scroll_bar.visible:
		var max_val: float = maxf(0.0, v_scroll_bar.max_value - v_scroll_bar.page)
		v_scroll_bar.value = clampf(ratio, 0.0, 1.0) * max_val
		_apply_scroll(v_scroll_bar.value)

func scroll_to_bottom() -> void:
	_update_scrollbar_range()
	if v_scroll_bar and v_scroll_bar.visible:
		var max_val: float = maxf(0.0, v_scroll_bar.max_value - v_scroll_bar.page)
		v_scroll_bar.value = max_val
		_apply_scroll(max_val)

func scroll_to_top() -> void:
	_update_scrollbar_range()
	if v_scroll_bar:
		v_scroll_bar.value = 0.0
	_apply_scroll(0.0)

func open_document() -> void:
	show()
	set_expanded_document_mode(true)
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
	set_expanded_document_mode(true)
	if macro_banner:
		macro_banner.hide()
	if status_label:
		status_label.text = "Macros enabled. Document is being processed..."
	if v_scroll_bar:
		v_scroll_bar.hide()
	
	# Trigger pretest / typing puzzle
	if typing_puzzle:
		typing_puzzle.show()
		if typing_puzzle.has_method("start_puzzle"):
			typing_puzzle.start_puzzle()
	
	macro_enabled.emit()

func _on_typing_completed() -> void:
	if v_scroll_bar:
		v_scroll_bar.show()
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

func update_word_count() -> void:
	if not word_count_label:
		word_count_label = find_child("WordCountLabel", true, false) as Label
	if not word_count_label:
		return
	
	var text_str: String = ""
	if passage_label:
		text_str = passage_label.get_parsed_text() if passage_label.has_method("get_parsed_text") else passage_label.text
	elif report_editor:
		text_str = report_editor.text
	
	var clean_str: String = text_str.strip_edges()
	if clean_str.is_empty():
		word_count_label.text = "0 words"
		return
	
	var words: PackedStringArray = clean_str.split(" ", false)
	var count: int = 0
	for w: String in words:
		var token: String = w.strip_edges()
		if not token.is_empty() and token != "\n":
			count += 1
	word_count_label.text = "%d words" % count
