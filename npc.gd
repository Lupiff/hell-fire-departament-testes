extends Area3D
class_name NPC

@export var dialogue: DialogueData

const DIALOGUE_UI_SCENE: PackedScene = preload("res://scenes/npc/DialogueUI.tscn")

var has_player := false
var player_ref: Node3D = null
var is_talking := false
var can_interact := true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if has_player and not is_talking and can_interact and Input.is_action_just_pressed("interact"):
		_start_dialogue()

func _start_dialogue() -> void:
	if not dialogue or dialogue.lines.is_empty():
		return
	is_talking = true
	var ui := DIALOGUE_UI_SCENE.instantiate()
	get_tree().current_scene.add_child(ui)
	ui.dialogue_finished.connect(_on_dialogue_finished)
	ui.start_dialogue(dialogue, player_ref)

func _on_dialogue_finished() -> void:
	is_talking = false
	can_interact = false
	await get_tree().create_timer(0.2).timeout
	can_interact = true

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		has_player = true
		player_ref = body

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		has_player = false
		player_ref = null
