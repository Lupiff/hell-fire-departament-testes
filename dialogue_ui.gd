extends CanvasLayer

signal dialogue_finished

@onready var dim_background: ColorRect = $Control/DimBackground
@onready var left_portrait: TextureRect = $Control/DialogueBox/LeftPortrait
@onready var right_portrait: TextureRect = $Control/DialogueBox/RightPortrait
@onready var name_label: Label = $Control/DialogueBox/NameLabel
@onready var text_label: RichTextLabel = $Control/DialogueBox/TextLabel

var lines: Array[DialogueLine] = []
var current_line := 0
var is_typing := false
var typing_speed := 0.02
var player_ref: Node3D = null

func start_dialogue(dialogue_data: DialogueData, player: Node3D) -> void:
	lines = dialogue_data.lines
	current_line = 0
	player_ref = player
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE   # opcional, se quiser liberar o mouse durante o diálogo
	_show_line()

func _show_line() -> void:
	if current_line >= lines.size():
		_end_dialogue()
		return

	var line: DialogueLine = lines[current_line]
	name_label.text = line.speaker_name
	text_label.text = line.text
	text_label.visible_ratio = 0.0

	if line.speaker == DialogueLine.Speaker.NPC:
		left_portrait.texture = line.portrait
		left_portrait.modulate = Color.WHITE
		right_portrait.modulate = Color(1, 1, 1, 0.4)
	else:
		right_portrait.texture = line.portrait
		right_portrait.modulate = Color.WHITE
		left_portrait.modulate = Color(1, 1, 1, 0.4)

	is_typing = true
	_type_text()

func _type_text() -> void:
	var total_chars := text_label.get_total_character_count()
	var elapsed := 0.0
	while is_typing and text_label.visible_ratio < 1.0:
		await get_tree().create_timer(typing_speed).timeout
		if not is_typing:
			return
		elapsed += typing_speed
		text_label.visible_ratio = clampf(elapsed / maxf(total_chars * typing_speed, 0.01), 0.0, 1.0)
	is_typing = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_typing:
			text_label.visible_ratio = 1.0
			is_typing = false
		else:
			current_line += 1
			_show_line()

func _end_dialogue() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	dialogue_finished.emit()
	queue_free()
