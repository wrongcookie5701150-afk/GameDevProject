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
	feedback_label.text = "Correct: %s is a spoofed university domain." % SPOOFED_DOMAIN
	entries.disabled = true

func on_solve_failed() -> void:
	feedback_label.text = "That file came from the expected sender. Check the report sender closely."
