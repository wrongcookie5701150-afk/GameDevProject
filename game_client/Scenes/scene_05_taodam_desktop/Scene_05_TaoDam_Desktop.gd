extends Control

@onready var player: BasePlayer = $Playground/Player
@onready var tao_dam: InteractObject = $Interactables/TaoDam
@onready var task_objective: Label = $CanvasLayer/TaskObjective
@onready var notebook_screen: Control = $CanvasLayer/NotebookScreen
@onready var forensic_toolbar: Panel = $CanvasLayer/ForensicToolbar
@onready var close_notebook_button: Button = $CanvasLayer/ForensicToolbar/Content/CloseNotebookButton
@onready var status_label: Label = $CanvasLayer/ForensicToolbar/Content/StatusLabel
@onready var hash_puzzle: BaseDecoderPuzzle = $CanvasLayer/Puzzle_Hash_Verify
@onready var macro_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_File_Structure
@onready var decoder_puzzle: DecoderPuzzle = $CanvasLayer/Puzzle_Decoder
@onready var persistence_puzzle: BaseSequencePuzzle = $CanvasLayer/Puzzle_Persistence_Order
@onready var completion_panel: Panel = $CanvasLayer/CompletionPanel
@onready var recovery_button: Button = $CanvasLayer/CompletionPanel/RecoveryButton

@onready var hash_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/HashButton
@onready var macro_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/MacroButton
@onready var decoder_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/DecoderButton
@onready var inspector_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/InspectorButton
@onready var persistence_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/PersistenceButton

var _hash_verified: bool = false
var _macro_inspected: bool = false
var _decoding_complete: bool = false

func _ready() -> void:
	notebook_screen.hide()
	forensic_toolbar.hide()
	_hide_puzzles()
	completion_panel.hide()
	task_objective.text = "Walk to TaoDam and press Space to inspect the laptop."
	tao_dam.player_approached.connect(_on_tao_dam_approached)
	tao_dam.player_left.connect(_on_tao_dam_left)
	player.interacted_with.connect(_on_player_interacted)
	close_notebook_button.pressed.connect(_on_close_notebook_pressed)
	recovery_button.pressed.connect(_on_recovery_pressed)
	hash_button.pressed.connect(_on_hash_pressed)
	macro_button.pressed.connect(_on_macro_pressed)
	decoder_button.pressed.connect(_on_decoder_pressed)
	inspector_button.pressed.connect(_on_inspector_pressed)
	persistence_button.pressed.connect(_on_persistence_pressed)
	hash_puzzle.puzzle_resolved.connect(_on_hash_verified)
	macro_puzzle.puzzle_resolved.connect(_on_macro_inspected)
	decoder_puzzle.all_decoding_complete.connect(_on_decoding_complete)
	persistence_puzzle.puzzle_resolved.connect(_on_persistence_stopped)
	_refresh_tool_availability()

func _on_tao_dam_approached(_object: InteractObject, _approaching_player: Node2D) -> void:
	task_objective.text = "Press Space to inspect TaoDam."

func _on_tao_dam_left(_object: InteractObject, _leaving_player: Node2D) -> void:
	if not notebook_screen.visible:
		task_objective.text = "Walk to TaoDam and press Space to inspect the laptop."

func _on_player_interacted(target: Node) -> void:
	var interact_object: InteractObject = target as InteractObject
	if not interact_object or interact_object != tao_dam:
		return
	_open_notebook_overlay()

func _open_notebook_overlay() -> void:
	# Keep NotebookScreen exactly as authored; forensic tools are layered over it here.
	notebook_screen.show()
	forensic_toolbar.show()
	task_objective.text = "TaoDam ready. Select a forensic tool from the overlay."

func _on_close_notebook_pressed() -> void:
	notebook_screen.hide()
	forensic_toolbar.hide()
	task_objective.text = "Walk to TaoDam and press Space to inspect the laptop."

func _on_hash_pressed() -> void:
	_launch_puzzle("T08", hash_puzzle)

func _on_macro_pressed() -> void:
	if not _hash_verified:
		status_label.text = "Verify the evidence copy with FTK Imager first."
		return
	_launch_puzzle("T09", macro_puzzle)

func _on_decoder_pressed() -> void:
	if not _macro_inspected:
		status_label.text = "Inspect the document macro structure first."
		return
	var task_to_launch: String = "T11" if decoder_puzzle.decode_stage == 1 else "T10"
	_launch_puzzle(task_to_launch, decoder_puzzle)

func _on_inspector_pressed() -> void:
	if not _decoding_complete:
		status_label.text = "Decode the helper name and mode before inspecting it."
		return
	status_label.text = "Office_Update_Helper.dat: logon/idle trigger; action modifies project files."

func _on_persistence_pressed() -> void:
	if not _decoding_complete:
		status_label.text = "Decode and inspect the helper before stopping persistence."
		return
	_launch_puzzle("T12", persistence_puzzle)

func _launch_puzzle(puzzle_id: String, puzzle: BasePuzzleUI) -> void:
	_hide_puzzles()
	puzzle.show()
	puzzle.start_puzzle()
	status_label.text = "%s ready." % puzzle_id

func _on_hash_verified() -> void:
	_hash_verified = true
	_hide_puzzles()
	status_label.text = "T08 complete: evidence hash matches Evidence_Manifest.txt."
	_refresh_tool_availability()

func _on_macro_inspected() -> void:
	_macro_inspected = true
	_hide_puzzles()
	status_label.text = "T09 complete: vbaProject.bin contains the macro project."
	_refresh_tool_availability()

func _on_decoding_complete() -> void:
	_decoding_complete = true
	_hide_puzzles()
	status_label.text = "T10/T11 complete: helper name and Wiper Mode identified."
	_refresh_tool_availability()

func _on_persistence_stopped() -> void:
	_hide_puzzles()
	notebook_screen.hide()
	forensic_toolbar.hide()
	completion_panel.show()
	status_label.text = "Scene 5 complete. Persistence is stopped; recovery is next."

func _on_recovery_pressed() -> void:
	var result: Error = get_tree().change_scene_to_file(
		"res://scenes/scene_06_recovery/Scene_06_Recovery.tscn"
	)
	if result != OK:
		push_error("Unable to load Scene 6 recovery: %s" % result)

func _refresh_tool_availability() -> void:
	macro_button.disabled = not _hash_verified
	decoder_button.disabled = not _macro_inspected
	inspector_button.disabled = not _decoding_complete
	persistence_button.disabled = not _decoding_complete

func _hide_puzzles() -> void:
	hash_puzzle.hide()
	macro_puzzle.hide()
	decoder_puzzle.hide()
	persistence_puzzle.hide()
