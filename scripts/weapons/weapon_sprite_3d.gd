extends AnimatedSprite3D

@export var bob_speed := 9.0
@export var bob_amount_x := 0.012
@export var bob_amount_y := 0.008
@export var return_speed := 6.0

@export var recoil_distance := 0.04
@export var recoil_down_amount := 0.003
@export var recoil_return_speed := 0.75
@export var flash_jitter_amount := 0.012
@export var flash_jitter_duration := 0.05

var base_position: Vector3
var bob_time := 0.0
var recoil_offset_z := 0.0
var recoil_offset_y := 0.0
var flash_offset := Vector2.ZERO
var flash_jitter_time := 0.0

@onready var player: CharacterBody3D = get_node("../../..")

func _ready() -> void:
	base_position = position

func _process(delta: float) -> void:
	if not player:
		return

	var horizontal_velocity := Vector3(player.velocity.x, 0, player.velocity.z)
	var is_moving := horizontal_velocity.length() > 0.5 and player.is_on_floor()
	var bob_offset := Vector2.ZERO
	if is_moving:
		bob_time += delta * bob_speed
		bob_offset.x = cos(bob_time * 0.5) * bob_amount_x
		bob_offset.y = abs(sin(bob_time)) * bob_amount_y
	else:
		bob_time = 0.0

	if flash_jitter_time > 0.0:
		flash_jitter_time -= delta
	else:
		flash_offset = flash_offset.lerp(Vector2.ZERO, minf(delta * 30.0, 1.0))

	recoil_offset_z = move_toward(recoil_offset_z, 0.0, recoil_return_speed * delta)
	recoil_offset_y = move_toward(recoil_offset_y, 0.0, recoil_return_speed * delta)
	position.x = base_position.x + bob_offset.x + flash_offset.x
	position.y = base_position.y + bob_offset.y + recoil_offset_y + flash_offset.y
	position.z = base_position.z + recoil_offset_z

func trigger_recoil() -> void:
	# Recuo instantâneo para trás, seguido de retorno suave no _process.
	recoil_offset_z = -recoil_distance
	recoil_offset_y = -recoil_down_amount
	flash_offset = Vector2(
		randf_range(-flash_jitter_amount, flash_jitter_amount),
		randf_range(-flash_jitter_amount, flash_jitter_amount)
	)
	flash_jitter_time = flash_jitter_duration
