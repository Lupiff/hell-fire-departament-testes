extends TextureRect

@onready var base_position = position
var bob_time = 0.0

func _process(delta):
	var is_moving = Input.get_vector("left", "right", "forward", "back").length() > 0.1
	if is_moving:
		bob_time += delta * 10.0
		position.y = base_position.y + sin(bob_time) * 5.0
		position.x = base_position.x + cos(bob_time * 0.5) * 3.0
	else:
		bob_time = 0.0
		position = position.lerp(base_position, delta * 5.0)
