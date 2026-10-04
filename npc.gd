extends Area3D
class_name NPC

@export var dialogue: DialogueData
@export var weapon_reward: WeaponData
var weapon_given := false	

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

	if weapon_reward and not weapon_given and player_ref:
		var cam := player_ref.get_node_or_null("Head/Camera3D")
		if cam and cam.has_method("unlock_weapon"):
			cam.unlock_weapon(weapon_reward)
			weapon_given = true

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
