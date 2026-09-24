extends Area3D

var has_player: bool = false
var is_open: bool = false

func _ready() -> void:
	# Conecta os sinais de entrada e saída de corpo
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and has_player:
		_open_door()

func _open_door() -> void:
	if is_open:
		return
	is_open = true
	var tween = create_tween()
	tween.tween_property($mesh, "position:x", -2, 1.0)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		has_player = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		has_player = false
