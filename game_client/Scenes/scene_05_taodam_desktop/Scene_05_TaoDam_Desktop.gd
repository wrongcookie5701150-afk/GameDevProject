extends Control

@onready var status_label: Label = $DesktopPanel/Content/StatusLabel
@onready var evidence_label: Label = $DesktopPanel/Content/EvidenceLabel
@onready var hash_puzzle: BaseDecoderPuzzle = $Puzzle_Hash_Verify
@onready var macro_puzzle: BaseClickSelectPuzzle = $Puzzle_File_Structure
@onready var decoder_puzzle: BaseDecoderPuzzle = $Puzzle_Decoder
@onready var persistence_puzzle: BaseSequencePuzzle = $Puzzle_Persistence_Order
@onready var completion_panel: Panel = $CompletionPanel

var _hash_verified: bool = false
var _macro_inspected: bool = false
var _decoding_complete: bool = false

func _ready() -> void:
	hash_puzzle.hide()
	macro_puzzle.hide()
	decoder_puzzle.hide()
	persistence_puzzle.hide()
	completion_panel.hide()
	evidence_label.text = "EV Drive: evidence copy mounted read-only"
	$DesktopPanel/Content/FTKButton.pressed.connect(_on_ftk_pressed)
	$DesktopPanel/Content/OlevbaButton.pressed.connect(_on_olevba_pressed)
	$DesktopPanel/Content/DecoderButton.pressed.connect(_on_decoder_pressed)
	$DesktopPanel/Content/InspectorButton.pressed.connect(_on_inspector_pressed)
	$DesktopPanel/Content/PersistenceButton.pressed.connect(_on_persistence_pressed)
	hash_puzzle.puzzle_resolved.connect(_on_hash_verified)
	macro_puzzle.puzzle_resolved.connect(_on_macro_inspected)
	decoder_puzzle.all_decoding_complete.connect(_on_decoding_complete)
	persistence_puzzle.puzzle_resolved.connect(_on_persistence_stopped)

func _on_ftk_pressed() -> void:
	_hide_puzzles()
	hash_puzzle.show()
	hash_puzzle.start_puzzle()
	status_label.text = "FTK Imager: compare evidence hashes with Evidence_Manifest.txt."

func _on_olevba_pressed() -> void:
	if not _hash_verified:
		status_label.text = "Verify the evidence hash before inspecting the document."
		return
	_hide_puzzles()
	macro_puzzle.show()
	macro_puzzle.start_puzzle()
	status_label.text = "Read-only document structure inspection."

func _on_decoder_pressed() -> void:
	if not _macro_inspected:
		status_label.text = "Inspect the macro container before using the decoder."
		return
	_hide_puzzles()
	decoder_puzzle.show()
	decoder_puzzle.start_puzzle()
	status_label.text = "Decode the helper name, then determine its mode."

func _on_inspector_pressed() -> void:
	if not _decoding_complete:
		status_label.text = "Decode both helper values before reviewing persistence details."
		return
	status_label.text = "Inspector: Office_Update_Helper.dat starts at logon/idle and modifies project files."

func _on_persistence_pressed() -> void:
	if not _decoding_complete:
		status_label.text = "Decode the helper values before ordering containment steps."
		return
	_hide_puzzles()
	persistence_puzzle.show()
	persistence_puzzle.start_puzzle()
	status_label.text = "Arrange the seven containment steps before recovery."

func _on_hash_verified() -> void:
	_hash_verified = true
	status_label.text = "T08 complete: evidence copy matches the manifest."
	_hide_puzzles()

func _on_macro_inspected() -> void:
	_macro_inspected = true
	status_label.text = "T09 complete: vbaProject.bin contains the macro project."
	_hide_puzzles()

func _on_decoding_complete() -> void:
	_decoding_complete = true
	status_label.text = "T10/T11 complete: helper identity and Wiper Mode decoded."
	_hide_puzzles()

func _on_persistence_stopped() -> void:
	_hide_puzzles()
	completion_panel.show()
	status_label.text = "Scene 5 complete. The persistence trigger is stopped; recovery is next."

func _hide_puzzles() -> void:
	hash_puzzle.hide()
	macro_puzzle.hide()
	decoder_puzzle.hide()
	persistence_puzzle.hide()
