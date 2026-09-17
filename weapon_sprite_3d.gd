extends AnimatedSprite3D

# --- Bobbing (existente) ---
@export var bob_speed: float = 14.0
@export var bob_amount_x: float = 0.02
@export var bob_amount_y: float = 0.015
@export var return_speed: float = 6.0

# --- Recoil (novo) ---
@export var recoil_distance := 0.1
#@export var recoil_down_amount := 0.03
@export var recoil_out_time := 0.03
@export var recoil_return_time := 0.15

var base_position: Vector3
var bob_time: float = 0.0
var recoil_offset_z: float = 0.0
#var recoil_offset_y: float = 0.0
var recoil_tween: Tween

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
		#position.y = base_position.y + offset_y + recoil_offset_y
	else:
		bob_time = 0.0
		position.x = lerp(position.x, base_position.x, delta * return_speed)
		position.y = lerp(position.y, base_position.y, delta * return_speed)

	# Z fica só por conta do recoil, nunca do bobbing
	position.z = base_position.z + recoil_offset_z

func trigger_recoil():
	if recoil_tween:
		recoil_tween.kill()

	recoil_tween = create_tween()
	recoil_tween.set_parallel(true)
	
	recoil_tween.tween_property(self, "recoil_offset_z", recoil_distance, recoil_out_time)
	#recoil_tween.tween_property(self, "recoil_offset_y", -recoil_down_amount, recoil_out_time)

	recoil_tween.chain().tween_property(self, "recoil_offset_z", 0.0, recoil_return_time)
	#recoil_tween.chain().tween_property(self, "recoil_offset_y", 0.0, recoil_return_time)
