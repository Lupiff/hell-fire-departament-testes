extends Sprite3D

@export var bob_speed: float = 14.0
@export var bob_amount_x: float = 0.02
@export var bob_amount_y: float = 0.015
@export var return_speed: float = 6.0

var base_position: Vector3
var bob_time: float = 0.0

@onready var player: CharacterBody3D = get_node("../../..")

func _ready():
	base_position = position

func _process(delta):
	if not player:
		return

	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	var is_moving = horizontal_velocity.length() > 0.5 and player.is_on_floor()

	if is_moving:
		bob_time += delta * bob_speed
		var offset_x = cos(bob_time * 0.5) * bob_amount_x
		var offset_y = abs(sin(bob_time)) * bob_amount_y

		position.x = base_position.x + offset_x
		position.y = base_position.y + offset_y
	else:
		bob_time = 0.0
		position = position.lerp(base_position, delta * return_speed)
