extends Control

## แถบแสดง Item Inventory UI (Hotbar 3 ช่อง)
## แสดงผลช่องไอเทม [1], [2], [3] และสถานะการถือไอเทมในปัจจุบัน
## ซ่อนอัตโนมัติหากไม่ได้อยู่ใน Playground เช่น ขณะใช้คอมพิวเตอร์ หรือเปิดหน้าจอ Overlay

@onready var slots_container: HBoxContainer = $MarginContainer/VBoxContainer/SlotsContainer
@onready var active_item_label: Label = $MarginContainer/VBoxContainer/ActiveItemLabel

# Styles
var style_normal: StyleBoxFlat
var style_selected: StyleBoxFlat
var style_empty: StyleBoxFlat

# Overlay checking cache
var _cached_scene: Node = null
var _monitored_overlays: Array[CanvasItem] = []

const COMPUTER_AND_OVERLAY_NAMES: Array[String] = [
	"DesktopScreen",
	"NotebookScreen",
	"DesktopPanel",
	"ForensicToolbar",
	"NoteBoard",
	"Checklist_UI",
	"Puzzle_Event_Log",
	"Puzzle_Drive_History",
	"EVDrivePanel",
	"Puzzle_Hash_Verify",
	"Puzzle_File_Structure",
	"Puzzle_Decoder",
	"Puzzle_Persistence_Order",
	"Puzzle_321_Backup",
	"Puzzle_Last_Boss_Summary",
	"KSA_Evaluation_UI",
	"ContinueModal",
	"SettingsModal"
]

func _ready() -> void:
	_create_styles()
	_connect_slots_mouse()
	
	if Engine.has_singleton("InventoryManager") or get_node_or_null("/root/InventoryManager"):
		var inv = get_node_or_null("/root/InventoryManager")
		if inv:
			inv.inventory_updated.connect(update_ui)
			inv.slot_selected.connect(_on_slot_selected)
			if inv.has_signal("visibility_changed"):
				inv.visibility_changed.connect(_on_manager_visibility_changed)
	
	_refresh_overlays_cache()
	update_ui()
	_update_visibility()

func _process(_delta: float) -> void:
	_update_visibility()

func _update_visibility() -> void:
	var should_show: bool = _should_be_visible()
	if visible != should_show:
		visible = should_show

func _should_be_visible() -> bool:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and not inv.is_visible:
		return false
	
	var playground: Node = _find_playground()
	if not playground:
		return false
	
	# ซ่อนเมื่อมี DialogueBox กำลังแสดงข้อความ
	var dialogue_box = playground.get_node_or_null("Textbox/DialogueBox")
	if dialogue_box and is_instance_valid(dialogue_box) and dialogue_box.visible:
		return false
	
	# ซ่อนเมื่อใช้คอมพิวเตอร์ หรือเปิด Overlay เต็มจอ
	if _is_computer_or_overlay_active():
		return false
	
	return true

func _find_playground() -> Node:
	var p = get_parent()
	while p:
		if p is Playground or p.name == "Playground":
			return p
		p = p.get_parent()
	
	var cur = get_tree().current_scene if get_tree() else null
	if cur:
		if cur is Playground or cur.name == "Playground":
			return cur
		var pg = cur.find_child("Playground", true, false)
		if pg:
			return pg
	return null

func _refresh_overlays_cache() -> void:
	var cur = get_tree().current_scene if get_tree() else null
	if not cur:
		return
	_cached_scene = cur
	_monitored_overlays.clear()
	for overlay_name in COMPUTER_AND_OVERLAY_NAMES:
		for node in cur.find_children(overlay_name, "Control", true, false):
			if node is Control:
				_monitored_overlays.append(node as CanvasItem)

func _is_computer_or_overlay_active() -> bool:
	var cur = get_tree().current_scene if get_tree() else null
	if not cur:
		return false
	
	if _cached_scene != cur:
		_refresh_overlays_cache()
	
	for overlay in _monitored_overlays:
		if is_instance_valid(overlay) and overlay.visible:
			return true
	
	# Fallback ตรวจจับโหนดหน้าจอคอมหรือ Overlay (เฉพาะ Control เท่านั้น เพื่อไม่ให้ชนกับ StaticBody2D NoteBoard ในฉาก)
	for nb in cur.find_children("NoteBoard", "Control", true, false):
		if is_instance_valid(nb) and (nb as Control).visible:
			return true
	
	for desktop in cur.find_children("DesktopScreen", "Control", true, false):
		if is_instance_valid(desktop) and (desktop as Control).visible:
			return true
	
	for notebook in cur.find_children("NotebookScreen", "Control", true, false):
		if is_instance_valid(notebook) and (notebook as Control).visible:
			return true
	
	return false

func _on_manager_visibility_changed(_is_vis: bool) -> void:
	_update_visibility()

func _create_styles() -> void:
	# สไตล์ช่องปกติที่มีของ
	style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.08, 0.12, 0.18, 0.85)
	style_normal.set_border_width_all(1)
	style_normal.border_color = Color(0.25, 0.55, 0.8, 0.8)
	style_normal.set_corner_radius_all(3)

	# สไตล์ช่องที่ถูกเลือกกำลังถือใช้งาน (Selected / Highlight)
	style_selected = StyleBoxFlat.new()
	style_selected.bg_color = Color(0.12, 0.25, 0.35, 0.95)
	style_selected.set_border_width_all(2)
	style_selected.border_color = Color(0.3, 0.95, 1.0, 1.0)
	style_selected.set_corner_radius_all(3)
	style_selected.shadow_color = Color(0.3, 0.95, 1.0, 0.4)
	style_selected.shadow_size = 2

	# สไตล์ช่องว่าง
	style_empty = StyleBoxFlat.new()
	style_empty.bg_color = Color(0.04, 0.06, 0.1, 0.6)
	style_empty.set_border_width_all(1)
	style_empty.border_color = Color(0.2, 0.25, 0.35, 0.5)
	style_empty.set_corner_radius_all(3)

func _connect_slots_mouse() -> void:
	if not slots_container:
		return
	for i in range(slots_container.get_child_count()):
		var slot_panel = slots_container.get_child(i) as Control
		if slot_panel:
			slot_panel.mouse_filter = Control.MOUSE_FILTER_PASS
			slot_panel.gui_input.connect(func(event: InputEvent) -> void:
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					var inv = get_node_or_null("/root/InventoryManager")
					if inv:
						inv.select_slot(i)
			)

func update_ui() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if not inv or not slots_container:
		return

	for i in range(slots_container.get_child_count()):
		var slot_panel = slots_container.get_child(i) as PanelContainer
		if not slot_panel:
			continue

		var icon_rect = slot_panel.get_node_or_null("CenterContainer/IconRect") as TextureRect
		var is_selected: bool = (inv.selected_slot == i)
		var slot_data: Dictionary = inv.slots[i] if i < inv.slots.size() else {}
		var has_item: bool = not slot_data.is_empty()

		# อัปเดตสไตล์ของกรอบช่อง
		if is_selected:
			slot_panel.add_theme_stylebox_override("panel", style_selected)
		elif has_item:
			slot_panel.add_theme_stylebox_override("panel", style_normal)
		else:
			slot_panel.add_theme_stylebox_override("panel", style_empty)

		# อัปเดตไอคอน
		if icon_rect:
			if has_item and slot_data.get("icon"):
				icon_rect.texture = slot_data.get("icon")
				icon_rect.visible = true
			else:
				icon_rect.texture = null
				icon_rect.visible = false

	# อัปเดตข้อความบอกไอเทมที่กำลังถือ
	_update_active_label()

func _on_slot_selected(_slot_index: int, _item_data: Dictionary) -> void:
	update_ui()

func _update_active_label() -> void:
	if not active_item_label:
		return
	var inv = get_node_or_null("/root/InventoryManager")
	if not inv:
		return

	if inv.selected_slot != -1:
		var item: Dictionary = inv.get_active_item()
		var item_name: String = item.get("name", "")
		active_item_label.text = "ถือ: %s (กด %d หรือ V เพื่อเก็บ)" % [item_name, inv.selected_slot + 1]
		active_item_label.visible = true
	else:
		active_item_label.text = ""
		active_item_label.visible = false
