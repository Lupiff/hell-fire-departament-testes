extends Area3D

var has_player: bool = false
var is_open: bool = false

func _ready() -> void:
	print("Door ready, monitoring: ", monitoring, " mask: ", collision_mask)
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

	# Na Godot 4, cria-se o Tween diretamente por código
	var tween = create_tween()
	# "translation" virou "position" na Godot 4
	tween.tween_property($mesh, "position:x", -30, 1.0)

func _on_body_entered(body: Node3D) -> void:
	print("ENTROU NA AREA: ", body.name, " | grupos: ", body.get_groups())
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		has_player = true
		print("has_player = true")

func _on_body_exited(body: Node3D) -> void:
	print("SAIU DA AREA: ", body.name)
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		has_player = false
