extends BaseClickSelectPuzzle

@onready var entries: ItemList = $Panel/Content/Entries
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel

func _ready() -> void:
	super._ready()
	_add_entry("18:58:07 | Report_Final.docx appeared in shared folder", "18:58:07")
	_add_entry("19:02:10 | WINWORD.EXE opened Report_Final.docx", "19:02:10")
	_add_entry("19:03:16 | User selected Enable Content", "19:03:16")
	_add_entry("21:21:50 | Office_Update_Helper started", "21:21:50")
	entries.item_selected.connect(_on_entry_selected)

func start_puzzle() -> void:
	super.start_puzzle()
	if not is_resolved and entries:
		entries.deselect_all()
		entries.mouse_filter = Control.MOUSE_FILTER_STOP

func _add_entry(label: String, timestamp: String) -> void:
	var index: int = entries.add_item(label)
	entries.set_item_metadata(index, {"selected_timestamp": timestamp})

func _on_entry_selected(index: int) -> void:
	var metadata: Dictionary = entries.get_item_metadata(index)
	submit_selection(StringName(metadata["selected_timestamp"]), metadata)

func on_solve_success() -> void:
	feedback_label.text = "✅ ถูกต้อง: WINWORD.EXE เปิดไฟล์ Report_Final.docx เวลา 19:02:10"
	for i: int in range(entries.item_count):
		entries.set_item_disabled(i, true)
	entries.mouse_filter = Control.MOUSE_FILTER_IGNORE

func on_solve_failed() -> void:
	feedback_label.text = "❌ ยังไม่ใช่เหตุการณ์เปิดไฟล์ครั้งแรก: ให้คลิกบรรทัดที่ WINWORD.EXE เปิด Report_Final.docx (19:02:10)"
