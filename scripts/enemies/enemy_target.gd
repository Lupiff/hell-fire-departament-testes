extends StaticBody3D

const HEALTH_BAR_WIDTH := 1.1

@export var max_health := 100
var health := 100

@onready var health_fill: MeshInstance3D = $HealthBar/HealthBarFill
@onready var health_bar: Node3D = $HealthBar

func _ready() -> void:
	health = max_health
	_update_health_bar()

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera:
		health_bar.look_at(camera.global_position, Vector3.UP, true)

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	_update_health_bar()
	if health == 0:
		queue_free()

func _update_health_bar() -> void:
	var ratio := clampf(float(health) / max_health, 0.0, 1.0)
	health_fill.scale.x = ratio
	health_fill.position.x = -HEALTH_BAR_WIDTH * (1.0 - ratio) * 0.5
