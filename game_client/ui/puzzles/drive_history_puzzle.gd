extends BaseClickSelectPuzzle

const SPOOFED_EMAIL: String = "mesasohot.sukj@universcity.example"
const SPOOFED_DOMAIN: String = "universcity.example"

@onready var entries: ItemList = $Panel/Content/Entries
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel

func _ready() -> void:
	super._ready()
	_add_entry(
		"18:54 | Network_Diagram.png | mesa.sukj@university.example | Normal",
		"network_diagram",
		"mesa.sukj@university.example"
	)
	_add_entry(
		"18:56 | Research_Data.xlsx | mesa.sukj@university.example | Normal",
		"research_data",
		"mesa.sukj@university.example"
	)
	_add_entry(
		"18:58 | Report_Final.docx | mesasohot.sukj@universcity.example | Macro-enabled",
		"report_final",
		SPOOFED_EMAIL
	)
	entries.item_selected.connect(_on_entry_selected)

func start_puzzle() -> void:
	super.start_puzzle()
	if not is_resolved and entries:
		entries.deselect_all()
		entries.mouse_filter = Control.MOUSE_FILTER_STOP

func _add_entry(label: String, option_id: String, sender_email: String) -> void:
	var index: int = entries.add_item(label)
	entries.set_item_metadata(index, {
		"selected_email": sender_email,
		"domain_checked": sender_email.get_slice("@", 1),
		"file_name": option_id
	})

func _on_entry_selected(index: int) -> void:
	var metadata: Dictionary = entries.get_item_metadata(index)
	submit_selection(StringName(metadata["file_name"]), metadata)

func on_solve_success() -> void:
	feedback_label.text = "✅ ถูกต้อง: พบโดเมนปลอมแปลง %s (สะกดผิดจาก university.example)" % SPOOFED_DOMAIN
	for i: int in range(entries.item_count):
		entries.set_item_disabled(i, true)
	entries.mouse_filter = Control.MOUSE_FILTER_IGNORE

func on_solve_failed() -> void:
	feedback_label.text = "❌ ไฟล์นี้มาจากโดเมนจริง (@university.example) ให้คลิกไฟล์ Report_Final.docx ที่มาจาก @universcity.example"
