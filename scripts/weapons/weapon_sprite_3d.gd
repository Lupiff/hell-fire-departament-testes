extends AnimatedSprite3D

@export var bob_speed := 9.0
@export var bob_amount_x := 0.012
@export var bob_amount_y := 0.008
@export var return_speed := 6.0

@export var recoil_distance := 0.1
@export var recoil_out_time := 0.03
@export var recoil_return_time := 0.15
@export var flash_jitter_amount := 0.012
@export var flash_jitter_duration := 0.05

var base_position: Vector3
var bob_time := 0.0
var recoil_offset_z := 0.0
var recoil_tween: Tween
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
	if is_moving:
		bob_time += delta * bob_speed
		var offset_x := cos(bob_time * 0.5) * bob_amount_x
		position.x = base_position.x + offset_x + flash_offset.x
		position.y = base_position.y #+ flash_offset.y
	else:
		bob_time = 0.0
		position.x = lerp(position.x, base_position.x + flash_offset.x, delta * return_speed)
		position.y = lerp(position.y, base_position.y + flash_offset.y, delta * return_speed)

	if flash_jitter_time > 0.0:
		flash_jitter_time -= delta
	else:
		flash_offset = flash_offset.lerp(Vector2.ZERO, minf(delta * 30.0, 1.0))

	position.z = base_position.z + recoil_offset_z

func trigger_recoil() -> void:
	if recoil_tween:
		recoil_tween.kill()

	recoil_tween = create_tween()
	recoil_tween.set_parallel(true)
	recoil_tween.tween_property(self, "recoil_offset_z", recoil_distance, recoil_out_time)
	recoil_tween.chain().tween_property(self, "recoil_offset_z", 0.0, recoil_return_time)

	flash_offset = Vector2(
		randf_range(-flash_jitter_amount, flash_jitter_amount),
		randf_range(-flash_jitter_amount, flash_jitter_amount)
	)
	flash_jitter_time = flash_jitter_duration
