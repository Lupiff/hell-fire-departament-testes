extends Area3D

@export var required_key: String = ""   # "" = porta branca, abre sem chave

var has_player: bool = false
var is_open: bool = false
var player_ref: Node3D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and has_player:
		_try_open_door()

func _try_open_door() -> void:
	if is_open:
		return

	if required_key != "":
		if player_ref == null or not player_ref.has_key(required_key):
			print("Precisa da chave: ", required_key)
			return

	_open_door()

func _open_door() -> void:
	is_open = true
	var tween = create_tween()
	tween.tween_property($mesh, "position:x", -2, 1.0)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		has_player = true
		player_ref = body

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		has_player = false
		player_ref = null
